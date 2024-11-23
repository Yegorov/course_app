class CreateCompetences < ActiveRecord::Migration[8.0]
  def change
    create_table :competences do |t|
      t.string :title
      t.references :course, null: false, foreign_key: true

      t.timestamps
    end
  end
end
