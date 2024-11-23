class CreateAuthors < ActiveRecord::Migration[8.0]
  def change
    create_table :authors do |t|
      t.string :name
      t.string :email
      t.text :bio

      t.timestamps
    end
  end
end
