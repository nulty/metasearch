module ResultsHelper
	
	require 'base64'		# used to authenticate API
	require 'net/http'	# used to retrieve search results
	require 'oj'				# used to convert json to ruby hash
	require 'cgi'				# used to unescape HTML in results
	require 'sanitize'	# used to remove HTML tags in results
	
	
	def getResults(par_bing, par_ent, par_blek, query)
		array = Array.new(3)
		threads = []
		
		 
				
			if par_bing
				threads << Thread.new {
					array[0] = bing_search(query)
					}
			end
	
			if par_ent
				threads << Thread.new{
					array[1] = entireweb_search(query)
				}
			end
	
			if par_blek
				threads << Thread.new {
					array[2] = blekko_search(query)
				}
			end
			
			threads.each { |aThread|  aThread.join }
			
		array
	end
	
	def bing_search(query)
			
		weight = 0.07194439651946019
		
		# Specify number of results to be returned
		num_results = 50
			
		 #User account search key
		accountKey = '985J/RTtuuXX2IhwQzKH1acvEqkHYAD7CpnP3tdI1l8='            

					
		# counter for addressing array position and assigning rank to each result 
		i = 0
			
		# Create our output object, a hash
		resHash = {:engine => "Bing",:results => []}
			
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
			array_size = array.size
	
			# cycle through the results transfering only the parts we need into the new datastructure
			array.each do |hash|
				resHash[:results] << Hash.new
				resHash[:results][i][:title] = hash["Title"].nil? ? "--No Title Available--" : hash["Title"]
				resHash[:results][i][:description] = hash["Description"].empty? ? "--No Description Available--" : hash["Description"]
				resHash[:results][i][:url] = hash["Url"]
				resHash[:results][i][:rank] = i+1
				raw_score = (1 - (((i+1)-1.0) / array_size))
				resHash[:results][i][:score] =(raw_score + (raw_score*weight)).round(4)
				i+=1
			end
		end

		# Set unused object to nil
		array = nil

		# return the new object
		resHash
	end
	
	def blekko_search(query)
			
		weight = 0.059700029899288215
			
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
		resHash={:engine => "Blekko", :results => [] }
		
		
		# counter for addressing array position and assigning rank to each result
		i = 0
			
		# cycle through the results transfering only the parts we need into the new datastructure
		array_size = array.size

			array.each do |hash|
				resHash[:results] << Hash.new
				resHash[:results][i][:title] = CGI.unescapeHTML(Sanitize.clean(hash["url_title"].nil? ? "--No Title Available--" : hash["url_title"]))
				resHash[:results][i][:description] = CGI.unescapeHTML(Sanitize.clean(hash["snippet"].nil? ? "--No Description Available--" : hash["snippet"] ))
				resHash[:results][i][:url] = hash["url"]
				resHash[:results][i][:rank] = i+1
				raw_score = (1 - (((i+1)-1.0) / array_size))
				resHash[:results][i][:score] = (raw_score + (raw_score*weight)).round(4)
				i+=1
			end
		

	# Set unused object to nil
		array = nil
		
		# return the new object
		resHash
		
	end
	
	def entireweb_search(query)
		
		weight = 0.038843882872345976
		
		 #User account search key
		accountKey = "bf3b6752f636dc5ef50052ec9cc0f835"
		
		# Specify number of results to be returned, **engine seems to return 5 extra for some reason....
		num_results = 95
		
		# IP address required by the API
		ip = "86.43.167.156"#"86.43.163.178"
				
		# URI for the API with variable interpolated
		uri = URI("http://www.entireweb.com/xmlquery?pz=#{accountKey}&ip=#{ip}&q=#{query}&n=#{num_results}&format=json")
		begin
		# Start the HTTP request to the API
		Net::HTTP.start(uri.host, uri.port,	:use_ssl => uri.scheme == 'https') do |http|
			req = Net::HTTP::Get.new uri.request_uri
			response = http.request(req)  
			@output = response.body
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
		
		
		array_size = array.size
		
		# cycle through the results transfering only the parts we need into the new datastructure
		array.each do |hash|
			resHash[:results] << Hash.new
			resHash[:results][i][:title] = hash["title"].nil? ? "--No Title Available--" : hash["title"]
			resHash[:results][i][:description] = hash["snippet"].nil? ? "--No Description Available--" : hash["snippet"]
			resHash[:results][i][:url] = hash["url"]
			resHash[:results][i][:rank] = i+1
			raw_score = (1 - (((i+1)-1.0) / array_size))
			resHash[:results][i][:score] =(raw_score + (raw_score*weight)).round(4)
			i+=1
		end
			
		# Set unused object to nil
		array = nil
		
		# return the new object
		resHash	
	rescue Exception => e
		
		flash[:engineerr] = "Entireweb has ceased to work"
		return nil
	end

	end
end
