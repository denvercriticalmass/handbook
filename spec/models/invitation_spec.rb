require "rails_helper"

RSpec.describe Invitation do
  describe ".outstanding" do
    it "leaves out the ones already accepted" do
      create(:invitation, :accepted)
      waiting = create(:invitation)

      expect(described_class.outstanding).to eq([ waiting ])
    end

    it "keeps an expired one, since it still needs clearing up" do
      expired = create(:invitation, :expired)

      expect(described_class.outstanding).to eq([ expired ])
    end
  end

  describe "#reissue" do
    it "pushes the expiry out a week" do
      invitation = create(:invitation, :expired)

      expect { invitation.reissue }.to change(invitation, :usable?).to(true)
    end

    it "keeps the token, so a link already sent still works" do
      invitation = create(:invitation)

      expect { invitation.reissue }.not_to change(invitation, :token)
    end
  end

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
