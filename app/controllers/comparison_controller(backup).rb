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
  	@db_names = [] << "Aggregated"
  	@queries = []
  	
  	# Fill arrays with their data from the database
  	Result.select(:query).where(:session_id => @sess).uniq.each {|r| @queries << r.query}
  	Result.select(:db_name).uniq.each {|r| @db_names << r.db_name}
  	
  	
  	# Collect all results for the selected engine relative to the seleced query 
  	if params[:engine] == "Aggregated"
			@engine =	Result.select('url, query_rank').where("session_id=? AND query=?", @sess, query).order('score DESC')
			
			
			urls = []

		
			# removes results with duplicate urls from the but leaves the result with the highest score (first because of ordering)
			@engine.delete_if do |item|
				if urls.include? item[:url]
					true
				else                                                
					urls << item[:url]
					false
				end
			end
			# assigns rank to aggregated results in line with score
			count_rank=0
			@engine.each do |e|
				count_rank+=1
				e.agg_rank = count_rank
			end
			
			@engine = @engine[0..99]
		else
			@engine = Result.select('url, query_rank').where("session_id=? AND db_name=? And query=?", @sess, engine, query).order('query_rank ASC').all
		end
		
  	# Retrieve all Google results for the selected query
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
					@relevant << [eng.url, @count, eng.agg_rank || eng.query_rank]
				end
			end
  	end
  	
  	@precision = ((@count/@engine.length.to_f))
  	@recall = ((@count/@googleRes.length.to_f))
  	
  	
  	
  	# how many of the top ten engine results are relevant (in Google results) 
  	top_10_rel = 0
  	@engine[0..9].each do |ten|
  		@relevant.each do |rel|
  			if rel[0] == ten[:url]
  				top_10_rel+=1
				end
  		end
  	end
  	
  	@P_at_10 = ((top_10_rel/10.0))
  	
  	
  	
  	
  	running_score =0
  	@relevant.each do |rel|
  		running_score += ((rel[1] / rel[2].to_f))
  	end
  	
  	@ave_precision = (running_score / @googleRes.size)
   
  end

  
  
  
  
  
  
  
  
  
  
  
  def summary
  	
  	
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
			agg_res = Result.where('session_id = ? and query =?', sess, q).order("score DESC")
			@googleRes = Google.select('url, query_rank').where("query=?",q).order('query_rank ASC').all
			
			# updating the setter for aggregated results ranking. Works because results are sorted by score.
			agg_rank1 = 0
			
			agg_res.each do |c|
				agg_rank1+=1
				c.agg_rank = agg_rank1
			end
			
			# end aggregated ranking
			
			
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
			
			# divides the count of relevancy by the engine rank to get precision of results 
				# for each relevant document,
				bing_precision_vals =0
			@bing_relevant.each do |rel|
				bing_precision_vals += (rel[1] / rel[2].to_f)
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
				blekko_precision_vals += (rel[1] / rel[2].to_f)
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
				entire_precision_vals += (rel[1] / rel[2].to_f)
			end
			
			@entire_ave_precision = (entire_precision_vals / @googleRes.size)
		
			@entirewebP << @entire_ave_precision
			
			##### Start of aggregated average precision calculation #####
			
			agg_res_relevant = []
			agg_count = 0
			agg_res_ave_precision = 0
			
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

		accumulated_averages = 0
		@bingP.each do |ave|
			accumulated_averages += ave
		end
		
		@bing_map= accumulated_averages / queries.count
		
  	####################################################
		accumulated_averages=0		
		@blekkoP.each do |ave|
			accumulated_averages += ave
		end
		
		@blekko_map= accumulated_averages / queries.count
		
		####################################################
		accumulated_averages=0
		@aggregatedP.each do |ave|
			accumulated_averages += ave
		end
		
		@aggregated_map= accumulated_averages / queries.count
		####################################################
		accumulated_averages=0
  	@entirewebP.each do |ave|
			accumulated_averages += ave
		end
		
		@entire_map= accumulated_averages / queries.count
		
  end
  
  def agg_map 
  	
  	
  end
end
