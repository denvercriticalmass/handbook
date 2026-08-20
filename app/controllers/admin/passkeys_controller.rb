class Admin::PasskeysController < Admin::BaseController
  # Scoping to Current.user's own passkeys is the authorization.
  skip_after_action :verify_authorized

  def create
    passkey = Current.user.passkeys.new(nickname: params[:nickname], **enrolled_credential)

    if passkey.save
      redirect_to admin_account_path, notice: "Added #{passkey.nickname}."
    else
      refuse_passkey
    end
  rescue WebAuthn::Error, JSON::ParserError, TypeError
    refuse_passkey
  end

  def destroy
    passkey = Current.user.passkeys.find(params[:id])
    passkey.destroy

    redirect_to admin_account_path, notice: "Removed #{passkey.nickname}."
  end

  private

    def enrolled_credential
      credential = WebAuthn::Credential.from_create(JSON.parse(params[:credential].to_s))
      credential.verify(session.delete(:passkey_challenge))

      { external_id: credential.id, public_key: credential.public_key, sign_count: credential.sign_count }
    end

    def refuse_passkey
      redirect_to admin_account_path, alert: "That passkey could not be added."
    end
end
