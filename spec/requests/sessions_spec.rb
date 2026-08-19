require "rails_helper"

RSpec.describe "Sessions" do
  let(:password) { "bike lanes now" }
  let(:user) { create(:user, email_address: "corker@example.com", password:) }

  def sign_in
    post session_path, params: { email_address: user.email_address, password: }
  end

  describe "POST /session" do
    it "signs in a user with the right password" do
      sign_in

      expect(response).to redirect_to(admin_root_path)
    end

    it "starts a session record for the user" do
      expect { sign_in }.to change { user.sessions.count }.by(1)
    end

    it "turns away a suspended admin holding the right password" do
      user.update!(active: false)

      sign_in

      expect(response).to redirect_to(new_session_path)
    end

    it "starts no session for a suspended admin" do
      user.update!(active: false)

      expect { sign_in }.not_to change { user.sessions.count }
    end

    it "turns away the wrong password" do
      post session_path, params: { email_address: user.email_address, password: "wrong" }

      expect(response).to redirect_to(new_session_path)
    end

    it "starts no session for the wrong password" do
      expect {
        post session_path, params: { email_address: user.email_address, password: "wrong" }
      }.not_to change { user.sessions.count }
    end
  end

  describe "DELETE /session" do
    it "signs the user out" do
      sign_in

      delete session_path

      expect(response).to redirect_to(new_session_path)
    end

    it "drops the session record" do
      sign_in

      expect { delete session_path }.to change { user.sessions.count }.by(-1)
    end
  end
end
