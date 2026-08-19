class Guide < ApplicationRecord
  include Searchable

  extend FriendlyId
  friendly_id :title, use: :slugged

  has_paper_trail on: %i[ create update destroy ]

  belongs_to :created_by, class_name: "User"
  has_rich_text :body

  validates :title, presence: true

  scope :by_title, -> { order(:title) }
end
