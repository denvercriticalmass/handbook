require "rails_helper"

RSpec.describe Guide do
  it "needs a title" do
    expect(build(:guide, title: "")).not_to be_valid
  end

  it "is valid with a title" do
    expect(build(:guide)).to be_valid
  end

  it "knows who wrote it" do
    expect(build(:guide).created_by).to be_a(User)
  end
end
