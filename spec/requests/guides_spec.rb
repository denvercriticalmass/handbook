require "rails_helper"

RSpec.describe "Guides" do
  it "lists guides without an account" do
    create(:guide, title: "Corking a junction")

    get guides_path

    expect(response.body).to include("Corking a junction")
  end

  it "shows one without an account" do
    guide = create(:guide, title: "Corking a junction")

    get guide_path(guide)

    expect(response.body).to include("Corking a junction")
  end

  it "renders the formatting an admin wrote" do
    guide = create(:guide, body: "<div>Stand <strong>here</strong></div>")

    get guide_path(guide)

    expect(response.body).to include("<strong>here</strong>")
  end

  it "strips a script tag out of a body" do
    guide = create(:guide, body: "<div>ok</div><script>alert(1)</script>")

    get guide_path(guide)

    expect(response.body).not_to include("<script>")
  end

  it "keeps the author to itself" do
    guide = create(:guide, created_by: create(:user, email_address: "corker@example.com"))

    get guide_path(guide)

    expect(response.body).not_to include("corker@example.com")
  end

  it "carries no trace of the admin UI" do
    create(:guide)

    get guides_path

    expect(response.body).not_to match(/signin|signout|admin/i)
  end
end
