class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :passkeys, dependent: :destroy
  # created_by_id is not nullable, so nullify would raise. An account that
  # wrote something gets suspended, never deleted.
  has_many :written_guides,
    class_name: "Guide",
    foreign_key: :created_by_id,
    inverse_of: :created_by,
    dependent: :restrict_with_error
  has_many :written_cheat_sheets,
    class_name: "CheatSheet",
    foreign_key: :created_by_id,
    inverse_of: :created_by,
    dependent: :restrict_with_error
  has_many :marked_waypoints,
    class_name: "Waypoint",
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

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true

  # Without this, a suspended user stays signed in until their cookie expires.
  after_update_commit :end_sessions, if: -> { saved_change_to_active? && !active? }

  normalizes :email_address, with: -> { it.strip.downcase }
  normalizes :name, with: -> { it.strip }

  # WebAuthn wants a stable opaque id for the account, never the email address.
  def passkey_handle
    update!(webauthn_id: WebAuthn.generate_user_id) if webauthn_id.blank?

    webauthn_id
  end

  private

    def end_sessions
      sessions.destroy_all
    end
end
