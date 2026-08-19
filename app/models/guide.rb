class Guide < ApplicationRecord
  belongs_to :created_by, class_name: "User"

  validates :title, presence: true

  scope :by_title, -> { order(:title) }
end
