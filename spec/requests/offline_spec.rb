require "rails_helper"

RSpec.describe "Working offline" do
  it "serves a manifest" do
    get pwa_manifest_path

    expect(response.parsed_body["name"]).to eq("Denver Critical Mass Handbook")
  end

  it "serves a service worker that knows where the fallback is" do
    get pwa_service_worker_path

    expect(response.body).to include(%(OFFLINE_PATH = "/offline"))
  end

  it "serves the fallback page" do
    get offline_path

    expect(response.body).to include("No signal")
  end

  it "marks a public page as safe to keep" do
    get cheat_sheets_path

    expect(response.headers["X-Offline-Cache"]).to eq("allowed")
  end

  it "refuses to mark a page carrying the admin nav" do
    user = create(:user, password: "password")
    post session_path, params: { email_address: user.email_address, password: "password" }

    get cheat_sheets_path

    expect(response.headers["X-Offline-Cache"]).to be_nil
  end
end
