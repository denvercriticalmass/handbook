require "rails_helper"

RSpec.describe InvitationsMailer do
  subject(:mail) { described_class.invite(invitation) }

  let(:invitation) { create(:invitation, email_address: "corker@example.com") }

  it "goes to the person invited" do
    expect(mail.to).to eq([ "corker@example.com" ])
  end

  it "comes from the ride" do
    expect(mail.from).to eq([ "denvercriticalmass@gmail.com" ])
  end

  it "carries the link that accepts the invitation" do
    expect(mail.body.encoded).to include("/signup?token=#{invitation.token}")
  end

  it "says who did the inviting" do
    expect(mail.body.encoded).to include(invitation.invited_by.name)
  end
end
