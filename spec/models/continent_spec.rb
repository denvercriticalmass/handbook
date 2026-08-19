require "rails_helper"

RSpec.describe Continent do
  subject(:continents) { described_class.all }

  def city(name)
    continents.flat_map(&:cities).find { it.name == name }
  end

  it "leads with the continent Denver rides on" do
    expect(continents.first.name).to eq("North America")
  end

  it "names all six" do
    expect(continents.map(&:name)).to eq([ "North America", "South America", "Europe", "Africa", "Asia", "Oceania" ])
  end

  it "slugs its name, so the stylesheet can colour its cities" do
    expect(continents.first.slug).to eq("north-america")
  end

  it "picks out the cities running a ride page of their own" do
    expect(continents.last.linked_cities.map(&:name)).to eq([ "Melbourne" ])
  end

  it "carries a city's own ride page" do
    expect(city("San Francisco").url).to eq("https://sfcriticalmass.com/")
  end

  it "leaves a city without a page unlinked" do
    expect(city("Denver").url).to be_nil
  end
end
