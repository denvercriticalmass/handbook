class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  enum :role, { admin: 0, superadmin: 1 }, default: :admin

  scope :active, -> { where(active: true) }

  normalizes :email_address, with: -> { it.strip.downcase }
end
