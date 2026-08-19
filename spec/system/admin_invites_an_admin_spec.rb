require "system_helper"

RSpec.describe "Inviting an admin" do
  let(:password) { "bike lanes now" }

  def sign_in_as(user)
    visit "/signin"
    fill_in "Email address", with: user.email_address
    fill_in "Password", with: password
    click_on "Sign in"
  end

  it "sends an invitation from the admin screens" do
    sign_in_as create(:user, :superadmin, password:)

    visit "/admin/invitations/new"
    fill_in "Email address", with: "newcorker@example.com"
    click_on "Send invitation"

    expect(page).to have_content("Invited newcorker@example.com")
  end

  it "offers Suspend against an admin but not against a superadmin" do
    sign_in_as create(:user, :superadmin, email_address: "boss@example.com", password:)
    create(:user, email_address: "corker@example.com")

    visit "/admin/users"

    expect(page).to have_button("Suspend", count: 1)
  end
end
