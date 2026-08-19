require "rails_helper"

RSpec.describe GuidePolicy do
  it "lets anyone read the list, signed in or not" do
    expect(described_class.new(nil, Guide)).to be_index
  end

  it "lets anyone read one" do
    expect(described_class.new(nil, build(:guide))).to be_show
  end

  it "keeps writing to admins" do
    expect(described_class.new(nil, Guide)).not_to be_create
  end

  it "lets an admin write" do
    expect(described_class.new(build(:user), Guide)).to be_create
  end
end
