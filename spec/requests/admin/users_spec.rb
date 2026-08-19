require "rails_helper"

RSpec.describe "Admin users" do
  let(:admin) { create(:user) }
  let(:superadmin) { create(:user, :superadmin) }

  def sign_in_as(user)
    post session_path, params: { email_address: user.email_address, password: "password" }
  end

  describe "the admin list" do
    it "is open to an admin" do
      sign_in_as admin

      get admin_users_path

      expect(response).to have_http_status(:ok)
    end

    it "offers an admin the invite form" do
      sign_in_as admin

      get admin_users_path

      expect(response.body).to include(new_admin_invitation_path)
    end

    it "hides the suspend control from an admin" do
      create(:user, name: "Corker Joe")
      sign_in_as admin

      get admin_users_path

      expect(response.body).not_to include("Suspend")
    end

    it "is open to the superadmin" do
      sign_in_as superadmin

      get admin_users_path

      expect(response).to have_http_status(:ok)
    end

    it "lists an invitation nobody has accepted" do
      create(:invitation, email_address: "corker@example.com")
      sign_in_as superadmin

      get admin_users_path

      expect(response.body).to include("corker@example.com")
    end

    it "leaves out an invitation already accepted" do
      create(:invitation, :accepted, email_address: "done@example.com")
      sign_in_as superadmin

      get admin_users_path

      expect(response.body).not_to include("done@example.com")
    end

    it "names each admin" do
      create(:user, name: "Corker Joe")
      sign_in_as superadmin

      get admin_users_path

      expect(response.body).to include("Corker Joe")
    end
  end

  describe "suspending" do
    it "tells a refused admin why, on the page it sends them to" do
      peer = create(:user)
      sign_in_as admin

      patch admin_user_path(peer), params: { active: false }
      follow_redirect!

      expect(Nokogiri::HTML(response.body).at("#alert").text).to eq("You can't do that.")
    end

    it "keeps a refused admin inside the admin screens" do
      peer = create(:user)
      sign_in_as admin

      patch admin_user_path(peer), params: { active: false }

      expect(response).to redirect_to(admin_root_path)
    end

    it "is refused to an admin acting on a peer" do
      peer = create(:user)
      sign_in_as admin

      expect { patch admin_user_path(peer), params: { active: false } }
        .not_to change { peer.reload.active }
    end

    it "is allowed to the superadmin" do
      sign_in_as superadmin

      expect { patch admin_user_path(admin), params: { active: false } }
        .to change { admin.reload.active }.to(false)
    end

    it "is refused even to a superadmin acting on another superadmin" do
      other = create(:user, :superadmin)
      sign_in_as superadmin

      expect { patch admin_user_path(other), params: { active: false } }
        .not_to change { other.reload.active }
    end
  end
end
