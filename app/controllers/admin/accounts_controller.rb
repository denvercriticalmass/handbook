class Admin::AccountsController < Admin::BaseController
  # There is no id to authorize against; the record is always Current.user.
  skip_after_action :verify_authorized

  def show
    @account = Current.user
  end

  def update
    @account = Current.user

    if @account.update(account_params)
      redirect_to admin_account_path, notice: "Saved."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

    # A blank password field means "leave it alone", not "set it to blank".
    def account_params
      submitted = params.permit(:name, :email_address, :password, :password_confirmation)
      submitted[:password].blank? ? submitted.except(:password, :password_confirmation) : submitted
    end
end
