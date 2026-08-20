class PasskeySessionsController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 10, within: 3.minutes, only: :create,
    with: -> { redirect_to new_session_path, alert: "Try again later." }

  # No allow list, so the authenticator offers whatever it holds for this site
  # and nobody has to type an address first.
  def challenge
    options = WebAuthn::Credential.options_for_get(user_verification: "required")

    session[:passkey_challenge] = options.challenge

    render json: options
  end

  def create
    if user = admin_behind_the_passkey
      start_new_session_for user
      redirect_to after_authentication_url
    else
      refuse
    end
  rescue WebAuthn::Error, JSON::ParserError, TypeError
    refuse
  end

  private

    def admin_behind_the_passkey
      credential = WebAuthn::Credential.from_get(JSON.parse(params[:credential].to_s))
      passkey = Passkey.find_by(external_id: credential.id)
      return if passkey.nil?

      credential.verify(
        session.delete(:passkey_challenge),
        public_key: passkey.public_key,
        sign_count: passkey.sign_count,
        user_verification: true
      )
      return unless passkey.user.active?

      passkey.update!(sign_count: credential.sign_count, last_used_at: Time.current)
      passkey.user
    end

    def refuse
      redirect_to new_session_path, alert: "That passkey didn't work."
    end
end
