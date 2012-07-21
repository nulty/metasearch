class ComparisonController < ApplicationController
  #include ComparisonHelper
  
  def single_query
  	
  	engine = params[:engine].nil? ? "Bing" : params[:engine]
  	query = params[:query].nil? ? "obama family tree" : params[:query]
  	
  	
  	@sess = "rake_task"
  	#query = "dinosaurs"
  	#db_name = "Bing"
  	@db_names = []
  	@queries = []
  	
  	Result.select(:query).where(:session_id => @sess).uniq.each {|r| @queries << r.query}
  	Result.select(:db_name).uniq.each {|r| @db_names << r.db_name}
  	
  	
  	
  	@bing = Result.select('url, query_rank').where("session_id=? AND db_name=? And query=?", @sess, engine, query).order('query_rank ASC').all
  		
  	@googleRes = Google.select('url, query_rank').where("query=?",query).order('query_rank ASC').all
  	
  	#for item in @googleRes do |google|
  	
  	@relevant = []
  	@count = 0
  	@ave_precision = 0
  	
  	@bing.each do |bing| 
  		@googleRes.each do |g|
				if g.url == bing.url
					@relevant << [bing.url, bing.query_rank, g.query_rank]
					@count += 1
				end
			end
  	end
  	
  	@precision = ((@count/@bing.length.to_f)*100).to_i
  	@recall = ((@count/@googleRes.length.to_f)*100).to_i
  	
  	@P_at_10 = @relevant.take_while {|r| r[1] <= 10  }
  	@P_at_10 = ((@P_at_10.size.to_f/10)*100).to_i
  	
  	running_score =0
  	@relevant.each do |rel|
  		running_score += ((rel[1] / rel[2].to_f)*100).to_i
  	end
  	
  	@ave_precision = (running_score / @googleRes.size)
 


 		
#  	@db_names = []
#  	
#  	Result.select(:db_name).uniq.each {|r| @db_names << r.db_name}
#  	
#  	
# 	
#  	@bing = Result.select('url, query_rank').where("session_id=? AND db_name=? And query=?", @sess, "Bing", query).order('query_rank ASC').all
#  		
#  	@googleRes = Google.select('url, query_rank').where("query=?",query).order('query_rank ASC').all
#  	
#  	#for item in @googleRes do |google|
#  	
#  	stats = statistics(engine, query)
#  	@relevant = stats[:rel]
#  	@count = stats[:rel_count]
#  	@precision = stats[:precision]
#  	@recall = stats[:recall]
#  	
#  	@P_at_10 = stats[:p10]
#  	
#  	
#  	@ave_precision = stats[:ave_prec]
#  	
  	
  	
  
  end

  def summary
  	
  	sess = "rake_task"
  	
  	db_names = []
  	queries = []
  	
  	Google.select(:query).uniq.each {|r| queries << r.query}
  	Result.select(:db_name).uniq.each {|r| db_names << r.db_name}
  	@bingP=[]
  	@blekkoP =[]
  	@entirewebP =[]
  	
  	queries.each do |q|
			@bing = Result.select('url, query_rank').where("session_id=? AND db_name=? AND query=?", sess, "Bing", q).order('query_rank ASC').all
			@blekko = Result.select('url, query_rank').where("session_id=? AND db_name=? AND query=?", sess, "Blekko", q).order('query_rank ASC').all
			@entireweb = Result.select('url, query_rank').where("session_id=? AND db_name=? AND query=?", sess, "Entireweb", q).order('query_rank ASC').all
			@googleRes = Google.select('url, query_rank').where("query=?",q).order('query_rank ASC').all
		
		
			@bing_relevant = []
			@bing_count = 0
			@bing_ave_precision = 0
			
			@bing.each do |bing| 
				@googleRes.each do |g|
					if g.url == bing.url
						@bing_relevant << [bing.url, bing.query_rank, g.query_rank]
						@bing_count += 1
					end
				end
			end
			
			bing_running_score =0
			@bing_relevant.each do |rel|
				bing_running_score += ((rel[1] / rel[2].to_f)*100).to_i
			end
			
			@bing_ave_precision = (bing_running_score / @googleRes.size)	## error divide by zero ##
			@bingP << @bing_ave_precision
			
			###################################################
			
			@blekko_relevant = []
			@blekko_count = 0
			@blekko_ave_precision = 0
			
			@blekko.each do |blekko| 
				@googleRes.each do |g|
					if g.url == blekko.url
						@blekko_relevant << [blekko.url, blekko.query_rank, g.query_rank]
						@blekko_count += 1
					end
				end
			end
			
			blekko_running_score =0
			@blekko_relevant.each do |rel|
				blekko_running_score += ((rel[1] / rel[2].to_f)*100).to_i
			end
			
			@blekko_ave_precision = (blekko_running_score / @googleRes.size)
			
			@blekkoP << @blekko_ave_precision
			################################################
			
			@entire_relevant = []
			@entire_count = 0
			@entire_ave_precision = 0
			
			@entireweb.each do |entire| 
				@googleRes.each do |g|
					if g.url == entire.url
						@entire_relevant << [entire.url, entire.query_rank, g.query_rank]
						@entire_count += 1
					end
				end
			end
			
			entire_running_score =0
			@entire_relevant.each do |rel|
				entire_running_score += ((rel[1] / rel[2].to_f)*100).to_i
			end
			
			@entire_ave_precision = (entire_running_score / @googleRes.size)
		
			@entirewebP << @entire_ave_precision
		end # queries loop
		
		
		
		
		score=0
		@bingP.each do |ave|
			score += ave
		end
		
		@bing_map= score/queries.count
  	
		score=0
		@blekkoP.each do |ave|
			score += ave
		end
		@blekko_map= score/queries.count
		
		score=0
  	@entirewebP.each do |ave|
			score += ave
		end
		@entire_map= score/queries.count
		
  end
end
