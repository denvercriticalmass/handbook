require "system_helper"

RSpec.describe "The nav on a phone" do
  let(:password) { "bike lanes now" }

  def position_of(selector)
    page.evaluate_script("getComputedStyle(document.querySelector(#{selector.to_json})).position")
  end

  it "keeps the waypoint filters in the page flow" do
    create(:waypoint)
    visit waypoints_path

    expect(position_of("main nav")).to eq("static")
  end

  it "pins the signed-in bar to the bottom" do
    visit "/signin"
    fill_in "Email address", with: create(:user, password:).email_address
    fill_in "Password", with: password
    click_on "Sign in"

    expect(position_of("body > nav")).to eq("fixed")
  end
end
