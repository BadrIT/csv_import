class CreateBooks < ActiveRecord::Migration[5.0]
  def change
    create_table :books do |t|
      t.string :title
      t.string :description
      t.json :tags
      t.json :options
      t.date :date
      t.integer :number_of_pages
      t.float :price
      t.boolean :hard_cover

      t.timestamps
    end
  end
end
