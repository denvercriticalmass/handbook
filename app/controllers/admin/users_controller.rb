class Admin::UsersController < Admin::BaseController
  def index
    authorize User
    authorize Invitation

    @users = User.order(:name)
    @invitations = Invitation.outstanding
  end

  def update
    user = User.find(params[:id])
    authorize user

    user.update(active: params[:active])
    redirect_to admin_users_path
  end
end
