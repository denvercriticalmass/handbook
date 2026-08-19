require "rails_helper"

RSpec.describe "The development sign-in shortcut" do
  it "has no route outside development" do
    expect(Rails.application.routes.url_helpers).not_to respond_to(:dev_signin_path)
  end

  it "is not reachable outside development" do
    post "/dev/signin"

    expect(response).to have_http_status(:not_found)
  end
end
