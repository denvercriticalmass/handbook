require "rails_helper"

RSpec.describe "Session route aliases" do
  let(:password) { "bike lanes now" }
  let(:user) { create(:user, email_address: "corker@example.com", password: password) }

  def sign_in
    post session_path, params: { email_address: user.email_address, password: password }
  end

  describe "signing in" do
    it "serves the sign-in form at /signin" do
      get "/signin"

      expect(response).to have_http_status(:ok)
    end

    it "redirects /login to the canonical /signin" do
      get "/login"

      expect(response).to redirect_to("/signin")
    end
  end

  describe "signing out" do
    it "asks for confirmation at /signout" do
      sign_in

      get "/signout"

      expect(response).to have_http_status(:ok)
    end

    it "redirects /logout to the canonical /signout" do
      sign_in

      get "/logout"

      expect(response).to redirect_to("/signout")
    end

    it "sends an unauthenticated visitor to sign in" do
      get "/signout"

      expect(response).to redirect_to(new_session_path)
    end

    it "names the account being signed out of" do
      sign_in

      get "/signout"

      expect(response.body).to include(user.email_address)
    end

    it "offers a button that deletes the session" do
      sign_in

      get "/signout"

      expect(response.body).to include(%(method="post"))
    end
  end
end
