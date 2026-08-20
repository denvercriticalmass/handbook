class PostgresDump
  def initialize(config: ActiveRecord::Base.connection_db_config.configuration_hash)
    @config = config
  end

  def into(path)
    system(environment, *command(path), exception: true)
  end

  def command(path)
    [
      "pg_dump",
      "--format=custom",
      "--no-owner",
      "--no-privileges",
      "--host=#{config[:host]}",
      "--port=#{config[:port]}",
      "--username=#{config[:username]}",
      "--dbname=#{config[:database]}",
      "--file=#{path}"
    ]
  end

  # Anyone reading the process list can see argv, so the password travels here.
  def environment
    { "PGPASSWORD" => config[:password].to_s }
  end

  private

    attr_reader :config
end
