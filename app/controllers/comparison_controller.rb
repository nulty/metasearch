class ComparisonController < ApplicationController
  #include ComparisonHelper
  
  def single_query
  	
  	# initializes the engine and query to Bing and first query if 
  	#		the parameters are empty
  	
  	engine = params[:engine].nil? ? "Bing" : params[:engine]
  	query = params[:query].nil? ? "obama family tree" : params[:query]
  	
  	# session Id for all test queries is rake_task
  	@sess = "rake_task"

  	# create arrays to hold the queries and engine names
  	@db_names = []
  	@queries = []
  	
  	# Fill arrays with their data from the database
  	Result.select(:query).where(:session_id => @sess).uniq.each {|r| @queries << r.query}
  	Result.select(:db_name).uniq.each {|r| @db_names << r.db_name}
  	
  	
  	# Collect all results for the selected engine relative to the seleced query 
  	@engine = Result.select('url, query_rank').where("session_id=? AND db_name=? And query=?", @sess, engine, query).order('query_rank ASC').all
  		
  	# Collect all Google results for the selected query
  	@googleRes = Google.select('url, query_rank').where("query=?",query).order('query_rank ASC').all
  	
  	# array to contain all the relevant queries returned by the engine
  	@relevant = []
  	
  	# initialize variables
  	@count = 0
  	@ave_precision = 0
  	
  	# compares engines results to google and retreive the relevant results
  	#		Store the url, order of results along with the rank of the result
  	 
  	@engine.each do |eng| 
  		@googleRes.each do |g|
				if g.url == eng.url					
					@count += 1
					@relevant << [eng.url, @count, eng.query_rank]
				end
			end
  	end
  	
  	@precision = ((@count/@engine.length.to_f)*100).to_i
  	@recall = ((@count/@googleRes.length.to_f)*100).to_i
  	
  	
  	
  	# how many of the top ten engine results are relevant (in Google results) 
  	c=0
  	@engine[0..9].each do |ten|
  		@relevant.each do |rel|
  			if rel[0] == ten[:url]
  				c+=1
				end
  		end
  	end
  	
  	@P_at_10 = ((c/10.0)*100).to_i
  	
  	
  	
  	
  	running_score =0
  	@relevant.each do |rel|
  		running_score += ((rel[1] / rel[2].to_f)*100).to_i
  	end
  	
  	@ave_precision = (running_score / @googleRes.size)
   
  end

  
  
  
  def summary
  	
  	# weighting attached to each search engine based on the trial queries
		bing_weight = 0.06
		blekko_weight = 0.05
		entire_weight = 0.0
  	
		# group for all the agg results at line 187
		aggregated_with_scores = []
		
  	sess = "rake_task"
  	
  	db_names = []
  	queries = []
  	
  	Google.select(:query).uniq.each {|r| queries << r.query}
  	Result.select(:db_name).uniq.each {|r| db_names << r.db_name}

  	
  	@bingP=[]
  	@blekkoP =[]
  	@entirewebP =[]
  	@aggregatedP =[]
  	
  	
  		# loops through the trial queries performing 
  	queries.each do |q|
  		
  			# retrieves the results from each engine for each of the current query
			@bing = Result.select('url, query_rank').where("session_id=? AND db_name=? AND query=?", sess, "Bing", q).order('query_rank ASC').all
			@blekko = Result.select('url, query_rank').where("session_id=? AND db_name=? AND query=?", sess, "Blekko", q).order('query_rank ASC').all
			@entireweb = Result.select('url, query_rank').where("session_id=? AND db_name=? AND query=?", sess, "Entireweb", q).order('query_rank ASC').all
			@googleRes = Google.select('url, query_rank').where("query=?",q).order('query_rank ASC').all
			
			
			@bing_relevant = []
			bing_count = 0
			@bing_ave_precision = 0
			
			
				# compares engines results to google and retreives the relevant results
			@bing.each do |bing| 
				@googleRes.each do |g|
					if g.url == bing.url
						bing_count += 1
						@bing_relevant << [bing.url, bing_count, bing.query_rank]
					end
				end
			end
			
				# divides the engine rank by the google rank to get precision of relevant results 
				# for each relevant document,
				bing_precision_vals =0
			@bing_relevant.each do |rel|
				bing_precision_vals += ((rel[1] / rel[2].to_f)*100).to_i
			end
			
			@bing_ave_precision = (bing_precision_vals / @googleRes.size)
			@bingP << @bing_ave_precision
			
			###################################################
			
			@blekko_relevant = []
			blekko_count = 0
			@blekko_ave_precision = 0
			
			@blekko.each do |blekko| 
				@googleRes.each do |g|
					if g.url == blekko.url
						blekko_count += 1
						@blekko_relevant << [blekko.url, blekko_count, blekko.query_rank]
					end
				end
			end
			
			blekko_precision_vals = 0
			@blekko_relevant.each do |rel|
				blekko_precision_vals += ((rel[1] / rel[2].to_f)*100).to_i
			end
			
			@blekko_ave_precision = (blekko_precision_vals / @googleRes.size)
			
			@blekkoP << @blekko_ave_precision
			################################################
			
			@entire_relevant = []
			entire_count = 0
			@entire_ave_precision = 0
			
			@entireweb.each do |entire| 
				@googleRes.each do |g|
					if g.url == entire.url
						entire_count += 1
						@entire_relevant << [entire.url, entire_count, entire.query_rank]
					end
				end
			end
			
			entire_precision_vals = 0
			@entire_relevant.each do |rel|
				entire_precision_vals += ((rel[1] / rel[2].to_f)*100).to_i
			end
			
			@entire_ave_precision = (entire_precision_vals / @googleRes.size)
		
			@entirewebP << @entire_ave_precision
			
			##### Start of aggregated average precision calculation #####
			
			# for each of the queries, give the result a score based on the weighting and
			#		put in group
			@bing.each do |res|
				r = res.serializable_hash
				raw_score = (1 - ((res["query_rank"]-1.0) / @bing.count)) # RankSim(rank)
				r[:score] = (raw_score + (raw_score*bing_weight)).round(4)
				aggregated_with_scores << r
			end
				
			@entireweb.each do |res|
				r = res.serializable_hash
				raw_score = (1 - ((res["query_rank"]-1.0) / @entireweb.count)) # RankSim(rank)
				r[:score] = (raw_score + (raw_score*entire_weight)).round(4)		 
				aggregated_with_scores<< r
			end
			
			@blekko.each do |res|
				r = res.serializable_hash
				raw_score = (1 - ((res["query_rank"]-1.0) / @blekko.count)) # RankSim(rank)
				r[:score] = (raw_score + (raw_score*blekko_weight)).round(4)
				aggregated_with_scores << r
			end
			
			# aggregated scores for this query 
			sorted_aggregated = aggregated_with_scores.sort_by {|hsh| hsh[:score]}
			
			#now get average precision for this aggregated result set
			
			
			
			
			@aggregated_relevant = []
			aggregated_count = 0
			@aggregated_ave_precision = 0
			
			sorted_aggregated.each do |aggregated| 
				@googleRes.each do |g|
					if g.url == aggregated[:url]
						aggregated_count += 1
						@aggregated_relevant << [aggregated['url'], aggregated_count, aggregated['query_rank']]
					end
				end
			end
			
			aggregated_precision_vals = 0
			@aggregated_relevant.each do |rel|
				aggregated_precision_vals += ((rel[1] / rel[2].to_f)*100).to_i
			end
			
			@aggregated_ave_precision = (aggregated_precision_vals / @googleRes.size)
			
			
			
			
			
			
			
			
			
			
			@aggregatedP << @aggregated_ave_precision
			
		end # queries loop

		
  	
		

		
		
		accumulated_averages = 0
		@bingP.each do |ave|
			accumulated_averages += ave
		end
		
		@bing_map= accumulated_averages / queries.count
  	
		accumulated_averages=0		
		@blekkoP.each do |ave|
			accumulated_averages += ave
		end
		
		@blekko_map= accumulated_averages / queries.count
		
		accumulated_averages=0
  	@entirewebP.each do |ave|
			accumulated_averages += ave
		end
		
		@aggregated_map= accumulated_averages / queries.count
		
		accumulated_averages=0
		@aggregatedP.each do |ave|
			accumulated_averages += ave
		end
		
		@entire_map= accumulated_averages / queries.count
		
  end
  
  def agg_map 
  	
  	
  end
end
