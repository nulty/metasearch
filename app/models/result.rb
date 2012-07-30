class Result < ActiveRecord::Base
	include ResultsHelper
	
  attr_accessible :db_name, :description, :query, :query_rank, :session_id, :title, :url, :query_number, :score,:agg_rank
  
  # getter and setter methods for aggregated results ranking
  attr_accessor :agg_rank 
  
  validates :db_name, :description, :query, :query_rank, :title, :session_id,  :url, :query_number, :score, :presence => :true

end
