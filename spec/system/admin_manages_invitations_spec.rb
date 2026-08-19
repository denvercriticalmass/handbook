require "system_helper"

RSpec.describe "Managing invitations" do
  let(:password) { "bike lanes now" }

  def sign_in_as(user)
    visit "/signin"
    fill_in "Email address", with: user.email_address
    fill_in "Password", with: password
    click_on "Sign in"
  end

  it "revokes one after saying what that does" do
    create(:invitation, email_address: "corker@example.com")
    sign_in_as create(:user, :superadmin, password:)

    visit "/admin/users"
    accept_confirm(/Revoke the invitation for corker@example\.com/) { click_on "Revoke" }

    expect(page).to have_content("Revoked the invitation for corker@example.com")
  end

  it "keeps the invitation when the warning is dismissed" do
    create(:invitation, email_address: "corker@example.com")
    sign_in_as create(:user, :superadmin, password:)

    visit "/admin/users"
    dismiss_confirm { click_on "Revoke" }

    expect(page).to have_link("corker@example.com")
  end
end
