class Waypoint < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  acts_as_taggable_on :tags

  has_paper_trail on: %i[ create update destroy ]

  belongs_to :created_by, class_name: "User"

  enum :category, { crossing: 0, intersection: 1, party_stop: 2, regroup_point: 3, hazard: 4 }

  validates :name, presence: true
  validates :latitude, numericality: { in: -90..90 }, allow_nil: true
  validates :longitude, numericality: { in: -180..180 }, allow_nil: true

  scope :by_name, -> { order(:name) }
  scope :grouped, -> { order(:category, :name) }

  def versioned_records
    [ self ]
  end

  def located?
    latitude.present? && longitude.present?
  end
end
