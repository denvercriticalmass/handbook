class Admin::InvitationsController < Admin::BaseController
  def new
    authorize Invitation
  end

  def create
    authorize Invitation

    invitation = Current.user.sent_invitations.create(email_address: params[:email_address])

    if invitation.persisted?
      InvitationsMailer.invite(invitation).deliver_later
      redirect_to new_admin_invitation_path, notice: "Invited #{invitation.email_address}."
    else
      redirect_to new_admin_invitation_path, alert: "That address couldn't be invited."
    end
  end
end
