module GooglesHelper

	include ApplicationHelper
		def google_search(query)
			
		# Specify number of results to be returned
		num_results = 50
			
		 # User account search key
		accountKey = 'AIzaSyB6HspQ996ILEHtRb7f3BYytLCYCcCfXVA' 
		 # 
		uid = '015176245184235393172:u9sjjguudrm'
				

		
		# counter for addressing array position and assigning rank to each result 
		i = 0
		
		# Create our output object, an array for results hashes (created before loop)
			resHash = []
		
		#https://www.googleapis.com/customsearch/v1?start=&key=AIzaSyB6HspQ996ILEHtRb7f3BYytLCYCcCfXVA&cx=015176245184235393172:u9sjjguudrm&q=hello%20world&alt=json
		
		# loop starts at 1, steps 10 each iteration until 100 (10 times) for query results offset 
		1.step(100,10) do |offset|
			
			# URI for the API with variable interpolated
			uri = URI("https://www.googleapis.com/customsearch/v1?key=#{accountKey}&cx=#{uid}&q=#{query}&start=#{offset}&alt=json")
		
		
			# Start the HTTP request to the API
			Net::HTTP.start(uri.host, uri.port,	:use_ssl => uri.scheme == 'https') do |http|
				req = Net::HTTP::Get.new uri.request_uri
				response = http.request(req)  
				@output = response.body
			end
			
			# Use oj to convert the json to a ruby Hash
			hash = Oj.load(@output)
			
			# use only the part of the hash we need
			array = hash["items"]
			
			# Set unused object to nil
			#hash = nil
			
				
			# cycle through the results transfering only the parts we need into the new datastructure
			array.each do |hash|
				resHash << Hash.new
				resHash[i][:title] = hash["title"].nil? ? "--No Title Available--" : hash["title"]
				resHash[i][:description] = hash["snippet"].nil? ? "--No Description Available--" : hash["snippet"]
				resHash[i][:url] = hash["link"]
				resHash[i][:rank] = i+1
				i+=1
			end
	
			# Set unused object to nil
			#array = nil
	
			# return the array of hashes
			resHash
		end # end for loop
		# return the array of hashes
			resHash
	end
end
