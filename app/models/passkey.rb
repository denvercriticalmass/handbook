class Passkey < ApplicationRecord
  belongs_to :user

  validates :external_id, presence: true, uniqueness: true
  validates :nickname, presence: true
  validates :public_key, presence: true
end
