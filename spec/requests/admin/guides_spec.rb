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
