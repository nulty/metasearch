module PagesHelper
	  	
  	
	#require 'rubygems'	# 
	require 'base64'		# used to authenticate API
	require 'net/http'	# used to retrieve search results
	require 'erb'				# used to URL encode the query string
	require 'oj'				# used to convert json to ruby hash
	require 'cgi'				# used to unescape HTML in results
	require 'sanitize'	# used to remove HTML tags in results
	#require 'fileutils'
	
	include ERB::Util
	
	
	
	def query_preprocesser(query)
				
		##################################################################
		#
		#			Stop words don't seem relevant as they are used by all search engines
		#			http://insidesearch.blogspot.ie/2012/04/search-quality-highlights-50-changes.html
		#
		#
		#
		# 		## Loads the stopwords into memory ##
		#		stopwords = File.open("app/assets/stopwords").read.gsub("\n", " ")
		#
		#	 		## deletes the stopwords from the query ##
		#
		#  	query.downcase.split(" ").delete_if {|word| list.include? word }
		#  	query.join " "
		##################################################################
		
		
		query = u params['query']
		query
			
	end
	
	def bing_search(query)
			
			
		 #User account search key
		accountKey = '985J/RTtuuXX2IhwQzKH1acvEqkHYAD7CpnP3tdI1l8='            
				
		uri = URI("https://api.datamarket.azure.com/Bing/Search/Web?$format=json&Query='#{query}'&$top=50")
		
		output = nil
		
		Net::HTTP.start(uri.host, uri.port,	:use_ssl => uri.scheme == 'https') do |http|
			req = Net::HTTP::Get.new uri.request_uri
			req.basic_auth '', accountKey
			response = http.request(req)  
			@output = response.body
		end
		
		
		@hash = Oj.load(@output)
		
		array = @hash["d"]["results"]
		
		
		simpleArr = []
		#array.each do |hash|
		#	 hash["Description"] = CGI.unescapeHTML(Sanitize.clean(hash["Description"]))
		#	 hash["Url"] = CGI.unescapeHTML(Sanitize.clean(hash["Url"]))
		#	 hash["Title"] = CGI.unescapeHTML(Sanitize.clean(hash["Title"]))
		#end
		#@batch=array
		
		
		@items
		
	end
	
	def blekko_search(query)
			
			
		 #User account search key
		accountKey = 'f4c8acf3'            
				
		uri = URI("http://blekko.com/ws/?q='#{query}'+/json&auth=#{accountKey}")
		
		output = nil
		
		Net::HTTP.start(uri.host, uri.port,	:use_ssl => uri.scheme == 'https') do |http|
			req = Net::HTTP::Get.new uri.request_uri
			response = http.request(req)  
			@output = response.body
		end

		
		@hash = Oj.load(@output)
		
		array = @hash["RESULT"]
		
		#@length = array.inspect
		
		simpleArr = []
		
			# converts alll the hash key -> value pairs to arrays for indexing
			#array.collect! {|item| item.each.to_a}

		array.each do |hash|
			simpleArr << hash["Description"] = CGI.unescapeHTML(Sanitize.clean(hash["snippet"]))
			simpleArr << hash["Url"] = CGI.unescapeHTML(Sanitize.clean(hash["url"]))
			simpleArr << hash["Title"] = CGI.unescapeHTML(Sanitize.clean(hash["url_title"]))
		end
	
		array = nil
		
		@items = Kaminari.paginate_array(simpleArr).page(params[:page]).per(10)
		
		@items
		
	end
	
	def entireweb_search(query)
		
		
		 #User account search key
		accountKey = "bf3b6752f636dc5ef50052ec9cc0f835"
		ip = "86.43.163.178"
				
		uri = URI("http://www.entireweb.com/xmlquery?pz=#{accountKey}&ip=#{ip}&q=#{query}&n=10&format=json")
		
		output = nil
		
		Net::HTTP.start(uri.host, uri.port,	:use_ssl => uri.scheme == 'https') do |http|
			req = Net::HTTP::Get.new uri.request_uri
			response = http.request(req)  
			@output = response.body
		end
		
		@hash = Oj.load(@output)
		
		array = @hash["hits"]
		
		@length = array.inspect
		
		simpleArr = []
		
		array.each do |hash|
			simpleArr << hash["Description"] = hash["snippet"]
			simpleArr << hash["Url"] = hash["url"]
			simpleArr << hash["Title"] = hash["title"]
		end
			
		@items = Kaminari.paginate_array(simpleArr).page(params[:page]).per(10)
		
		@items
	
	end
	
end
