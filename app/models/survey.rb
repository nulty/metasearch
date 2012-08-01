class Survey < ActiveRecord::Base
  attr_accessible :add_info, :agg_non, :clust_non, :interface, :make_default, :meta_better, :norm_eng, :result_pres, :speed
  
  validates :norm_eng, :presence => {:message => "Q1) must be answered!"}
  validates :meta_better, :presence => {:message => "Q2) must be answered!"}
  validates :agg_non, :presence => {:message => "Q3) must be answered!"}
  validates :clust_non, :presence => {:message => "Q4) must be answered!"}
  validates :interface, :presence => {:message => "Q5) must be answered!"}
  validates :result_pres, :presence => {:message => "Q6) must be answered!"}
  validates :speed, :presence => {:message => "Q7) must be answered!"}
  validates :make_default, :presence => {:message => "Q8) must be answered!"}

  
end
