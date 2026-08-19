require "rails_helper"

RSpec.describe "Home" do
  let(:password) { "bike lanes now" }

  def body_of(path)
    get path
    response.body
  end

  def sign_in
    user = create(:user, password:)
    post session_path, params: { email_address: user.email_address, password: }
  end

  it "is reachable without signing in" do
    get root_path

    expect(response).to have_http_status(:ok)
  end

  it "carries no trace of the admin UI" do
    get root_path

    expect(response.body).not_to match(/signin|signout|session/i)
  end

  it "looks the same to a signed-in admin, so the cache can't fragment" do
    anonymous = body_of(root_path)
    sign_in

    expect(body_of(root_path)).to eq(anonymous)
  end
end
