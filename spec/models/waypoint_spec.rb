require "rails_helper"

RSpec.describe Waypoint do
  it "needs a name" do
    expect(build(:waypoint, name: "")).not_to be_valid
  end

  it "takes its slug from its name" do
    expect(create(:waypoint, name: "Speer and 5th").slug).to eq("speer-and-5th")
  end

  it "is a crossing unless told otherwise" do
    expect(described_class.new).to be_crossing
  end

  it "knows it has somewhere to point at" do
    expect(build(:waypoint)).to be_located
  end

  it "knows when it has no coordinates" do
    expect(build(:waypoint, latitude: nil, longitude: nil)).not_to be_located
  end

  it "refuses a latitude off the globe" do
    expect(build(:waypoint, latitude: 91)).not_to be_valid
  end

  it "takes a spot with no coordinates yet" do
    expect(build(:waypoint, latitude: nil, longitude: nil)).to be_valid
  end

  it "keeps a version of every edit" do
    waypoint = create(:waypoint, name: "Speer")

    expect { waypoint.update!(name: "Speer and 5th") }.to change { waypoint.versions.count }.by(1)
  end
end
