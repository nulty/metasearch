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

  	
  	@num_of_queries = Result.select(:query).uniq.where('session_id = ?', sessionid).all.count

  	
		respond_to do |format|
			format.html #{ redirect_to results_path(@bing, @blekko, @entireweb)}
		end
  	
	end
end
  
