class CreateGuides < ActiveRecord::Migration[8.1]
  def change
    create_table :guides do |t|
      t.string :title, null: false
      t.text :body
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
