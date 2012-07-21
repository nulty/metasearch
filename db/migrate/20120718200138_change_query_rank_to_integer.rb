class ChangeQueryRankToInteger < ActiveRecord::Migration
  def up
  	change_column :googles, :query_rank, :integer
  end

  def down
  	change_column :googles, :query_rank, :text
  end
end
