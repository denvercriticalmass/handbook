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

  def guide_with_an_attached_image
    blob = ActiveStorage::Blob.create_and_upload!(
      io: Rails.root.join("spec/fixtures/files/dot.png").open,
      filename: "dot.png",
      content_type: "image/png"
    )

    create(:guide, body: %(<action-text-attachment sgid="#{blob.attachable_sgid}"></action-text-attachment>))
  end

  it "serves an image attached to a body" do
    get guide_path(guide_with_an_attached_image)
    get Nokogiri::HTML(response.body).at("img")["src"]
    follow_redirect! while response.redirect?

    expect(response).to have_http_status(:ok)
  end

  it "lives at its slug" do
    guide = create(:guide, title: "Corking a junction")

    get guide_path(guide)

    expect(request.path).to eq("/guides/corking-a-junction")
  end

  it "still answers to an id, so an old link holds" do
    guide = create(:guide, title: "Corking a junction")

    get "/guides/#{guide.id}"

    expect(response).to have_http_status(:ok)
  end

  it "links its tags" do
    guide = create(:guide, tag_list: "corking")

    get guide_path(guide)

    expect(response.body).to include(tag_path("corking"))
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
