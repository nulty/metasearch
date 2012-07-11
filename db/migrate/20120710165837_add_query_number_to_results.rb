class AddQueryNumberToResults < ActiveRecord::Migration
  def change
    add_column :results, :query_number, :integer
  end
end
