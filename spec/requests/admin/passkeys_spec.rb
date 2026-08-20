require "rails_helper"
require "webauthn/fake_client"

RSpec.describe "Enrolling a passkey" do
  let(:password) { "bike lanes now" }
  let(:user) { create(:user, password:) }
  let(:client) { WebAuthn::FakeClient.new("http://localhost:3000") }

  before { post "/session", params: { email_address: user.email_address, password: } }

  def issued_challenge
    post "/admin/passkey_challenge"

    response.parsed_body["challenge"]
  end

  def enroll(nickname: "Work phone", challenge: issued_challenge)
    post "/admin/passkeys", params: { nickname:, credential: client.create(challenge:, user_verified: true).to_json }
  end

  it "stores the passkey" do
    expect { enroll }.to change(Passkey, :count).by(1)
  end

  it "keeps the name it was given" do
    enroll(nickname: "Yubikey")

    expect(Passkey.last.nickname).to eq("Yubikey")
  end

  it "attaches it to the signed-in admin" do
    enroll

    expect(Passkey.last.user).to eq(user)
  end

  it "records the credential id the authenticator returned" do
    enroll

    expect(Passkey.last.external_id).to be_present
  end

  it "refuses a credential answering a different challenge" do
    issued_challenge

    expect { enroll(challenge: WebAuthn.configuration.encoder.encode(SecureRandom.random_bytes(32))) }
      .not_to change(Passkey, :count)
  end

  # Asserting the redirect, since a 500 would satisfy an unchanged count too.
  it "refuses a credential with no challenge on the session without blowing up" do
    enroll(challenge: WebAuthn.configuration.encoder.encode(SecureRandom.random_bytes(32)))

    expect(response).to redirect_to(admin_account_path)
  end

  it "refuses a passkey with no name" do
    expect { enroll(nickname: "") }.not_to change(Passkey, :count)
  end

  it "refuses nonsense in place of a credential" do
    post "/admin/passkeys", params: { nickname: "Phone", credential: "not json" }

    expect(response).to redirect_to(admin_account_path)
  end

  it "lists the ones already enrolled" do
    passkey = create(:passkey, user:, nickname: "Yubikey")

    get "/admin"

    expect(response.body).to include(passkey.nickname)
  end

  describe "removing one" do
    it "removes my own" do
      passkey = create(:passkey, user:)

      expect { delete "/admin/passkeys/#{passkey.id}" }.to change(Passkey, :count).by(-1)
    end

    it "leaves someone else's alone" do
      passkey = create(:passkey)

      expect { delete "/admin/passkeys/#{passkey.id}" }.not_to change(Passkey, :count)
    end
  end
end
