module ComparisonHelper
	
	
	def engine_sum(query, googleRes, sess, eng)
		
				
						# retrieves the results from each engine for each of the current query
						engine = Result.select('url, query_rank').where("session_id=? AND db_name=? AND query=?", sess, eng, query).order('query_rank ASC').all
					
										
					engine_relevant = []
					engine_rel_count = 0
					engine_ave_precision = 0
					
					
						# compares engines results to google and retreives the relevant results
					engine.each do |engine| 
						googleRes.each do |g|
							if g.url == engine.url
								engine_rel_count += 1
								engine_relevant << [engine.url, engine_rel_count, engine.query_rank]
							end
						end
					end
					
					# divides the count of relevancy by the engine rank to get precision of results 
						# for each relevant document,
					
					engine_precision_vals =0
					
					engine_relevant.each do |rel|
						engine_precision_vals += (rel[1] / rel[2].to_f)
					end
					
					engine_ave_precision = (engine_precision_vals / googleRes.size)
					
	end
	
	
	def agg_sum(query, googleRes, sess)
		
				
						# retrieves the results from each engine for each of the current query
					agg_res = Result.where('session_id = ? and query =?', sess, query).order("score DESC")
					
					urls =[]
					
					# removes results with duplicate urls from the but leaves the result with the highest score
					agg_res.delete_if do |item|
						if urls.include? item[:url]
							true
						else
							urls << item[:url]
							false
						end
					end
					
					urls = nil
					
					# updating the setter for aggregated results ranking. Works because results are sorted by score.
					agg_rank_count = 0
					
					agg_res.each do |c|
						agg_rank_count+=1
						c.agg_rank = agg_rank_count
					end
					
					# delete results which are ranked above 100 to match individual result sets
					agg_res.delete_if {|result| result.agg_rank > 100}
					
					# end aggregated ranking
					
					##### Start of aggregated average precision calculation #####
					
					agg_res_relevant = []
					agg_count = 0
					agg_res_ave_precision = 0
					
					
					
					# compares aggregated results to google and retreives the relevant results
					agg_res.each do |agg| 
						googleRes.each do |g|
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
					
					agg_res_ave_precision = (agg_precision_vals / googleRes.size)
					
	end
end
