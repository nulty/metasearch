module ResultsHelper
	
	require 'base64'		# used to authenticate API
	require 'net/http'	# used to retrieve search results
	require 'oj'				# used to convert json to ruby hash
	require 'cgi'				# used to unescape HTML in results
	require 'sanitize'	# used to remove HTML tags in results
	require 'erb'				# used to URL encode the query string
	
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
	
	def getResults(par_bing, par_ent, par_blek, query)
		array = Array.new(3)
		
		if par_bing
  		array[0] = bing_search(query)
  	end

		if par_ent
			array[1] = entireweb_search(query)
		end

		if par_blek
			array[2] = blekko_search(query)
		end

		array
	end
	
	def bing_search(query)
			
		# Specify number of results to be returned
		num_results = 50
			
		 #User account search key
		accountKey = '985J/RTtuuXX2IhwQzKH1acvEqkHYAD7CpnP3tdI1l8='            
				
		# URI for the API with variable interpolated
		uri = URI("https://api.datamarket.azure.com/Bing/Search/Web?$format=json&Query='#{query}'&$top=#{num_results}")

		# Start the HTTP request to the API
		Net::HTTP.start(uri.host, uri.port,	:use_ssl => uri.scheme == 'https') do |http|
			req = Net::HTTP::Get.new uri.request_uri
			req.basic_auth '', accountKey
			response = http.request(req)  
			@output = response.body
		end
		
		# Use oj to convert the json to a ruby Hash
		hash = Oj.load(@output)
		
		# use only the part of the hash we need
		array = hash["d"]["results"]
		
		# Set unused object to nil
		hash = nil
		
		# Create our output object, a hash
		resHash = {:engine => "Bing",:results => []}
		
		# counter for addressing array position and assigning rank to each result 
		i = 0

		# cycle through the results transfering only the parts we need into the new datastructure
		array.each do |hash|
			resHash[:results] << Hash.new
			resHash[:results][i][:title] = CGI.unescapeHTML(Sanitize.clean(hash["Title"]))
			resHash[:results][i][:description] = CGI.unescapeHTML(Sanitize.clean(hash["Description"]))
			resHash[:results][i][:url] = hash["Url"]
			resHash[:results][i][:rank] = i+1
			i+=1
		end

		# Set unused object to nil
		array = nil

		# return the new object
		resHash
	end
	
	def blekko_search(query)
			
			
		 #User account search key
		accountKey = 'f4c8acf3'            
		
		# Specify number of results to be returned
		num_results = 50
				
		# URI for the API with variable interpolated
		uri = URI("http://blekko.com/ws/?q='#{query}'+/json+/ps=#{num_results}&auth=#{accountKey}")
		
		# Start the HTTP request to the API
		Net::HTTP.start(uri.host, uri.port,	:use_ssl => uri.scheme == 'https') do |http|
			req = Net::HTTP::Get.new uri.request_uri
			response = http.request(req)  
			@output = response.body
		end

		# Use oj to convert the json to a ruby Hash
		hash = Oj.load(@output)
		
		# use only the part of the hash we need
		array = hash["RESULT"]
		
		# Set unused object to nil
		hash = nil
		
		# Create our output object, a hash
		resHash={:engine => "Blekko", :results => [] }
		
		
		# counter for addressing array position and assigning rank to each result
		i = 0
			
		# cycle through the results transfering only the parts we need into the new datastructure
		array.each do |hash|
			resHash[:results] << Hash.new
			resHash[:results][i][:title] = CGI.unescapeHTML(Sanitize.clean(hash["url_title"]))
			resHash[:results][i][:description] = CGI.unescapeHTML(Sanitize.clean(hash["snippet"]))
			resHash[:results][i][:url] = hash["url"]
			resHash[:results][i][:rank] = i+1
			i+=1
		end

	# Set unused object to nil
		array = nil
		
		# return the new object
		resHash
		
	end
	
	def entireweb_search(query)
		
		
		 #User account search key
		accountKey = "bf3b6752f636dc5ef50052ec9cc0f835"
		
		# Specify number of results to be returned
		num_results = 50
		
		# IP address required by the API
		ip = "86.43.163.178"
				
		# URI for the API with variable interpolated
		uri = URI("http://www.entireweb.com/xmlquery?pz=#{accountKey}&ip=#{ip}&q=#{query}&n=#{num_results}&format=json")
				
		# Start the HTTP request to the API
		Net::HTTP.start(uri.host, uri.port,	:use_ssl => uri.scheme == 'https') do |http|
			req = Net::HTTP::Get.new uri.request_uri
			response = http.request(req)  
			@output = response.body
			#output
		end
		
		# Use oj to convert the json to a ruby Hash
		hash = Oj.load(@output)
		
		# use only the part of the hash we need
		array = hash["hits"]
		
		# Set unused object to nil
		hash = nil
		
		# Create our output object, a hash
		resHash={:engine => "Entireweb", :results => [] }
		
		# counter for addressing array position and assigning rank to each result
		i = 0
		
		# cycle through the results transfering only the parts we need into the new datastructure
		array.each do |hash|
			resHash[:results] << Hash.new
			resHash[:results][i][:title] = hash["title"]
			resHash[:results][i][:description] = hash["snippet"]
			resHash[:results][i][:url] = hash["url"]
			resHash[:results][i][:rank] = i+1
			i+=1
		end
			
		# Set unused object to nil
		array = nil
		
		# return the new object
		resHash	
	

end
end
