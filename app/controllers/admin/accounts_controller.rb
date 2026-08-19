# A singular resource with no id, so an admin can only ever reach their own.
class Admin::AccountsController < Admin::BaseController
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
      submitted = params.permit(:email_address, :password, :password_confirmation)
      submitted[:password].blank? ? submitted.except(:password, :password_confirmation) : submitted
    end
end
