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

  it "does not be destroyed out from under what it wrote" do
    user = create(:user)
    create(:guide, created_by: user)

    expect(user.destroy).to be(false)
  end

  it "leaves sessions alone on an unrelated update" do
    user = create(:user)
    user.sessions.create!

    expect { user.update!(email_address: "moved@example.com") }.not_to change { user.sessions.count }
  end
end
