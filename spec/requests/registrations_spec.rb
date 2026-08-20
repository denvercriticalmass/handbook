require "rails_helper"

RSpec.describe "Registration" do
  let(:founder) { "joe@joesak.com" }

  def register(email_address, superadmin_email: nil, token: nil, name: "Joe")
    ClimateControl.modify(SUPERADMIN_EMAIL: superadmin_email) do
      post signup_path, params: { email_address:, token:, name:, password: "bike lanes now" }
    end
  end

  describe "the first account ever" do
    it "becomes superadmin when the email matches SUPERADMIN_EMAIL" do
      register(founder, superadmin_email: founder)

      expect(User.sole).to be_superadmin
    end

    it "keeps the name it registered under" do
      register(founder, superadmin_email: founder, name: "Joe Sak")

      expect(User.sole.name).to eq("Joe Sak")
    end

    it "matches the email regardless of case" do
      register("JOE@JoeSak.com", superadmin_email: founder)

      expect(User.count).to eq(1)
    end

    it "is turned away when the email does not match" do
      register("someone@else.example", superadmin_email: founder)

      expect(User.count).to eq(0)
    end

    it "is turned away when SUPERADMIN_EMAIL is unset, rather than letting anyone claim it" do
      register(founder, superadmin_email: nil)

      expect(User.count).to eq(0)
    end
  end

  describe "any account after the first" do
    it "is turned away without an invitation" do
      create(:user, :superadmin, email_address: founder)

      register("second@example.com", superadmin_email: founder)

      expect(User.count).to eq(1)
    end

    # A founder-address user here would trip uniqueness, not the closed rule.
    it "is turned away even when the email matches SUPERADMIN_EMAIL" do
      create(:user, email_address: "someone@example.com")

      register(founder, superadmin_email: founder)

      expect(User.count).to eq(1)
    end
  end

  describe "with an invitation" do
    # Both are let!/before so the records exist before any expectation block
    # measures User.count. Creating them inside the block counts the setup.
    let!(:invitation) { create(:invitation, email_address: "corker@example.com") }

    before { create(:user, email_address: "founder@example.com") }

    def accept(email_address: invitation.email_address, token: invitation.token)
      register(email_address, token:)
    end

    it "lets the invited address through" do
      expect { accept }.to change(User, :count).by(1)
    end

    it "grants admin, never superadmin" do
      accept

      expect(User.find_by(email_address: invitation.email_address)).to be_admin
    end

    it "spends the invitation" do
      accept

      expect(invitation.reload).to be_accepted
    end

    it "refuses an address that already has an account" do
      create(:user, email_address: invitation.email_address)

      expect { accept }.not_to change(User, :count)
    end

    it "refuses a second use of the same token" do
      accept

      expect { register(invitation.email_address, token: invitation.token) }
        .not_to change(User, :count)
    end

    it "refuses an expired invitation" do
      invitation.update!(expires_at: 1.day.ago)

      expect { accept }.not_to change(User, :count)
    end

    it "refuses a token that belongs to a different address" do
      expect { accept(email_address: "someone@else.example") }.not_to change(User, :count)
    end

    it "refuses a made-up token" do
      expect { accept(token: "not-a-real-token") }.not_to change(User, :count)
    end
  end

  describe "the signup page" do
    it "greets an invited admin as invited" do
      get "/signup", params: { token: create(:invitation).token }

      expect(response.body).to include("Accept your invitation")
    end

    it "greets the founder as the first account" do
      get "/signup"

      expect(response.body).to include("Create the first account")
    end
  end
end
