class Admin::AccountsController < Admin::BaseController
  # There is no id to authorize against; the record is always Current.user.
  skip_after_action :verify_authorized

  before_action :load_account

  def update
    if @account.update(account_params)
      redirect_to admin_account_path, notice: "Saved."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

    def load_account
      @account = Current.user
      @passkeys = Current.user.passkeys.order(:created_at)
    end

    # A blank password field means "leave it alone", not "set it to blank".
    def account_params
      submitted = params.permit(:name, :email_address, :password, :password_confirmation)
      submitted[:password].blank? ? submitted.except(:password, :password_confirmation) : submitted
    end
end
