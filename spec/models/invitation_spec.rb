require "rails_helper"

RSpec.describe Invitation do
  it "is usable when freshly created" do
    expect(build(:invitation)).to be_usable
  end

  it "is spent once accepted" do
    expect(build(:invitation, :accepted)).not_to be_usable
  end

  it "is spent once it expires" do
    expect(build(:invitation, :expired)).not_to be_usable
  end

  it "lasts a week by default" do
    expect(build(:invitation).expires_at).to be_within(1.minute).of(1.week.from_now)
  end

  it "carries a token so the link means something" do
    expect(create(:invitation).token).to be_present
  end

  it "gives every invitation its own token" do
    tokens = create_list(:invitation, 2).map(&:token)

    expect(tokens.uniq.length).to eq(2)
  end

  it "normalizes the address the way User does" do
    expect(build(:invitation, email_address: "  Corker@Example.COM ").email_address)
      .to eq("corker@example.com")
  end

  describe ".usable" do
    it "leaves out the accepted and the expired" do
      usable = create(:invitation)
      create(:invitation, :accepted)
      create(:invitation, :expired)

      expect(described_class.usable).to eq([ usable ])
    end
  end
end
