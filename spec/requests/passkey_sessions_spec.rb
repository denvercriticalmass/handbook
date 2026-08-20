require "rails_helper"
require "webauthn/fake_client"

RSpec.describe "Signing in with a passkey" do
  let(:password) { "bike lanes now" }
  let(:user) { create(:user, password:) }
  let(:client) { WebAuthn::FakeClient.new("http://localhost:3000") }

  # The same fake authenticator has to enroll the credential before it can
  # present one, so every example starts by adding a passkey for real.
  def enroll
    post "/session", params: { email_address: user.email_address, password: }
    post "/admin/passkey_challenge"
    attestation = client.create(challenge: response.parsed_body["challenge"], user_verified: true)
    post "/admin/passkeys", params: { nickname: "Phone", credential: attestation.to_json }
    delete "/session"
  end

  def sign_in_with_passkey(challenge: nil, user_verified: true, sign_count: nil)
    post "/passkey_challenge"
    challenge ||= response.parsed_body["challenge"]
    assertion = client.get(challenge:, user_verified:, sign_count:)

    post "/passkey_session", params: { credential: assertion.to_json }
  end

  before { enroll }

  it "starts a session" do
    expect { sign_in_with_passkey }.to change(Session, :count).by(1)
  end

  it "signs in the account the passkey belongs to" do
    sign_in_with_passkey

    expect(user.sessions.count).to eq(1)
  end

  it "lands them where they can work" do
    sign_in_with_passkey

    expect(response).to redirect_to(admin_root_url)
  end

  it "records when the passkey was last used" do
    sign_in_with_passkey

    expect(Passkey.last.last_used_at).to be_present
  end

  it "advances the signature counter" do
    sign_in_with_passkey

    expect(Passkey.last.sign_count).to be_positive
  end

  it "refuses an assertion answering a different challenge" do
    expect { sign_in_with_passkey(challenge: WebAuthn.configuration.encoder.encode(SecureRandom.random_bytes(32))) }
      .not_to change(Session, :count)
  end

  it "refuses a suspended admin" do
    user.update!(active: false)

    expect { sign_in_with_passkey }.not_to change(Session, :count)
  end

  it "refuses a credential nobody enrolled" do
    Passkey.delete_all

    expect { sign_in_with_passkey }.not_to change(Session, :count)
  end

  # WebAuthn only enforces this if verify is told to, so a stolen unlocked
  # device would otherwise be enough.
  it "refuses an assertion the authenticator never verified" do
    expect { sign_in_with_passkey(user_verified: false) }.not_to change(Session, :count)
  end

  it "refuses a signature counter that went backwards" do
    Passkey.last.update!(sign_count: 99)

    expect { sign_in_with_passkey(sign_count: 2) }.not_to change(Session, :count)
  end

  it "refuses nonsense in place of an assertion" do
    post "/passkey_session", params: { credential: "not json" }

    expect(response).to redirect_to(new_session_path)
  end

  it "offers the button on the sign-in page" do
    get "/signin"

    expect(response.body).to include("Sign in with a passkey")
  end
end
