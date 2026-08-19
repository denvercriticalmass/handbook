require "rails_helper"

RSpec.describe History do
  subject(:history) { described_class.new(guide) }

  let(:guide) { create(:guide, title: "Korking", body: "<div>Stand here</div>") }

  it "starts with the newest change" do
    guide.update!(title: "Corking")
    guide.update!(body: "<div>Stand there</div>")

    expect(history.entries.first.change).to eq("Body")
  end

  it "names the field that changed" do
    guide.update!(title: "Corking")

    expect(history.entries.map(&:change)).to include("Title")
  end

  it "records when the guide was written" do
    expect(history.entries.map(&:change)).to include("Created")
  end
end
