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
end
