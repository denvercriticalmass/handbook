class AddSlugsToContent < ActiveRecord::Migration[8.1]
  TABLES = %w[ guides cheat_sheets ].freeze

  def up
    TABLES.each do |table|
      add_column table, :slug, :string

      execute <<~SQL.squish
        UPDATE #{table}
        SET slug = trim(both '-' from regexp_replace(lower(title), '[^a-z0-9]+', '-', 'g'))
      SQL

      change_column_null table, :slug, false
      add_index table, :slug, unique: true
    end
  end

  def down
    TABLES.each { remove_column it, :slug }
  end
end
