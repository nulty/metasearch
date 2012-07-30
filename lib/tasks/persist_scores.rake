desc "Update results to presist scores"

task :persist_scores => :environment do


	(1..50).each do |query_num|
		
		# weighting attached to each search engine based on the trial queries
		bing_weight 	= 0.07194439651946018
		blekko_weight = 0.059700029899288264
		entire_weight = 0.038843882872345976
		
		# session_id for the test queries
  	sessionid =  "rake_task"
  	
  	group = []
  	
  	# These three instance variables populate the view with the data from the database.
  	bing_res = Result.where('db_name = ? and session_id = ? and query_number =?', "Bing", sessionid, query_num).order("query_rank ASC")
  	blekko_res = Result.where('db_name = ? and session_id = ? and query_number =?', "Blekko", sessionid, query_num).order("query_rank ASC")
  	entire_res = Result.where('db_name = ? and session_id = ? and query_number =?', "Entireweb", sessionid, query_num).order("query_rank ASC")
  	
  	bing_query_count = bing_res.count
  	
  	Result.transaction do
			bing_res.each do |res|
				raw_score = (1 - ((res.query_rank-1.0) / bing_query_count))
				weighted_score = (raw_score + (raw_score*bing_weight))
				res.update_attributes(:score => weighted_score.to_d)
			end
		end
		
		entire_query_count = entire_res.count
		
		Result.transaction do
			
			entire_res.each do |res|
				raw_score = (1 - ((res.query_rank-1.0) / entire_query_count))
				weighted_score = (raw_score + (raw_score*entire_weight))		 
				res.update_attributes(:score => weighted_score.to_d)
			end
		end
		
		blekko_query_count = blekko_res.count
		
		Result.transaction do			
			blekko_res.each do |res|
				raw_score = (1 - ((res.query_rank-1.0) / blekko_query_count))
				weighted_score = (raw_score + (raw_score*blekko_weight))
				res.update_attributes(:score => weighted_score.to_d)
			end
		end
  	  	
	end # query loop
end
