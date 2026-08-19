require "rails_helper"

RSpec.describe "Admin invitations" do
  let(:admin) { create(:user) }

  def sign_in_as(user)
    post session_path, params: { email_address: user.email_address, password: "password" }
  end

  it "sends a visitor with no account to sign in" do
    get new_admin_invitation_path

    expect(response).to redirect_to(new_session_path)
  end

  it "lets an admin open the invite form" do
    sign_in_as admin

    get new_admin_invitation_path

    expect(response).to have_http_status(:ok)
  end

  it "lets an admin invite another admin" do
    sign_in_as admin

    expect { post admin_invitations_path, params: { email_address: "new@example.com" } }
      .to change(Invitation, :count).by(1)
  end

  it "records who did the inviting" do
    sign_in_as admin

    post admin_invitations_path, params: { email_address: "new@example.com" }

    expect(Invitation.sole.invited_by).to eq(admin)
  end
end
