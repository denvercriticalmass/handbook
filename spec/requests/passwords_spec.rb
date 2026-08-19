require "rails_helper"

RSpec.describe "Password resets" do
  let(:user) { create(:user, email_address: "corker@example.com") }

  describe "asking for a reset" do
    it "serves the form" do
      get new_password_path

      expect(response).to have_http_status(:ok)
    end

    it "emails a known address" do
      expect { post passwords_path, params: { email_address: user.email_address } }
        .to have_enqueued_mail(PasswordsMailer, :reset)
    end

    it "emails nobody for an unknown address" do
      expect { post passwords_path, params: { email_address: "nobody@example.com" } }
        .not_to have_enqueued_mail(PasswordsMailer, :reset)
    end

    # Same response either way, so the form can't be used to discover which
    # addresses have accounts.
    it "answers an unknown address exactly as it answers a known one" do
      post passwords_path, params: { email_address: user.email_address }
      known = [ response.status, flash[:notice] ]

      post passwords_path, params: { email_address: "nobody@example.com" }

      expect([ response.status, flash[:notice] ]).to eq(known)
    end
  end

  describe "following the link" do
    it "serves the form for a good token" do
      get edit_password_path(user.password_reset_token)

      expect(response).to have_http_status(:ok)
    end

    it "turns away a bad token" do
      get edit_password_path("not-a-token")

      expect(response).to redirect_to(new_password_path)
    end

    it "changes the password when both fields match" do
      patch password_path(user.password_reset_token),
        params: { password: "a whole new password", password_confirmation: "a whole new password" }

      expect(user.reload.authenticate("a whole new password")).to be_truthy
    end

    it "signs out everywhere once the password changes" do
      user.sessions.create!

      expect {
        patch password_path(user.password_reset_token),
          params: { password: "a whole new password", password_confirmation: "a whole new password" }
      }.to change { user.sessions.count }.to(0)
    end

    it "refuses when the fields disagree" do
      patch password_path(user.password_reset_token),
        params: { password: "one thing", password_confirmation: "another thing" }

      expect(user.reload.authenticate("one thing")).to be_falsey
    end
  end
end
