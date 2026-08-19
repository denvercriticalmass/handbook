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

  it "says when the next ride is" do
    get root_path

    expect(response.body).to include(Ride.next.on.strftime("%A, %B"))
  end

  it "says when to gather" do
    get root_path

    expect(response.body).to include(Ride.next.gathers_at)
  end

  it "points at the guides" do
    get root_path

    expect(response.body).to include(guides_path)
  end

  it "points at the cheat sheets" do
    get root_path

    expect(response.body).to include(cheat_sheets_path)
  end

  it "points at the worldwide rides" do
    get root_path

    expect(response.body).to include(worldwide_path)
  end

  it "is reachable without signing in" do
    get root_path

    expect(response).to have_http_status(:ok)
  end

  it "keeps a flash meant for somewhere else off a public page" do
    post session_path, params: { email_address: "nobody@example.com", password: "wrong" }

    get root_path

    expect(Nokogiri::HTML(response.body).at("#alert")).to be_nil
  end

  it "carries no trace of the admin UI" do
    get root_path

    expect(response.body).not_to match(/signin|signout|session/i)
  end

  it "carries the admin nav for a signed-in admin" do
    sign_in

    expect(body_of(root_path)).to include(admin_guides_path)
  end
end
