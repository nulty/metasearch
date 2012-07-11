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
  	
  	#max = Results.last.where
	
		respond_to do |format|
			format.html #{ redirect_to results_path(@bing, @blekko, @entireweb)}
		end
  	
	end
end
  
