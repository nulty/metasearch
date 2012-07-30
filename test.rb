# group for all the agg results at line 187
		aggregated_with_scores = []
		
  	sess = "rake_task"
  	
  	db_names = []
  	queries = []
  	
  	Google.select(:query).uniq.each {|r| queries << r.query}
  	Result.select(:db_name).uniq.each {|r| db_names << r.db_name}

  	
  	@aggregatedP =[]
  	
  	
  		# loops through the trial queries performing 
  	queries.each do |q|
  		
  			# retrieves the results from each engine for each of the current query
			agg_res = Result.where('session_id = ? and query =?', sess, q).order("score DESC")
			@googleRes = Google.select('url, query_rank').where("query=?",q).order('query_rank ASC').all
			
			# updating the setter for aggregated results ranking. Works because results are sorted by score.
			agg_rank = 0
			
			agg_res.each do |c|
				agg_rank+=1
				c.update_attributes(:agg_rank => agg_rank)
			end
			
			# end aggregated ranking
			
			
			
			##### Start of aggregated average precision calculation #####
			
			agg_res_relevant = []
			agg_count = 0
			agg_res_ave_precision = 0
			
			# removes results with duplicate urls from the but leaves the result with the highest score
			agg_res.delete_if do |item|
				if urls.include? item[:url]
					true
				else
					urls << item[:url]
					false
				end
			end
			
			# compares aggregated results to google and retreives the relevant results
			agg_res[0..99].each do |agg| 
				@googleRes.each do |g|
					if g.url == agg.url
						agg_count += 1
						agg_res_relevant << [agg.url, agg_count, agg.agg_rank]
					end
				end
			end
			
				# divides the engine rank by the google rank to get precision of relevant results 
				# for each relevant document,
			
			agg_precision_vals =0
			
			agg_res_relevant.each do |rel|
				agg_precision_vals += (rel[1] / rel[2].to_f)
			end
			
			agg_res_ave_precision = (agg_precision_vals / @googleRes.size)
			@aggregatedP << agg_res_ave_precision
			
		
			
		end # queries loop

		####################################################
		accumulated_averages=0
		@aggregatedP.each do |ave|
			accumulated_averages += ave
		end
		
		@aggregated_map= accumulated_averages / queries.count
		
