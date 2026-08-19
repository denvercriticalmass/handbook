module Searchable
  extend ActiveSupport::Concern

  included do
    include PgSearch::Model

    pg_search_scope :search,
      against: :title,
      associated_against: { rich_text_body: :body },
      using: { tsearch: { prefix: true } }
  end
end
