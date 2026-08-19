require "rails_helper"

RSpec.describe Guide do
  it "needs a title" do
    expect(build(:guide, title: "")).not_to be_valid
  end

  it "is valid with a title" do
    expect(build(:guide)).to be_valid
  end

  it "keeps its body as rich text" do
    expect(build(:guide, body: "<div>Stand <strong>here</strong></div>").body.to_plain_text).to eq("Stand here")
  end

  it "knows who wrote it" do
    expect(build(:guide).created_by).to be_a(User)
  end
end
