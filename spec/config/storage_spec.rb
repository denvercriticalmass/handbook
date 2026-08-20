require "rails_helper"

RSpec.describe "config/storage.yml" do
  let(:settings) do
    {
      access_key_id: "an-access-key",
      secret_access_key: "a-secret",
      endpoint: "https://hel1.example.com",
      region: "fsn1",
      bucket: "handbook-uploads"
    }
  end

  let(:uploads) do
    settings.each do |field, value|
      allow(Rails.application.credentials).to receive(:dig).with(:uploads, field).and_return(value)
    end

    YAML.safe_load(ERB.new(Rails.root.join("config/storage.yml").read).result, aliases: true).fetch("uploads")
  end

  it "talks S3" do
    expect(uploads.fetch("service")).to eq("S3")
  end

  it "uses the uploads bucket, never the one backups are pruned from" do
    expect(uploads.fetch("bucket")).to eq("handbook-uploads")
  end

  it "points at the configured endpoint" do
    expect(uploads.fetch("endpoint")).to eq("https://hel1.example.com")
  end

  it "signs with the configured region" do
    expect(uploads.fetch("region")).to eq("fsn1")
  end

  it "reads the access key" do
    expect(uploads.fetch("access_key_id")).to eq("an-access-key")
  end

  it "reads the secret separately from the key" do
    expect(uploads.fetch("secret_access_key")).to eq("a-secret")
  end
end
