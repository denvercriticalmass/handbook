class InvitationsMailer < ApplicationMailer
  def invite(invitation)
    @invitation = invitation

    mail to: invitation.email_address, subject: "You're invited to the Denver Critical Mass handbook"
  end
end
