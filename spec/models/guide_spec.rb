require "rails_helper"

RSpec.describe Guide do
  it "needs a title" do
    expect(build(:guide, title: "")).not_to be_valid
  end

  it "is valid with a title" do
    expect(build(:guide)).to be_valid
  end

  it "keeps its body as rich text" do
    expect(build(:guide, body: "<div>Stand <strong>here</strong></div>").body.to_plain_text).to eq("Stand here")
  end

  it "is found by a word in its title" do
    guide = create(:guide, title: "Corking a junction")
    create(:guide, title: "Radio channels")

    expect(described_class.search("corking")).to eq([ guide ])
  end

  it "is found by a word in its body" do
    guide = create(:guide, body: "<div>Stand where drivers can see you</div>")

    expect(described_class.search("drivers")).to eq([ guide ])
  end

  it "takes its slug from its title" do
    expect(create(:guide, title: "Corking a junction").slug).to eq("corking-a-junction")
  end

  it "keeps the slug when the title is fixed, so a shared link still works" do
    guide = create(:guide, title: "Korking")

    expect { guide.update!(title: "Corking") }.not_to change(guide, :slug)
  end

  it "answers to its slug" do
    guide = create(:guide, title: "Corking a junction")

    expect(described_class.friendly.find("corking-a-junction")).to eq(guide)
  end

  it "keeps a version of every edit" do
    guide = create(:guide, title: "Korking")

    expect { guide.update!(title: "Corking") }.to change { guide.versions.count }.by(1)
  end

  it "leaves the body alone when only the title changed" do
    guide = create(:guide, title: "Korking", body: "<div>Stand here</div>")

    expect { guide.update!(title: "Corking") }.not_to change { guide.rich_text_body.versions.count }
  end

  it "knows who wrote it" do
    expect(build(:guide).created_by).to be_a(User)
  end
end
