class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  # created_by_id is not nullable, so nullify would raise. An account that
  # wrote something gets suspended, never deleted.
  has_many :written_guides,
    class_name: "Guide",
    foreign_key: :created_by_id,
    inverse_of: :created_by,
    dependent: :restrict_with_error
  has_many :sent_invitations,
    class_name: "Invitation",
    foreign_key: :invited_by_id,
    inverse_of: :invited_by,
    dependent: :destroy

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
