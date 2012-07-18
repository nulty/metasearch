module ApplicationHelper
	
	#require 'uri'				# used to URL encode the query string
	require 'cgi'
	
	
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
		
		#query.gsub("\"", "\"")
		#query.join " "
		
		#query = u params['query']
		query = CGI::escape params['query']
		query
			
	end
	
end
