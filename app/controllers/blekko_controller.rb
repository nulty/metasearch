class BlekkoController < ApplicationController
  
	def results
  
		#require 'rubygems'	# 
		require 'net/http'	# used to retrieve search results
		require 'erb'				# used to URL encode the query string
		require 'oj'				# used to convert json to ruby hash
		require 'cgi'				# used to unescape HTML in results
		require 'sanitize'	# used to remove HTML tags in results
		#require 'fileutils'

		#query = ERB::Util.url_encode(params[:query])
			
			
		 #User account search key
		#accountKey = 'f4c8acf3'            
				
		#uri = URI("http://blekko.com/ws/?q='#{query}'+/json&auth=#{accountKey}")
		
		#output = nil
		
		#Net::HTTP.start(uri.host, uri.port,	:use_ssl => uri.scheme == 'https') do |http|
		#	req = Net::HTTP::Get.new uri.request_uri
		#	response = http.request(req)  
		#	@output = response.body
		#end
		
		
		file = File.open("doc/blekko_json")
		
		@output = file.read
		
		@hash = Oj.load(@output)
		
		array = @hash["RESULT"]
		
		@length = array.inspect
		
			# converts alll the hash key -> value pairs to arrays for indexing
			#array.collect! {|item| item.each.to_a}

			array.each do |hash|
				hash["snippet"] = CGI.unescapeHTML(Sanitize.clean(hash["snippet"]))
				hash["url"] = CGI.unescapeHTML(Sanitize.clean(hash["url"]))
				hash["url_title"] = CGI.unescapeHTML(Sanitize.clean(hash["url_title"]))
			end
		
		#escaped_array = CGI.unescapeHTML(array)
		
		@items = Kaminari.paginate_array(array).page(params[:page]).per(5)
		
	
			#hash.each do |key|
				#keydelete("c", "display_url", "doc_date", "doc_date_iso", "n_group", "rss", "rss_title", "short_host", "short_host_url")
	end
  
end
