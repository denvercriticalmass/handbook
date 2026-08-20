require "aws-sdk-s3"
require "tempfile"

class DatabaseBackup
  RETENTION = 30.days
  PREFIX = "handbook-"

  def self.nightly
    new.store
  end

  def initialize(client: self.class.client, bucket: self.class.bucket, dump: PostgresDump.new)
    @client = client
    @bucket = bucket
    @dump = dump
  end

  def store
    Tempfile.create([ PREFIX, ".dump" ]) do |file|
      dump.into(file.path)
      client.put_object(bucket:, key: key_for(Time.current), body: File.open(file.path, "rb"))
    end

    prune
  end

  def prune
    stale.each { client.delete_object(bucket:, key: it.key) }
  end

  class << self
    def client
      Aws::S3::Client.new(
        access_key_id: settings.fetch(:access_key_id),
        secret_access_key: settings.fetch(:secret_access_key),
        endpoint: settings.fetch(:endpoint),
        region: settings.fetch(:region)
      )
    end

    def bucket
      settings.fetch(:bucket)
    end

    private

      # Named for the job rather than the vendor, which has already changed once.
      def settings
        Rails.application.credentials.backups ||
          raise("Backups need a backups section in credentials: " \
                "access_key_id, secret_access_key, endpoint, region, bucket")
      end
  end

  private

    attr_reader :client, :bucket, :dump

    def key_for(time)
      "#{PREFIX}#{time.utc.strftime("%Y%m%d%H%M%S")}.dump"
    end

    def stale
      client.list_objects_v2(bucket:, prefix: PREFIX)
        .contents
        .select { it.last_modified < RETENTION.ago }
    end
end
