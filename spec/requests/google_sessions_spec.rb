require "rails_helper"

RSpec.describe "Signing in with Google" do
  let(:email) { "corker@example.com" }

  around do |example|
    OmniAuth.config.test_mode = true
    example.run
    OmniAuth.config.mock_auth[:google_oauth2] = nil
    OmniAuth.config.test_mode = false
  end

  # The strategy returns a blank email when Google has not verified it.
  def google_returns(email)
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "108412345678901234567",
      info: { email:, name: "Corker" }
    )
  end

  def sign_in_with_google
    post "/auth/google_oauth2"
    follow_redirect! while response.redirect? && response.location.include?("/auth/")
  end

  it "signs in the admin whose address matches" do
    user = create(:user, email_address: email)
    google_returns(email)

    sign_in_with_google

    expect(user.sessions.count).to eq(1)
  end

  it "lands them where they can work" do
    create(:user, email_address: email)
    google_returns(email)

    sign_in_with_google

    expect(response).to redirect_to(admin_root_url)
  end

  it "matches an address Google returns in a different case" do
    user = create(:user, email_address: email)
    google_returns("Corker@Example.com")

    sign_in_with_google

    expect(user.sessions.count).to eq(1)
  end

  it "refuses an address with no account" do
    google_returns("stranger@example.com")

    sign_in_with_google

    expect(Session.count).to eq(0)
  end

  it "refuses a suspended admin" do
    user = create(:user, :suspended, email_address: email)
    google_returns(email)

    sign_in_with_google

    expect(user.sessions.count).to eq(0)
  end

  it "refuses an unverified address" do
    create(:user, email_address: email)
    google_returns(nil)

    sign_in_with_google

    expect(Session.count).to eq(0)
  end

  it "refuses when the provider reports a failure" do
    OmniAuth.config.mock_auth[:google_oauth2] = :access_denied

    sign_in_with_google

    expect(Session.count).to eq(0)
  end

  it "sends anyone refused back to sign in" do
    google_returns("stranger@example.com")

    sign_in_with_google

    expect(response).to redirect_to(new_session_path)
  end

  # CI has no master key, so neither example can rely on the real credentials.
  def configured_client_id(id)
    allow(Rails.application.credentials).to receive(:dig).with(:google, :client_id).and_return(id)
  end

  it "offers the button once a client id is configured" do
    configured_client_id("handbook.apps.googleusercontent.com")

    get "/signin"

    expect(response.body).to include("Continue with Google")
  end

  it "hides the button when no client id is configured" do
    configured_client_id(nil)

    get "/signin"

    expect(response.body).not_to include("Continue with Google")
  end

  it "carries the invitation token on the signup button" do
    configured_client_id("handbook.apps.googleusercontent.com")
    invitation = create(:invitation)

    get "/signup", params: { token: invitation.token }

    expect(response.body).to include("/auth/google_oauth2?token=#{invitation.token}")
  end

  describe "accepting an invitation" do
    # let!/before so both exist before any expectation block measures a count.
    let!(:invitation) { create(:invitation, email_address: email) }

    before { create(:user, email_address: "founder@example.com") }

    def accept_with_google(token: invitation.token, address: email)
      google_returns(address)
      post "/auth/google_oauth2?#{ { token: }.to_query }"
      follow_redirect! while response.redirect? && response.location.include?("/auth/")
    end

    it "creates the invited admin" do
      expect { accept_with_google }.to change(User, :count).by(1)
    end

    it "signs them straight in" do
      accept_with_google

      expect(Session.count).to eq(1)
    end

    it "spends the invitation" do
      accept_with_google

      expect(invitation.reload).to be_accepted
    end

    it "grants admin, never superadmin" do
      accept_with_google

      expect(User.find_by(email_address: email)).to be_admin
    end

    it "refuses a token issued to another address" do
      expect { accept_with_google(address: "someone.else@example.com") }
        .not_to change(User, :count)
    end

    it "refuses a Google account carrying no token" do
      expect { accept_with_google(token: nil) }.not_to change(User, :count)
    end

    it "refuses an expired invitation" do
      invitation.update!(expires_at: 1.day.ago)

      expect { accept_with_google }.not_to change(User, :count)
    end
  end

  describe "founding the first account" do
    around do |example|
      ClimateControl.modify(SUPERADMIN_EMAIL: email) { example.run }
    end

    def sign_in_as_founder(address: email)
      google_returns(address)
      post "/auth/google_oauth2"
      follow_redirect! while response.redirect? && response.location.include?("/auth/")
    end

    it "makes the founder a superadmin" do
      sign_in_as_founder

      expect(User.find_by(email_address: email)).to be_superadmin
    end

    it "turns away any other address" do
      expect { sign_in_as_founder(address: "stranger@example.com") }
        .not_to change(User, :count)
    end
  end
end
