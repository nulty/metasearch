class PagesController < ApplicationController
  require 'erb'
  
  include ERB::Util
	
	def index
  	 @query = params['query']
  	 
  	 #respond_to do |format|
  	 #	 if params['query']
  	 #		format.html { redirect_to('/pages/cluster', :notice => "Sorry, that Race has been suspended")  }
  	 #	end
  	 #end
  end

  def cluster
  	  
  end
  
  def results
  	@query = url_encode(params['query'])
  	  
  end
  
  def search
  	
  	@query = url_encode(params['query'])
  	
  	# User account search key
    @accountKey = '985J/RTtuuXX2IhwQzKH1acvEqkHYAD7CpnP3tdI1l8=';            
    
    # Url of the search API where results will be attained
    @ServiceRootURL =  'https://api.datamarket.azure.com/Bing/Search/Web/';                    
    
    @WebSearchURL = @ServiceRootURL << 'Web?$format=json&Query=' << @query;
  end
  
end
