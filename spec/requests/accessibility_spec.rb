require "rails_helper"

pages = {
  "the homepage" => "/",
  "sign in" => "/signin",
  "sign up" => "/signup",
  "the password reset form" => "/passwords/new",
  "the guides list" => "/guides",
  "the worldwide rides" => "/worldwide",
  "the cheat sheets" => "/cheat_sheets",
  "search" => "/search"
}

RSpec.describe "Accessibility" do
  def document_for(path)
    get path
    Nokogiri::HTML(response.body)
  end

  def unlabelled_fields(document)
    document.css("input, select, textarea").reject do |field|
      next true if %w[hidden submit].include?(field["type"])

      labelled_by_id?(document, field) || field.ancestors("label").any? || field["aria-label"].present?
    end
  end

  def labelled_by_id?(document, field)
    field["id"].present? && document.at("label[for='#{field["id"]}']").present?
  end

  pages.each do |name, path|
    it "declares a page language on #{name}" do
      expect(document_for(path).at("html")["lang"]).to be_present
    end

    it "labels every field on #{name}" do
      expect(unlabelled_fields(document_for(path)).map { it["name"] }).to be_empty
    end
  end
end
