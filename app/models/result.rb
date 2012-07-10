class Result < ActiveRecord::Base
  attr_accessible :db_name, :description, :query, :query_rank, :session_id, :title, :url
end
