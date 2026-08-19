class Admin::UsersController < Admin::BaseController
  def index
    authorize User

    @users = User.order(:email_address)
  end

  def update
    user = User.find(params[:id])
    authorize user

    user.update(active: params[:active])
    redirect_to admin_users_path
  end
end
