require "system_helper"

RSpec.describe "Tagging a guide" do
  let(:password) { "bike lanes now" }

  before do
    ActsAsTaggableOn::Tag.create!(name: "etiquette")

    visit "/signin"
    fill_in "Email address", with: create(:user, password:).email_address
    fill_in "Password", with: password
    click_on "Sign in"
    click_on "Guides"
    click_on "Write a guide"
  end

  def tag_field
    find("input[name='guide[tag_list]']", visible: :all)
  end

  def open_tags
    find(".ts-control").click
    sleep 0.2
  end

  def fill_in_the_rest
    fill_in "Title", with: "Corking basics"
    find("trix-editor").click.send_keys("Body text.")
  end

  # acts_as_taggable_on joins tag_list.to_s with ", " (a space after the
  # comma), which the widget's plain "," delimiter can't parse -- the second
  # tag silently vanished from the field until the seed value used to_a.join.
  it "shows every existing tag when a guide already has more than one" do
    guide = create(:guide, tag_list: %w[test b])

    visit "/admin/guides/#{guide.slug}/edit"

    expect(page).to have_css(".ts-control .item", count: 2)
  end

  it "reuses an existing tag rather than creating a duplicate" do
    open_tags
    find(".ts-dropdown .option", text: "etiquette").click

    expect(tag_field.value).to eq("etiquette")
    expect(ActsAsTaggableOn::Tag.where(name: "etiquette").count).to eq(1)
  end

  it "creates a tag that doesn't exist yet" do
    open_tags
    input = find(".ts-control input")
    input.click
    input.send_keys("brand new tag")
    sleep 0.3
    input.send_keys(:enter)
    sleep 0.3

    expect(tag_field.value).to eq("brand new tag")
  end

  it "commits a typed tag on Tab and keeps focus in the field" do
    open_tags
    input = find(".ts-control input")
    input.click
    input.send_keys("brand new tag")
    sleep 0.3
    input.send_keys(:tab)
    sleep 0.3

    expect(tag_field.value).to eq("brand new tag")
    expect(page).to have_css(".ts-control input:focus")
  end

  it "tabs to the next field normally once the tag box is empty" do
    open_tags
    find(".ts-control input").send_keys(:tab)
    sleep 0.3

    expect(page).to have_no_css(".ts-control input:focus")
  end

  it "shows a pointer cursor on a chip's remove button" do
    open_tags
    find(".ts-dropdown .option", text: "etiquette").click

    cursor = page.evaluate_script(
      "getComputedStyle(document.querySelector('.ts-control .item .remove')).cursor"
    )

    expect(cursor).to eq("pointer")
  end

  it "removes a tag from the field" do
    open_tags
    find(".ts-dropdown .option", text: "etiquette").click

    find(".ts-control .item .remove").click

    expect(tag_field.value).to eq("")
  end

  # Capybara's own visibility check does not catch this: an sr-only clip
  # rect still has non-zero box dimensions, so it reads as "visible" to it.
  it "hides the real field behind Tom Select's control" do
    style = page.evaluate_script(
      "getComputedStyle(document.querySelector(\"input[name='guide[tag_list]']\")).clipPath"
    )

    expect(style).to eq("inset(50%)")
  end

  it "saves the tag on the guide" do
    fill_in_the_rest
    open_tags
    find(".ts-dropdown .option", text: "etiquette").click
    find("h1").click
    click_on "Save"

    expect(Guide.find_by(title: "Corking basics").tag_list.to_a).to eq([ "etiquette" ])
  end
end
