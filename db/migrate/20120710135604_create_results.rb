class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.text :session_id
      t.text :db_name
      t.text :query
      t.integer :query_rank
      t.text :title
      t.text :description
      t.text :url

      t.timestamps
    end
  end
end
