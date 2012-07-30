class AddScoreToResult < ActiveRecord::Migration
  def change
    add_column :results, :score, :decimal, :precision => 8, :scale => 5
  end
end
