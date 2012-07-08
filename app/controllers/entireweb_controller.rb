class EntirewebController < ApplicationController
  def results
  	
  	
  	
  	#require 'rubygems'	# 
		require 'net/http'	# used to retrieve search results
		require 'erb'				# used to URL encode the query string
		require 'oj'				# used to convert json to ruby hash
		require 'cgi'				# used to unescape HTML in results
		require 'sanitize'	# used to remove HTML tags in results
		#require 'fileutils'

		query = ERB::Util.url_encode(params[:query])
			
			
		 #User account search key
		accountKey = "bf3b6752f636dc5ef50052ec9cc0f835"
		ip = "86.43.163.178"
				
		uri = URI("http://www.entireweb.com/xmlquery?pz=#{accountKey}&ip=#{ip}&q=Linux&n=10&format=json")
		
		output = nil
		
		Net::HTTP.start(uri.host, uri.port,	:use_ssl => uri.scheme == 'https') do |http|
			req = Net::HTTP::Get.new uri.request_uri
			response = http.request(req)  
			@output = response.body
		end
		
		
		#file = File.open("doc/entireweb_json")
		
		#@output = file.read
		
		@hash = Oj.load(@output)
		
		array = @hash["hits"]
		
		@length = array.inspect
		
			# converts alll the hash key -> value pairs to arrays for indexing
			#array.collect! {|item| item.each.to_a}

			array.each do |hash|
				hash["snippet"] = hash["snippet"]
				hash["url"] = hash["url"]
				hash["title"] = hash["title"]
			end
		
		#escaped_array = CGI.unescapeHTML(array)
		
		@items = Kaminari.paginate_array(array).page(params[:page]).per(5)
		
	
			#hash.each do |key|
				#keydelete("c", "display_url", "doc_date", "doc_date_iso", "n_group", "rss", "rss_title", "short_host", "short_host_url")
	end
end
