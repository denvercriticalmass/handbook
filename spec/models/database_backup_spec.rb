require "rails_helper"

RSpec.describe DatabaseBackup do
  let(:client) do
    Aws::S3::Client.new(
      stub_responses: true,
      region: "us-east-005",
      credentials: Aws::Credentials.new("key-id", "application-key")
    )
  end

  # The real dump needs a pg_dump matching the server, which no dev machine
  # here has. What it writes is verified in the production image instead.
  let(:dump) { instance_double(PostgresDump) }

  def backup
    described_class.new(client:, bucket: "handbook-backups", dump:)
  end

  def uploads
    client.api_requests.select { it[:operation_name] == :put_object }
  end

  before { allow(dump).to receive(:into) { File.write(it, "PGDMP pretend archive") } }

  it "uploads one object" do
    backup.store

    expect(uploads.size).to eq(1)
  end

  it "uploads into the configured bucket" do
    backup.store

    expect(uploads.first.dig(:params, :bucket)).to eq("handbook-backups")
  end

  it "names the object for the moment it ran" do
    backup.store

    expect(uploads.first.dig(:params, :key)).to match(/\Ahandbook-\d{14}\.dump\z/)
  end

  it "uploads what pg_dump wrote" do
    backup.store

    expect(uploads.first.dig(:params, :body).read).to eq("PGDMP pretend archive")
  end

  it "leaves nothing behind on disk" do
    backup.store

    expect(Dir.glob(File.join(Dir.tmpdir, "#{described_class::PREFIX}*"))).to be_empty
  end

  it "says what it needs when nothing is configured" do
    allow(Rails.application.credentials).to receive(:backups).and_return(nil)

    expect { described_class.bucket }.to raise_error(/access_key_id/)
  end

  describe "pruning" do
    def stub_backups(*ages)
      client.stub_responses(
        :list_objects_v2,
        contents: ages.map.with_index { |age, i| { key: "handbook-2026010#{i}000000.dump", last_modified: age } }
      )
    end

    def deletions
      client.api_requests.select { it[:operation_name] == :delete_object }.map { it.dig(:params, :key) }
    end

    it "removes a backup past the retention window" do
      stub_backups(31.days.ago)

      backup.prune

      expect(deletions.size).to eq(1)
    end

    it "keeps one still inside it" do
      stub_backups(29.days.ago)

      backup.prune

      expect(deletions).to be_empty
    end

    it "removes only the stale one" do
      stub_backups(29.days.ago, 31.days.ago)

      backup.prune

      expect(deletions).to eq([ "handbook-20260101000000.dump" ])
    end
  end
end
