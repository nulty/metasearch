class PagesController < ApplicationController
	include PagesHelper
	
	def index
  	 
  ############################################################################	 
	#	respond_to do |format|
	#		if params[:query].empty?
	#			format.html { redirect_to results_path(@bing, @blekko, @entireweb)}
	#		else
	#			format.html { redirect_to(:back, :notice => "query cannot be blank")}
	#		end
	#		
	############################################################################
  end

  def cluster  
  end
  
  def results
  	
  	
  	@query = query_preprocesser(params[:query])

  	if params[:bing]
  		@bing = bing_search(@query)
  	end

		if params[:entireweb]
			@entireweb = entireweb_search(@query)
		end

		if params[:blekko]
			@blekko = blekko_search(@query)
		end
	
		respond_to do |format|
			format.html #{ redirect_to results_path(@bing, @blekko, @entireweb)}
		end
  	
	end
end
  
