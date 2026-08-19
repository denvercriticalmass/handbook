require "rails_helper"

# These all hinge on User.count, so they deliberately share no factory setup
# with the other auth specs. A stray create(:user) in a shared hook would make
# them pass for the wrong reason.
RSpec.describe "Registration" do
  let(:founder) { "joe@joesak.com" }

  def register(email_address, superadmin_email: nil)
    ClimateControl.modify(SUPERADMIN_EMAIL: superadmin_email) do
      post signup_path, params: { email_address:, password: "bike lanes now" }
    end
  end

  describe "the first account ever" do
    it "becomes superadmin when the email matches SUPERADMIN_EMAIL" do
      register(founder, superadmin_email: founder)

      expect(User.sole).to be_superadmin
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

    # Uses a different existing account on purpose. If the existing user held
    # the founder address, uniqueness would reject this and the spec would
    # pass without ever exercising the closed-registration rule.
    it "is turned away even when the email matches SUPERADMIN_EMAIL" do
      create(:user, email_address: "someone@example.com")

      register(founder, superadmin_email: founder)

      expect(User.count).to eq(1)
    end
  end
end
