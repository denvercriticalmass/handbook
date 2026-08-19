require "rails_helper"

RSpec.describe CheatSheetPolicy do
  it "lets anyone read the list, signed in or not" do
    expect(described_class.new(nil, CheatSheet)).to be_index
  end

  it "lets anyone read one" do
    expect(described_class.new(nil, build(:cheat_sheet))).to be_show
  end

  it "keeps writing to admins" do
    expect(described_class.new(nil, CheatSheet)).not_to be_create
  end

  it "lets an admin write" do
    expect(described_class.new(build(:user), CheatSheet)).to be_create
  end
end
