class PagesController < ApplicationController
  require 'erb'
  
  include ERB::Util
	
	def index
  	 @query = url_encode(params['query'])
  	 
  	 #respond_to do |format|
  	 #	 if params['query']
  	 #		format.html { redirect_to('/pages/cluster', :notice => "Sorry, that Race has been suspended")  }
  	 #	end
  	 #end
  end

  def cluster
  	  
  end
  
  
  
  
  
end
