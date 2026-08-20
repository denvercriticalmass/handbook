class OmniauthSessionsController < ApplicationController
  allow_unauthenticated_access

  def create
    if user = existing_admin || registered_admin
      start_new_session_for user
      redirect_to after_authentication_url
    else
      refuse
    end
  end

  def failure
    refuse
  end

  private

    def auth
      request.env["omniauth.auth"]
    end

    def address
      auth&.info&.email.to_s.strip.downcase
    end

    def existing_admin
      User.active.find_by(email_address: address)
    end

    # Google is the only way into this account, so the password is never used.
    def registered_admin
      Registration.new(
        email_address: address,
        name: auth&.info&.name.presence || address,
        password: SecureRandom.base58(48),
        token: request.env.dig("omniauth.params", "token")
      ).create
    end

    # Says nothing about whether the account exists or is only suspended.
    def refuse
      redirect_to new_session_path, alert: "That Google account can't sign in here."
    end
end
