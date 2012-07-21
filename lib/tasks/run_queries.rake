	
	



desc "Running search Queries for Result model"

task :run_Result => :environment do
	
	query_number = 1
	sess_id = "rake_task"
	
	queries = File.open(Rails.root.join "lib/assets/queries").each_line do |line|
			#require 'base64'		# used to authenticate API
		require 'net/http'	# used to retrieve search results
		require 'oj'				# used to convert json to ruby hash
		require 'cgi'				# used to unescape HTML in results
		require 'sanitize'	# used to remove HTML tags in results
		
		
		query = CGI.escape(line.strip)
		
		
		######## bing_search(query) ########
		########################################
		########################################
				puts "Query : #{query}"
				puts
		puts "\tStarting Bing "
		
		
			# Specify number of results to be returned
			num_results = 50
			 	#User account search key
			accountKey = '985J/RTtuuXX2IhwQzKH1acvEqkHYAD7CpnP3tdI1l8='            
				# counter for addressing array position and assigning rank to each result 
			i = 0
				# Create our output object, a hash
				bing_resHash = {:engine => "Bing",:results => []}

			0.step(50,50) do |offset|
				
					# URI for the API with variable interpolated
					uri = URI("https://api.datamarket.azure.com/Bing/Search/Web?$format=json&Query=%27#{query}%27&$top=#{num_results}&$skip=#{offset}")
					#https://api.datamarket.azure.com/Bing/Search/Web?$format=json&Query='dinosaurs'&$top=50&$skip=0
			
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
				#hash = nil
		
				# cycle through the results transfering only the parts we need into the new datastructure
				array.each do |hash|
					bing_resHash[:results] << Hash.new
					bing_resHash[:results][i][:title] = hash["Title"]
					bing_resHash[:results][i][:description] = hash["Description"]
					bing_resHash[:results][i][:url] = hash["Url"]
					bing_resHash[:results][i][:rank] = i+1
					i+=1
				end
			end
	
			# Set unused object to nil
			#array = nil
	
			# return the new object
			bing_resHash
		################################  end  ########
		################################
		################################
		
		puts "\tFinished Bing!"
		puts "\tStarting Blekko!"
		
		#################def blekko_search(query)
				################################################
				################################################
			 #User account search key
			accountKey = 'f4c8acf3'            
			
			# Specify number of results to be returned
			num_results = 100
					
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
			blekko_resHash={:engine => "Blekko", :results => [] }
			
			
			# counter for addressing array position and assigning rank to each result
			i = 0
				
			# cycle through the results transfering only the parts we need into the new datastructure
			#unless array.nil?
			
			array.each do |hash|
				blekko_resHash[:results] << Hash.new
				blekko_resHash[:results][i][:title] = CGI.unescapeHTML(Sanitize.clean(hash["url_title"].nil? ? "--No Title Available--" : hash["url_title"]))
				blekko_resHash[:results][i][:description] = CGI.unescapeHTML(Sanitize.clean(hash["snippet"].nil? ? "--No Description Available--" : hash["snippet"] ))
				blekko_resHash[:results][i][:url] = hash["url"]
				blekko_resHash[:results][i][:rank] = i+1
				i+=1
			end

	
			# Set unused object to nil
			array = nil
			
			# return the new object
			blekko_resHash
			
		############ end ###########
		############################
		
		puts "\tFinished Blekko!"
		puts "\tStarting Entireweb!"
		
		############ def entireweb_search(query) ##########
		###################################################
		###################################################
			
			
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
			entire_resHash={:engine => "Entireweb", :results => [] }
			
			# counter for addressing array position and assigning rank to each result
			i = 0
			
			# cycle through the results transfering only the parts we need into the new datastructure
			array.each do |hash|
				entire_resHash[:results] << Hash.new
				entire_resHash[:results][i][:title] = hash["title"].nil? ? "--No Title Available--" : hash["title"]
				entire_resHash[:results][i][:description] = hash["snippet"].nil? ? "--No Description Available--" : hash["snippet"]
				entire_resHash[:results][i][:url] = hash["url"]
				entire_resHash[:results][i][:rank] = i+1
				i+=1
			end
				
			# Set unused object to nil
			array = nil
			
			# return the new object
			entire_resHash	
		################ end ##########
		###############################
		###############################
		puts "\tFinished Blekko!"
		puts "\tStarting to Save! to results!"
		
			
		
				
		#resArray = [[{:engine => "bing, :results => [{:Description => "abc", :Title => "def"}, {:Description => "ghi", :Title => "jkl"}]}, {etc},{etc} ],[{:eng...}]]
	
		
		# unescape for database entry
		query = CGI.unescape(query)
		
		
		# method for collecting results of search from multiple engines - In ResultsHelper
		resArray = []
		resArray << bing_resHash 
		resArray<< entire_resHash 
		resArray<< blekko_resHash
		
		#results = []
		
		resArray.each do |engine|
			unless engine.nil?
				db_name = engine[:engine]
				Result.transaction do
				engine[:results].each do |result|
					if result[:title].empty?
						result[:title] = result[:description][0..15]
					end
					if result[:description].empty?
						result[:description] = result[:title]
					end
					
					res = Result.new(
						:session_id => sess_id, 
						:db_name => db_name,
						:query_number => query_number,
						:query => query,
						:query_rank => result[:rank],
						:description => result[:description],
						:title => result[:title],
						:url => result[:url] )
						
					res.save!
					end
				end
			end
		end
		
		
		# increase the search count for the session
		query_number += 1

		puts "\tSaved! to results!"

		puts "Sleeping for 10 seconds...Blekko! :| "
		sleep 10
		puts
	end #queries loop

end


