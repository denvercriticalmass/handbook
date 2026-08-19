require "rails_helper"

RSpec.describe "Admin guides" do
  let(:admin) { create(:user) }

  def sign_in_as(user)
    post session_path, params: { email_address: user.email_address, password: "password" }
  end

  it "sends a visitor with no account to sign in" do
    get new_admin_guide_path

    expect(response).to redirect_to(new_session_path)
  end

  it "is reachable from the admin nav" do
    sign_in_as admin

    get admin_root_path

    expect(response.body).to include(admin_guides_path)
  end

  it "lets an admin write one" do
    sign_in_as admin

    expect { post admin_guides_path, params: { guide: { title: "Corking", body: "Stand here." } } }
      .to change(Guide, :count).by(1)
  end

  it "records the author" do
    sign_in_as admin

    post admin_guides_path, params: { guide: { title: "Corking", body: "Stand here." } }

    expect(Guide.sole.created_by).to eq(admin)
  end

  it "stores the body as rich text" do
    sign_in_as admin

    post admin_guides_path, params: { guide: { title: "Corking", body: "<div>Stand here.</div>" } }

    expect(Guide.sole.body.to_plain_text).to eq("Stand here.")
  end

  it "links each guide to its history" do
    guide = create(:guide)
    sign_in_as admin

    get admin_guides_path

    expect(response.body).to include(history_admin_guide_path(guide))
  end

  it "shows who changed what" do
    guide = create(:guide, title: "Korking")
    sign_in_as admin
    patch admin_guide_path(guide), params: { guide: { title: "Corking" } }
    get history_admin_guide_path(guide)

    expect(response.body).to include("Title by #{admin.name}")
  end

  it "keeps the history behind sign in" do
    guide = create(:guide)

    get history_admin_guide_path(guide)

    expect(response).to redirect_to(new_session_path)
  end

  it "stops a suspended admin who is still holding a session" do
    guide = create(:guide, title: "Korking")
    sign_in_as admin
    admin.update_column(:active, false)

    patch admin_guide_path(guide), params: { guide: { title: "Corking" } }

    expect(guide.reload.title).to eq("Korking")
  end

  it "records who made an edit" do
    guide = create(:guide, title: "Korking")
    sign_in_as admin

    patch admin_guide_path(guide), params: { guide: { title: "Corking" } }

    expect(guide.versions.last.whodunnit).to eq(admin.id)
  end

  it "refuses one with no title" do
    sign_in_as admin

    expect { post admin_guides_path, params: { guide: { title: "", body: "Stand here." } } }
      .not_to change(Guide, :count)
  end

  it "lets an admin fix a typo" do
    guide = create(:guide, title: "Korking")
    sign_in_as admin

    patch admin_guide_path(guide), params: { guide: { title: "Corking" } }

    expect(guide.reload.title).to eq("Corking")
  end
end
