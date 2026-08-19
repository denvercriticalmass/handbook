require "rails_helper"

RSpec.describe "Cheat sheets" do
  it "lists them without an account" do
    create(:cheat_sheet, title: "Radio channels")

    get cheat_sheets_path

    expect(response.body).to include("Radio channels")
  end

  it "shows one without an account" do
    cheat_sheet = create(:cheat_sheet, title: "Radio channels")

    get cheat_sheet_path(cheat_sheet)

    expect(response.body).to include("Radio channels")
  end

  it "renders the formatting an admin wrote" do
    cheat_sheet = create(:cheat_sheet, body: "<div>Channel <strong>1</strong></div>")

    get cheat_sheet_path(cheat_sheet)

    expect(response.body).to include("<strong>1</strong>")
  end

  it "keeps the author to itself" do
    cheat_sheet = create(:cheat_sheet, created_by: create(:user, email_address: "corker@example.com"))

    get cheat_sheet_path(cheat_sheet)

    expect(response.body).not_to include("corker@example.com")
  end

  it "carries no trace of the admin UI" do
    create(:cheat_sheet)

    get cheat_sheets_path

    expect(response.body).not_to match(/signin|signout|admin/i)
  end
end
