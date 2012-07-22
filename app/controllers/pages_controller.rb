class PagesController < ApplicationController
	include PagesHelper
	
	def index
		@sessid = request.session[:session_id]
  	 
		
		#respond_to do |format|
		#	if params[:query].empty?
		#		format.html { redirect_to pages_path(params[:query]), :flash => "query cannot be blank" }
		#	else
		#		format.html { redirect_to results_path}
		#	end
		#end
			
	
  end

  def cluster  
  end
  
  def results
  	
  	sessionid = request.session[:session_id]
  	
  	max = Result.where("session_id = ? ", sessionid).maximum("query_number")
  	
  	
  	# num of characters the description of results is truncated to in the view
  	# for all search results
  	@trunc = 150
  	
  	
  	# These three instance variables populate the view with the data from the database.
  	bing = Result.where('db_name = ? and session_id = ? and query_number =?', "Bing", sessionid, max).order("query_rank ASC")
  	blekko = Result.where('db_name = ? and session_id = ? and query_number =?', "Blekko", sessionid, max).order("query_rank ASC")
  	entireweb = Result.where('db_name = ? and session_id = ? and query_number =?', "Entireweb", sessionid, max).order("query_rank ASC")
  	
  	@bing				= bing.empty? ? nil : bing.page(params[:page]).per(10)
  	@blekko			= blekko.empty? ? nil : blekko.page(params[:page]).per(10)
  	@entireweb	= entireweb.empty? ? nil : entireweb.page(params[:page]).per(10)
  	
  	@lastquery = Result.select(:query).where('session_id = ?', sessionid).last

  	@queries = Result.select("query,query_number").uniq.where('session_id = ?', sessionid).order("query_number DESC").first(5)
  	
  	@num_of_queries = Result.select(:query).uniq.where('session_id = ?', sessionid).all.count

  	
		respond_to do |format|
			format.html #{ redirect_to results_path(@bing, @blekko, @entireweb)}
		end
  	
	end
	
	def aggregated
		
		
		# weighting attached to each search engine based on the trial queries
		bing_weight = 0.44
		blekko_weight = 0.26
		entire_weight = 0.31
		
		# session_id for the test queries
  	sessionid =  request.session[:session_id]
  	
  	if params[:query].nil?
  		query_num = Result.where("session_id = ? ", sessionid).maximum("query_number")
  	else
  		query_num = params[:query]
  	end
  	
  	
  	
  	
  	# num of characters the description of results is truncated to in the view
  	# for all search results
  	@trunc = 150
  	
  	group = []
  	
  	# These three instance variables populate the view with the data from the database.
  	bing_res = Result.where('db_name = ? and session_id = ? and query_number =?', "Bing", sessionid, query_num).order("query_rank ASC")
  	blekko_res = Result.where('db_name = ? and session_id = ? and query_number =?', "Blekko", sessionid, query_num).order("query_rank ASC")
  	entire_res = Result.where('db_name = ? and session_id = ? and query_number =?', "Entireweb", sessionid, query_num).order("query_rank ASC")
  	
  	bing_res.each do |res|
  		r = res.serializable_hash
  		raw_score = (1 - ((res["query_rank"]-1.0) / bing_res.count))
  		r[:score] = (raw_score + (raw_score*bing_weight)).round(4)
  		group << r
  	end
  		
  	entire_res.each do |res|
  		r = res.serializable_hash
  		raw_score = (1 - ((res["query_rank"]-1.0) / entire_res.count))
  		r[:score] = (raw_score + (raw_score*entire_weight)).round(4)		 
  		group<< r
  	end
  	
  	blekko_res.each do |res|
  		r = res.serializable_hash
  		raw_score = (1 - ((res["query_rank"]-1.0) / blekko_res.count))
  		r[:score] = (raw_score + (raw_score*blekko_weight)).round(4)
  		group << r
  	end
  	
  	#raw_score = RankSim(rank) = 1 - (rank-1/results_count)
  	#score = raw_score + (raw_score*weight)
  	
  	
  	#@bing				= group[:bing].empty? ? nil : group[:bing].page(params[:page]).per(10)
  	#@blekko			= blekko.empty? ? nil : blekko.page(params[:page]).per(10)
  	#@entireweb	= entireweb.empty? ? nil : entireweb.page(params[:page]).per(10)
  	
  	@lastquery = Result.select(:query).where('session_id = ?', sessionid).last
  	
  	# gets last 5 queries associated with the users session so they can go back to their older queries
  	@queries = Result.select("query,query_number").uniq.where('session_id = ?', sessionid).order("query_number DESC").first(5)
  	
  	group.sort_by! { |hsh| hsh[:score] } 
  	
  	@num_of_queries = Result.select(:query).uniq.where('session_id = ?', sessionid).all.count

  	@agg = Kaminari.paginate_array(group.reverse).page(params[:page]).per(10)
  	
		respond_to do |format|
			format.html #{ redirect_to results_path(@bing, @blekko, @entireweb)}
		end
		
	end
end
  
