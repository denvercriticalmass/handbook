require "rails_helper"

RSpec.describe CheatSheet do
  it "needs a title" do
    expect(build(:cheat_sheet, title: "")).not_to be_valid
  end

  it "is valid with a title" do
    expect(build(:cheat_sheet)).to be_valid
  end

  it "knows who wrote it" do
    expect(build(:cheat_sheet).created_by).to be_a(User)
  end
end
