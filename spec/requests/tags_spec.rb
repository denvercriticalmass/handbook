require "rails_helper"

RSpec.describe "A tag" do
  it "lists a guide and a cheat sheet under the same tag" do
    create(:guide, title: "Corking a junction", tag_list: "corking")
    create(:cheat_sheet, title: "Corking hand signals", tag_list: "corking")

    get tag_path("corking")

    expect(response.body).to include("Corking a junction", "Corking hand signals")
  end

  it "leaves out what carries another tag" do
    create(:guide, title: "Radio channels", tag_list: "radios")

    get tag_path("corking")

    expect(response.body).not_to include("Radio channels")
  end

  it "says so when a tag has nothing on it" do
    get tag_path("nothing-here")

    expect(response).to have_http_status(:ok)
  end

  it "handles a tag with a dot in it" do
    create(:guide, title: "Channel eight", tag_list: "channel 8.5")

    get tag_path("channel 8.5")

    expect(response.body).to include("Channel eight")
  end
end
