require "rails_helper"

RSpec.describe "My admin account" do
  let(:admin) { create(:user, email_address: "corker@example.com") }

  def sign_in_as(user)
    post session_path, params: { email_address: user.email_address, password: "password" }
  end

  it "sends a visitor with no account to sign in" do
    get admin_account_path

    expect(response).to redirect_to(new_session_path)
  end

  it "shows the signed-in admin their own address" do
    sign_in_as admin

    get admin_account_path

    expect(response.body).to include("corker@example.com")
  end

  it "always shows your own account, never anyone else's" do
    create(:user, email_address: "someone@else.example")
    sign_in_as admin

    get admin_account_path

    expect(response.body).not_to include("someone@else.example")
  end

  it "changes the name" do
    sign_in_as admin

    patch admin_account_path, params: { name: "Corker Joe" }

    expect(admin.reload.name).to eq("Corker Joe")
  end

  it "changes the address" do
    sign_in_as admin

    patch admin_account_path, params: { email_address: "moved@example.com" }

    expect(admin.reload.email_address).to eq("moved@example.com")
  end

  it "changes the password" do
    sign_in_as admin

    patch admin_account_path,
      params: { password: "a whole new password", password_confirmation: "a whole new password" }

    expect(admin.reload.authenticate("a whole new password")).to be_truthy
  end

  it "leaves the password alone when the field is left blank" do
    sign_in_as admin

    patch admin_account_path, params: { email_address: "moved@example.com", password: "" }

    expect(admin.reload.authenticate("password")).to be_truthy
  end
end
