class Admin::PasskeyChallengesController < Admin::BaseController
  # The record is always Current.user's, so there is no id to authorize against.
  skip_after_action :verify_authorized

  def create
    options = WebAuthn::Credential.options_for_create(
      user: {
        id: Current.user.passkey_handle,
        name: Current.user.email_address,
        display_name: Current.user.name
      },
      authenticator_selection: { resident_key: "required", user_verification: "required" },
      exclude: Current.user.passkeys.pluck(:external_id)
    )

    session[:passkey_challenge] = options.challenge

    render json: options
  end
end
