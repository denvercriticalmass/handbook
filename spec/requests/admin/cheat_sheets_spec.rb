require "rails_helper"

RSpec.describe "Admin cheat sheets" do
  let(:admin) { create(:user) }

  def sign_in_as(user)
    post session_path, params: { email_address: user.email_address, password: "password" }
  end

  it "sends a visitor with no account to sign in" do
    get new_admin_cheat_sheet_path

    expect(response).to redirect_to(new_session_path)
  end

  it "is reachable from the admin nav" do
    sign_in_as admin

    get admin_root_path

    expect(response.body).to include(admin_cheat_sheets_path)
  end

  it "lets an admin write one" do
    sign_in_as admin

    expect { post admin_cheat_sheets_path, params: { cheat_sheet: { title: "Radios", body: "Channel 1." } } }
      .to change(CheatSheet, :count).by(1)
  end

  it "records the author" do
    sign_in_as admin

    post admin_cheat_sheets_path, params: { cheat_sheet: { title: "Radios", body: "Channel 1." } }

    expect(CheatSheet.sole.created_by).to eq(admin)
  end

  it "links each cheat sheet to its history" do
    cheat_sheet = create(:cheat_sheet)
    sign_in_as admin

    get admin_cheat_sheets_path

    expect(response.body).to include(history_admin_cheat_sheet_path(cheat_sheet))
  end

  it "shows who changed what" do
    cheat_sheet = create(:cheat_sheet, title: "Radioz")
    sign_in_as admin
    patch admin_cheat_sheet_path(cheat_sheet), params: { cheat_sheet: { title: "Radios" } }
    get history_admin_cheat_sheet_path(cheat_sheet)

    expect(response.body).to include("Title by #{admin.name}")
  end

  it "refuses one with no title" do
    sign_in_as admin

    expect { post admin_cheat_sheets_path, params: { cheat_sheet: { title: "", body: "Channel 1." } } }
      .not_to change(CheatSheet, :count)
  end

  it "lets an admin fix a typo" do
    cheat_sheet = create(:cheat_sheet, title: "Radioz")
    sign_in_as admin

    patch admin_cheat_sheet_path(cheat_sheet), params: { cheat_sheet: { title: "Radios" } }

    expect(cheat_sheet.reload.title).to eq("Radios")
  end
end
