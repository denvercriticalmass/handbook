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

  it "offers the button once a client id is configured" do
    ClimateControl.modify(GOOGLE_CLIENT_ID: "handbook.apps.googleusercontent.com") do
      get "/signin"
    end

    expect(response.body).to include("Continue with Google")
  end

  it "hides the button when no client id is configured" do
    ClimateControl.modify(GOOGLE_CLIENT_ID: nil) { get "/signin" }

    expect(response.body).not_to include("Continue with Google")
  end
end
