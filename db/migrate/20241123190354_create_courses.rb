class CreateCourses < ActiveRecord::Migration[8.0]
  def change
    create_table :courses do |t|
      t.string :title
      t.text :description
      t.integer :level
      t.decimal :rating, precision: 5, scale: 2
      t.boolean :enabled, null: false, default: true
      t.references :author, null: true, foreign_key: true

      t.timestamps
    end
  end
end
