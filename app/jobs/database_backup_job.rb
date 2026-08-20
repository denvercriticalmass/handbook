class DatabaseBackupJob < ApplicationJob
  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  def perform
    DatabaseBackup.nightly
  end
end
