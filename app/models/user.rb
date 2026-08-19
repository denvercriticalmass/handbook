class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  enum :role, { admin: 0, superadmin: 1 }, default: :admin

  scope :active, -> { where(active: true) }

  # Without this, a suspended user stays signed in until their cookie expires.
  after_update_commit :end_sessions, if: -> { saved_change_to_active? && !active? }

  normalizes :email_address, with: -> { it.strip.downcase }

  private

    def end_sessions
      sessions.destroy_all
    end
end
