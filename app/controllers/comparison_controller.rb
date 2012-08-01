class ComparisonController < ApplicationController
  include ComparisonHelper
  
  def single_query
  	
  	@title = "Individual Query Analysis"
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
			
			@engine.delete_if {|e| e.agg_rank > 100}
			
			
		else
			@engine = Result.select('url, query_rank').where("session_id=? AND db_name=? And query=?", @sess, engine, query).order('query_rank ASC').all
		end
		
  	# Retrieve all Google results for the selected query
  	@googleRes = Google.select('url, query_rank').where("query=?",query).order('query_rank ASC').all
  	
  	# array to contain all the relevant queries returned by the engine
  	@relevant = []
  	rel_count = 0
  	@ave_precision = 0
  	
  	# compares engines results to google and retreive the relevant results
  	#		Store the url, order of results along with the rank of the result
  	 
  	@engine.each do |eng| 
  		@googleRes.each do |g|
				if g.url == eng.url					
					rel_count += 1
					@relevant << [eng.url, rel_count, eng.agg_rank || eng.query_rank] # stores agg if aggregated
				end
			end
  	end
  	
  	@precision = ((rel_count / @engine.length.to_f)*100)
  	@recall = ((rel_count / @googleRes.length.to_f)*100)
  	
  	# how many of the top ten engine results are relevant (in Google results) 
  	top_10_rel = 0
  	@engine[0..9].each do |ten|
  		@googleRes.each do |rel|
  			if rel[:url] == ten[:url]
  				top_10_rel+=1
				end
  		end
  	end
  	
  	@P_at_10 = ((top_10_rel/10.0)*100)
  	
  	
  	precision_at =0
  	@relevant.each do |rel|
  		precision_at += ((rel[1] / rel[2].to_f))
  	end
  	
  	# relevant retrieved / relevant
  	@ave_precision = ((precision_at / @googleRes.size)*100).round(2)
   
  end

  
  
  
  def summary
  	
  	@title = "Mean Average Precision across engines"
		
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
		queries.each do |query|
		
			googleRes = Google.select('url, query_rank').where("query=?",query).order('query_rank ASC').all
			
			@bingP 				<< engine_sum(query, googleRes, sess, "Bing")
			@blekkoP 			<< engine_sum(query, googleRes, sess, "Blekko")
			@entirewebP 	<< engine_sum(query, googleRes, sess, "Entireweb")
			@aggregatedP 	<< agg_sum(query, googleRes, sess)
			
		
			
		end # queries loop
		
		
		accumulated_averages=0		
		@bingP.each do |ave|
			accumulated_averages += ave
		end
		
		@bing_map= ((accumulated_averages / queries.count)*100).round(2)
		
  	####################################################
  	
		accumulated_averages=0		
		@blekkoP.each do |ave|
			accumulated_averages += ave
		end
		
		@blekko_map= ((accumulated_averages / queries.count)*100).round(2)
		
		####################################################
		
		accumulated_averages=0
		@aggregatedP.each do |ave|
			accumulated_averages += ave
		end
		
		@aggregated_map= ((accumulated_averages / queries.count)*100).round(2)
		
		####################################################
		accumulated_averages=0
  	@entirewebP.each do |ave|
			accumulated_averages += ave
		end
		
		@entire_map= ((accumulated_averages / queries.count)*100).round(2)
		
  end
  
end
