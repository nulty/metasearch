class Result < ActiveRecord::Base
	include ResultsHelper
	
  attr_accessible :db_name, :description, :query, :query_rank, :session_id, :title, :url, :query_number
  
  
  validates :db_name, :description, :query, :query_rank, :session_id,  :url, :query_number, :presence => :true #:title,
  
  
end
