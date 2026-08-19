require "rails_helper"

RSpec.describe Search do
  it "finds nothing without a term" do
    create(:guide)

    expect(described_class.new("  ").guides).to be_empty
  end

  it "reports that something matched" do
    create(:cheat_sheet, title: "Radio channels")

    expect(described_class.new("radio")).to be_any
  end

  it "reports that nothing matched" do
    create(:cheat_sheet, title: "Radio channels")

    expect(described_class.new("corking")).not_to be_any
  end
end
