class CreateGoogles < ActiveRecord::Migration
  def change
    create_table :googles do |t|
      t.text :query
      t.text :query_rank
      t.integer :query_number
      t.text :title
      t.text :description
      t.text :url

      t.timestamps
    end
  end
end
