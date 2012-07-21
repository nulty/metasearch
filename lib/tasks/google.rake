desc "Running search Queries for Entireweb (again!) in Result model"

task :run_google => :environment do
	
	query_number = 1
	
	
#	
#	
#	Query : cheap internet
#
#	Starting Google!
#off setting 1 results
#off setting 11 results
#off setting 21 results
#off setting 31 results
#off setting 41 results
#off setting 51 results
#off setting 61 results
#off setting 71 results
#off setting 81 results
#rake aborted!
#undefined method `each' for nil:NilClass

#Tasks: TOP => run_google

	
	File.open(Rails.root.join "lib/assets/queries").each_line do |line|

		require 'net/http'	# used to retrieve search results
		require 'oj'				# used to convert json to ruby hash
		require 'cgi'				# used to unescape HTML in results
		#require 'sanitize'	# used to remove HTML tags in results
		
		
		query = CGI.escape(line.strip)
		

		puts "Query : #{line.strip}"
				puts

				puts "\tStarting Google!"
		
				
			
		# Specify number of results to be returned
		num_results = 100
			
		 # User account search key
		accountKey = 'AIzaSyB6HspQ996ILEHtRb7f3BYytLCYCcCfXVA' 
		 
		uid = '015176245184235393172:u9sjjguudrm'
		
		#accountKey = "AIzaSyCYP56gAoI9whjO2lVk3_Ekyh18BfgOxf4" 
		#uid = "000964652424995737634:31gyregw0gw"
		
		#accountKey = "AIzaSyBhpYtc1PKw6q58R1Mv9Co3PXZZo7QdxDM" 
		#uid = "011951479472987328455:erppun2qifw"
		
		#accountKey = "AIzaSyBAWJet3l41qp6IoVUNnrP7z1xS-UwfI5k" 
		#uid = "012717166733205651491:c_s0yp5xudq"
		
		#accountKey = "AIzaSyA00RJUWOLTRNruPJ2H4Yi84pyb8fo6P8g" 
		#uid = "012290087398875969489:j3bslqhwba0"
		
		# (5) API "AIzaSyAQnKyJHilPajLmMMHKwP9Br-KxMgYdUnU" Engine "006118105857014670165:_ywp5knkc6g"
				
		
		# counter for addressing array position and assigning rank to each result 
		i = 0
		
		# Create our output object, an array for results hashes (created before loop)
		google_resHash = []
		
		#https://www.googleapis.com/customsearch/v1?start=&key=AIzaSyB6HspQ996ILEHtRb7f3BYytLCYCcCfXVA&cx=015176245184235393172:u9sjjguudrm&q=hello%20world&alt=json
		
		# loop starts at 1, steps 10 each iteration until 100 (10 times) for query results offset 
		1.step(100,10) do |offset|
			puts "off setting #{offset} results"
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
			hash = nil
			
				
			# cycle through the results transfering only the parts we need into the new datastructure
			array.each do |hash|
				google_resHash << Hash.new
				google_resHash[i][:title] = hash["title"].nil? ? "--No Title Available--" : hash["title"]
				google_resHash[i][:description] = hash["snippet"].nil? ? "--No Description Available--" : hash["snippet"]
				google_resHash[i][:url] = hash["link"]
				google_resHash[i][:rank] = i+1
				i+=1
			end
	
			# Set unused object to nil
			array = nil
	
			# return the array of hashes
			google_resHash
			
		end # end step loop

		
		puts "\tGoogle finished!"
		puts "\tStarting to Save! to Google!"
		
			
		
				
		#resArray = [[{:engine => "bing, :results => [{:Description => "abc", :Title => "def"}, {:Description => "ghi", :Title => "jkl"}]}, {etc},{etc} ],[{:eng...}]]
	
		
		# unescape for database entry
		query = CGI.unescape(query)

		

		
		Result.transaction do
			google_resHash.each do |result|
			if result[:title].empty?
				result[:title] = result[:description][0..15]
			end
			if result[:description].empty?
				result[:description] = result[:title]
			end
			
			res = Google.new( 
				:query_number => query_number,
				:query => query,
				:query_rank => result[:rank],
				:description => result[:description],
				:title => result[:title],
				:url => result[:url] )
				
			res.save!
			end
		end


		
		
		# increase the search count for the session
		query_number += 1

		puts "\tSaved! to results!"

		puts "Sleeping for 1 seconds. Just cause... "
		sleep 2
		puts
	end #queries loop
	
end
