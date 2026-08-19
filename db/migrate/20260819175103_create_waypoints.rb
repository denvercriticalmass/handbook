class CreateWaypoints < ActiveRecord::Migration[8.1]
  def change
    create_table :waypoints do |t|
      t.string :name, null: false
      t.string :slug, null: false, index: { unique: true }
      t.integer :category, null: false, default: 0
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.text :note
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
