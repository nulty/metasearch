class CreateSurveys < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.integer :norm_eng
      t.integer :meta_better
      t.integer :agg_non
      t.integer :clust_non
      t.integer :interface
      t.integer :result_pres
      t.integer :speed
      t.boolean :make_default
      t.text :add_info

      t.timestamps
    end
  end
end
