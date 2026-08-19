require "rails_helper"

RSpec.describe "Worldwide" do
  before { get worldwide_path }

  it "is reachable without signing in" do
    expect(response).to have_http_status(:ok)
  end

  it "names every continent" do
    expect(response.body).to include("North America", "South America", "Europe", "Africa", "Asia", "Oceania")
  end

  it "links a city that runs its own ride page" do
    expect(response.body).to include("https://criticalmass.melbourne/")
  end

  it "hands the whole city list to the cloud" do
    expect(response.body).to include("Kathmandu")
  end

  it "carries no trace of the admin UI" do
    expect(response.body).not_to match(/signin|signout|session/i)
  end
end
