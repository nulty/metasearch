class BingController < ApplicationController
	
	def results
	
		require "base64"		# used to authenticate API
		require 'net/http'	# used to retrieve search results
		require 'erb'				# used to URL encode the query string 
		require 'oj'				# used to convert json to ruby hash
		#require 'fileutils'

		#query = ERB::Util.url_encode(params[:query])
			
			
		 #User account search key
		#accountKey = '985J/RTtuuXX2IhwQzKH1acvEqkHYAD7CpnP3tdI1l8='            
				
		#uri = URI("https://api.datamarket.azure.com/Bing/Search/Web?$format=json&Query='#{query}'")
		
		#output = nil
		
		#Net::HTTP.start(uri.host, uri.port,	:use_ssl => uri.scheme == 'https') do |http|
		#	req = Net::HTTP::Get.new uri.request_uri
		#	req.basic_auth '', accountKey
		#	response = http.request(req)  
		#	@output = response.body
		#end
		
		
		file = File.open("doc/sample_Json")
		
		@output = file.read
		
		@hash = Oj.load(@output)
		
		array = @hash["d"]["results"]
		
		@items = Kaminari.paginate_array(array).page(params[:page]).per(5)
		
		#respond_to do |format|
		#	format.html # index.html.erb
		#	format.json { render :json => @output}
		#end
		
		
		
		#require 'oauth2'
		
		#client = OAuth2::Client.new('x10207490', 'kZfSD2/4foxF9ybzIEeigMoOgu3sVGffCtVecEFmVyA=', :site => 'https://api.datamarket.azure.com/Bing/Search/', :authorize_url => 'embedded/consent')

		
		#client.auth_code.authorize_url(:redirect_uri => 'http://localhost:3000/results')
		# => "https://example.org/oauth/authorization?response_type=code&client_id=client_id&redirect_uri=http://localhost:8080/oauth2/callback"
		
		#token = client.auth_code.get_token('', :redirect_uri => 'http://localhost:3000/results', :headers => {'Authorization Basic ' => '985J/RTtuuXX2IhwQzKH1acvEqkHYAD7CpnP3tdI1l8='})
		#response = token.get('Bing/Search/Web/?', :params => { 'Query' => @query, '$top' => '50' })
		#@rname = response.class.name
		# => OAuth2::Response
		
		
		#W&Options=%27EnableHighlighting%27&Adult=%27Moderate%27&$top=50&$format=json
		
		
		
		#require 'rubygems'
		#require 'rbing'
		
		#bing = RBing.new("985J/RTtuuXX2IhwQzKH1acvEqkHYAD7CpnP3tdI1l8=")

		#@rbing = RBing.new
	
		#rsp = bing.web("Obama's family tree")
		
		#title = rsp.results[0].title
	
		#@rbing.url_title =  title
  	
  	#@query = url_encode(params['query'])
  	
  	# User account search key
    #@accountKey = '985J/RTtuuXX2IhwQzKH1acvEqkHYAD7CpnP3tdI1l8=';            
    
    # Url of the search API where results will be attained
    #@ServiceRootURL =  'https://api.datamarket.azure.com/Bing/Search/Web/';                    
    
    #@WebSearchURL = @ServiceRootURL << '' << @query;
		
	end
	
	
	def test
		
		@output = {}

	end
	
	
end
