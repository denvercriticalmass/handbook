require "rails_helper"

RSpec.describe "Admin users" do
  let(:admin) { create(:user) }
  let(:superadmin) { create(:user, :superadmin) }

  def sign_in_as(user)
    post session_path, params: { email_address: user.email_address, password: "password" }
  end

  describe "the admin list" do
    it "is closed to an admin" do
      sign_in_as admin

      get admin_users_path

      expect(response).to redirect_to(root_path)
    end

    it "is open to the superadmin" do
      sign_in_as superadmin

      get admin_users_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "suspending" do
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
