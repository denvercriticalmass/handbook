# The token is a single-use credential. Never log it.
class Invitation < ApplicationRecord
  LIFESPAN = 1.week

  belongs_to :invited_by, class_name: "User"

  has_secure_token

  attribute :expires_at, default: -> { LIFESPAN.from_now }

  normalizes :email_address, with: -> { it.strip.downcase }

  scope :usable, -> { where(accepted_at: nil).where(expires_at: Time.current..) }

  def accepted?
    accepted_at.present?
  end

  def expired?
    expires_at.past?
  end

  def usable?
    !accepted? && !expired?
  end
end
