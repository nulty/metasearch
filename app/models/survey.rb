class Survey < ActiveRecord::Base
  attr_accessible :add_info, :agg_non, :clust_non, :interface, :make_default, :meta_better, :norm_eng, :result_pres, :speed
  
  
  validates  :agg_non, :clust_non, :interface, :make_default, :meta_better, :norm_eng, :result_pres, :speed, :presence => :true
  
end
