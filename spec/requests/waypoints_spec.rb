require "rails_helper"

RSpec.describe "Waypoints" do
  it "lists them without an account" do
    create(:waypoint, name: "Speer and 5th")

    get waypoints_path

    expect(response.body).to include("Speer and 5th")
  end

  it "groups them under their category" do
    create(:waypoint, category: :hazard, name: "Cracked gutter")

    get waypoints_path

    expect(response.body).to include("Hazard")
  end

  it "narrows to one category" do
    create(:waypoint, category: :hazard, name: "Cracked gutter")
    create(:waypoint, category: :party_stop, name: "The park")

    get waypoints_path(category: "hazard")

    expect(response.body).not_to include("The park")
  end

  it "ignores a category nobody has" do
    create(:waypoint, name: "Speer and 5th")

    get waypoints_path(category: "nonsense")

    expect(response.body).to include("Speer and 5th")
  end

  it "shows one at its slug" do
    waypoint = create(:waypoint, name: "Speer and 5th", note: "Wait for the light.")

    get waypoint_path(waypoint)

    expect(response.body).to include("Wait for the light.")
  end

  it "hands the coordinates to a map" do
    waypoint = create(:waypoint, latitude: 39.7364, longitude: -104.9931)

    get waypoint_path(waypoint)

    expect(response.body).to include("openstreetmap.org")
  end

  it "leaves out the map link when there are no coordinates" do
    waypoint = create(:waypoint, latitude: nil, longitude: nil)

    get waypoint_path(waypoint)

    expect(response.body).not_to include("openstreetmap.org")
  end

  it "carries no trace of the admin UI" do
    create(:waypoint)

    get waypoints_path

    expect(response.body).not_to match(/signin|signout|session/i)
  end
end
