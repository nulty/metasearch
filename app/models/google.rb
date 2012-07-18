class Google < ActiveRecord::Base
  attr_accessible :description, :query, :query_number, :query_rank, :title, :url
  
  validates :description, :query, :query_rank, :title, :url, :query_number, :presence => :true
end
