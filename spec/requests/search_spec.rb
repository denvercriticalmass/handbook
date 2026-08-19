require "rails_helper"

RSpec.describe "Search" do
  it "finds a guide and a cheat sheet at once" do
    create(:guide, title: "Corking a junction")
    create(:cheat_sheet, title: "Corking hand signals")

    get search_path, params: { q: "corking" }

    expect(response.body).to include("Corking a junction", "Corking hand signals")
  end

  it "leaves out what doesn't match" do
    create(:guide, title: "Radio channels")

    get search_path, params: { q: "corking" }

    expect(response.body).not_to include("Radio channels")
  end

  it "finds a word in a body" do
    create(:guide, title: "Corking", body: "<div>Stand where drivers can see you</div>")

    get search_path, params: { q: "drivers" }

    expect(response.body).to include("Corking")
  end

  it "survives a term made of query syntax" do
    get search_path, params: { q: %(corking' OR 1=1; -- %&|!:*) }

    expect(response).to have_http_status(:ok)
  end

  it "asks for a term when there isn't one" do
    get search_path

    expect(response).to have_http_status(:ok)
  end

  it "carries no trace of the admin UI" do
    get search_path, params: { q: "corking" }

    expect(response.body).not_to match(/signin|signout|session/i)
  end
end
