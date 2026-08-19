# Shared by Guide and CheatSheet. The body is Action Text, so the indexed
# column is the rich text record's, tags and all.
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
