desc "Running search Queries for Result model"

task :run_Result => :environment do
	
		#require 'base64'		# used to authenticate API
	require 'net/http'	# used to retrieve search results
	require 'oj'				# used to convert json to ruby hash
	require 'cgi'				# used to unescape HTML in results
	require 'sanitize'	# used to remove HTML tags in results

	File.open()
