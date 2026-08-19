require "rails_helper"
require "tempfile"

RSpec.describe "Working offline" do
  it "serves a manifest" do
    get pwa_manifest_path

    expect(response.parsed_body["name"]).to eq("Denver Critical Mass Handbook")
  end

  it "serves a service worker that knows where the fallback is" do
    get pwa_service_worker_path

    expect(response.body).to include(%(OFFLINE_PATH = "/offline"))
  end

  it "serves a service worker that parses as javascript" do
    skip "node is not installed" unless system("which node > /dev/null 2>&1")
    get pwa_service_worker_path
    script = Tempfile.new([ "service-worker", ".js" ]).tap { it.write(response.body); it.close }

    expect(system("node", "--check", script.path)).to be(true)
  end

  it "names the asset cache after the release, so a deploy sweeps the old one" do
    get pwa_service_worker_path

    expect(response.body).to match(/const RELEASE = "\w+"/)
  end

  it "treats a turbo visit as a page, since turbo fetches rather than navigates" do
    get pwa_service_worker_path

    expect(response.body).to include("Turbo-Frame")
  end

  it "serves the fallback page" do
    get offline_path

    expect(response.body).to include("No signal")
  end

  it "tells the worker to forget cached pages when a session ends" do
    user = create(:user, password: "password")
    post session_path, params: { email_address: user.email_address, password: "password" }

    delete session_path
    follow_redirect!

    expect(response.body).to include(%(data-controller="signed-out"))
  end

  it "offers the cheat sheets list for prefetching" do
    get cheat_sheets_path

    expect(response.body).to include(%(data-controller="prefetch"))
  end
end
