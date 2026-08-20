require "rails_helper"

RSpec.describe User do
  it "is an admin unless told otherwise" do
    expect(build(:user).role).to eq("admin")
  end

  it "never makes a superadmin by accident" do
    expect(build(:user)).not_to be_superadmin
  end

  it "can be a superadmin" do
    expect(build(:user, :superadmin)).to be_superadmin
  end

  it "is active unless suspended" do
    expect(build(:user)).to be_active
  end

  it "can be suspended" do
    expect(build(:user, :suspended)).not_to be_active
  end

  it "throws out a suspended admin who is already signed in" do
    user = create(:user)
    user.sessions.create!

    expect { user.update!(active: false) }.to change { user.sessions.count }.to(0)
  end

  it "needs a name" do
    expect(build(:user, name: "")).not_to be_valid
  end

  # A blank one would match the address an unverified Google account returns.
  it "needs an email address" do
    expect(build(:user, email_address: "")).not_to be_valid
  end

  # Without this Registration raises RecordNotUnique instead of refusing.
  it "needs an unclaimed email address" do
    taken = create(:user).email_address

    expect(build(:user, email_address: taken)).not_to be_valid
  end

  it "refuses a destroy while it has authored content" do
    user = create(:user)
    create(:guide, created_by: user)

    expect(user.destroy).to be(false)
  end

  it "leaves sessions alone on an unrelated update" do
    user = create(:user)
    user.sessions.create!

    expect { user.update!(email_address: "moved@example.com") }.not_to change { user.sessions.count }
  end

  describe "the passkey handle" do
    it "is generated on demand" do
      expect(create(:user).passkey_handle).to be_present
    end

    it "never changes once generated" do
      user = create(:user)

      expect(user.passkey_handle).to eq(user.reload.passkey_handle)
    end

    it "differs between accounts" do
      expect(create(:user).passkey_handle).not_to eq(create(:user).passkey_handle)
    end
  end
end
