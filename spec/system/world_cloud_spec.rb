require "system_helper"

RSpec.describe "The world cloud" do
  before { visit worldwide_path }

  def continents
    all(".world-bubble").map { it["data-continent"] }
  end

  it "fills every position a phone has room for" do
    expect(page).to have_css(".world-bubble", count: 12)
  end

  it "spreads them over the continents" do
    expect(continents.uniq.size).to be > 1
  end

  it "shows no continent more than three times" do
    expect(continents.tally.values.max).to be <= 3
  end

  it "names each city once" do
    names = all(".world-bubble").map(&:text)

    expect(names.uniq.size).to eq(names.size)
  end

  it "stays out of the accessibility tree" do
    expect(page).to have_css("[data-controller='world-cloud'][aria-hidden='true']", visible: :all)
  end
end
