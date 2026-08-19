require "rails_helper"

RSpec.describe UserPolicy do
  let(:admin) { build(:user) }
  let(:superadmin) { build(:user, :superadmin) }

  describe "#manage?" do
    it "lets a superadmin manage an admin" do
      expect(described_class.new(superadmin, admin)).to be_manage
    end

    it "stops a superadmin managing another superadmin" do
      expect(described_class.new(superadmin, build(:user, :superadmin))).not_to be_manage
    end

    it "stops an admin managing a peer" do
      expect(described_class.new(admin, build(:user))).not_to be_manage
    end

    it "stops an admin managing themselves" do
      expect(described_class.new(admin, admin)).not_to be_manage
    end
  end

  describe "#index?" do
    it "is open to the superadmin" do
      expect(described_class.new(superadmin, User)).to be_index
    end

    it "is open to an admin, who can invite but not manage" do
      expect(described_class.new(admin, User)).to be_index
    end

    it "is closed to a visitor" do
      expect(described_class.new(nil, User)).not_to be_index
    end
  end
end
