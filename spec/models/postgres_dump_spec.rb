require "rails_helper"

RSpec.describe PostgresDump do
  let(:config) do
    { host: "handbook-db", port: 5432, username: "handbook", password: "hunter2", database: "handbook_production" }
  end

  def dump
    described_class.new(config:)
  end

  it "dumps the configured database" do
    expect(dump.command("/tmp/out.dump")).to include("--dbname=handbook_production")
  end

  it "reaches the database over the configured host" do
    expect(dump.command("/tmp/out.dump")).to include("--host=handbook-db")
  end

  it "writes where it is told" do
    expect(dump.command("/tmp/out.dump")).to include("--file=/tmp/out.dump")
  end

  it "asks for the format pg_restore reads" do
    expect(dump.command("/tmp/out.dump")).to include("--format=custom")
  end

  # argv is world readable in a process list, so this must never appear there.
  it "keeps the password out of the command" do
    expect(dump.command("/tmp/out.dump").join(" ")).not_to include("hunter2")
  end

  it "passes the password through the environment" do
    expect(dump.environment).to eq("PGPASSWORD" => "hunter2")
  end
end
