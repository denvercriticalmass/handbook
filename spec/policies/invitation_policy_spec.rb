require "rails_helper"

RSpec.describe InvitationPolicy do
  describe "#create?" do
    it "lets an admin invite" do
      expect(described_class.new(build(:user), Invitation)).to be_create
    end

    it "lets a superadmin invite" do
      expect(described_class.new(build(:user, :superadmin), Invitation)).to be_create
    end

    it "stops a visitor with no account" do
      expect(described_class.new(nil, Invitation)).not_to be_create
    end
  end
end
