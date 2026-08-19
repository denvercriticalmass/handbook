require "rails_helper"

RSpec.describe CheatSheet do
  it "needs a title" do
    expect(build(:cheat_sheet, title: "")).not_to be_valid
  end

  it "is valid with a title" do
    expect(build(:cheat_sheet)).to be_valid
  end

  it "is found by a word in its title" do
    cheat_sheet = create(:cheat_sheet, title: "Radio channels")

    expect(described_class.search("radio")).to eq([ cheat_sheet ])
  end

  it "takes its slug from its title" do
    expect(create(:cheat_sheet, title: "Radio channels").slug).to eq("radio-channels")
  end

  it "knows who wrote it" do
    expect(build(:cheat_sheet).created_by).to be_a(User)
  end
end
