class MoveBodiesToActionText < ActiveRecord::Migration[8.1]
  RECORDS = { "guides" => "Guide", "cheat_sheets" => "CheatSheet" }.freeze

  def up
    RECORDS.each do |table, model|
      # Trix stores each line as its own block, so plain text arrives as divs.
      execute <<~SQL.squish
        INSERT INTO action_text_rich_texts (name, body, record_type, record_id, created_at, updated_at)
        SELECT 'body', '<div>' || replace(body, E'\\n', '</div><div>') || '</div>',
               '#{model}', id, now(), now()
        FROM #{table} WHERE body IS NOT NULL AND body <> ''
      SQL

      remove_column table, :body, :text
    end
  end

  def down
    RECORDS.each_key { add_column it, :body, :text }
  end
end
