# encoding: utf-8
class PagesController < ApplicationController
	include Math
	include PagesHelper
	
	def index
		@title = "Home"
		
		#request.session[:session_id] = "rake_task"
  		
  end

  def cluster
  	
  	@title = "Clustered Results"
  	
  	#sessionid = "rake_task"#
  	sessionid = request.session[:session_id]
  	
		@query ||= params[:query].nil? ? Result.select(:query).where(:session_id => sessionid).last.query : Result.select(:query).where(:query_number => params[:query]).first.query 
		
		
		
		
		@queries = Result.select("query, query_number").where(:session_id => sessionid).uniq(:query).order("query_number DESC").limit(5)
		@query_number = params[:query].nil? ? Result.where("session_id = ? ", sessionid).maximum("query_number") : params[:query]
		#query_number 
		# all results for current query
		
		## 			Get all results for the query, 
		##							limited to save time, 
		##							remove duplicate urls, 
		##							loop results
		##								extract processed cluster phrases from the description
		##								create vectors for each phrase for each description
		##								reassemble descriptions and store in variable
		##							Get most frequent phrase for tf
		
		@results = Result.where(:query_number => @query_number, :session_id => sessionid).order("score DESC")
		
		
		urls=[]
		# removes results with duplicate urls from the but leaves the result with the highest score 
		@results.delete_if do |item|
			if urls.include? item[:url]
				true
			else
				urls << item[:url]
				false
			end
		end
		
		
		urls=nil
		
		documents = []
		
		file = File.open(Rails.root.join("app/assets/stopwords")).read.split
		
		@results.first.query.split.each {|word_q| file << word_q} 
		
		# add pluralized / singularized query terms to end of stopwords
		@results.first.query.split.each {|word_q| file << word_q.pluralize; file << word_q.singularize}
		
		
		doc_collection =[]
		
		
		@results.each do |result|
			
			result_phrases=[]
			
			(1..4).each do |c|
				# remove characters and stopwords from the descriptions
				result.description.downcase.gsub(/["•\[\]{}~:;|!?*+().,”“]/, "").gsub(/(\s-\s)/, " ").split.each_cons(c) {|phrase| result_phrases << phrase}
			end
			
			
			# delete if phrase starts or ends with a stopword 
			result_phrases.delete_if {|a| (file.include?(a.last) || file.include?(a.first) )}
			
			# create a hash of the results with a hash of the words and frequencies
			# {:url=> r.url, :phrases => {"carrot" => 2, "cup" => 3}}
			doc_term_freq = {:url=> result.url, :phrases => {}}
			
			# create hash of result with hashes of {term => frequency}
			result_phrases.each do |phrase|
				if doc_term_freq[:phrases].has_key? phrase
					doc_term_freq[:phrases][phrase] += 1.0
				else
					doc_term_freq[:phrases][phrase] = 1.0
				end
			end
			
			
			# add the documents with term frequencies to doc_collection array
			doc_collection << doc_term_freq
			
			result.description = result_phrases.join(" ")
			documents << result
		end
		
		# now we've got a structure that has word and word count associated with that document.
		# we then get the highest frequency of any word to normalize the word frequencies i.e, (0...1)
		
		
		max_frequency_phrase = 0.0
		doc_collection.each do |doc_term_freq|
			doc_term_freq[:phrases].each_value {|count| max_frequency_phrase = count if count > max_frequency_phrase}
		end
		
		# here we want to get a count of the document frequency of the terms
		
		
		top_doc_freq={}
		doc_collection.each do |doc_term_freq|
			
			doc_term_freq[:phrases].each do |term, count| 
					# normalizing term frequency by dividing max occurance by term frequency
					if count > 2
						count = count / max_frequency_phrase
						top_doc_freq.merge!({term =>0}) unless top_doc_freq.has_key? term or count < 0.4 or term.nil?
					end
			end
		end
		
		
		#top_doc_freq.delete_if {|term| }
		top_doc_freq.each do |term, count|
			documents.each do |doc|
				if doc.description.match term.join(" ")
					top_doc_freq[term] +=1.0
				end
			end
		end
		
		num_of_docs = documents.size
		
		# create Inverse document frequency
		top_doc_freq.map do |a,b| 
			puts "top_doc_freq[a] = log(num_of_docs/b) : #{top_doc_freq[a]} = #{log(num_of_docs/b)}" 
			top_doc_freq[a] = log(num_of_docs/b)
			
		end
		
		top_doc_freq.sort_by {|a,b| b}.reverse
		
		
		
		# create cluster structure that contains the cluster labels with associated results array
		clusters = {}
		top_doc_freq.each do |phrase|
			clusters.store(phrase[0], [])
		end
		clusters.store(["other"], [])
			
		# go through each of the documents and add to the cluster that matches the phrase.
		# if a document matches no phrase put it in the "other" cluster
		documents.each do |doc|
			matched_flag = 0
			top_doc_freq.each do |phrase|
				if doc.description.downcase.match(phrase[0].join(" "))
					clusters[phrase[0]] << doc.id
					matched_flag = 1
				end
			end
			clusters[["other"]] << doc.id if matched_flag == 0
		end
	

		#clusters.each do |instance|
			#instance
			
			if params[:label]
				cresults = []
				Result.transaction do
					clusters[ params[:label].split ].each do |id|
						cresults << Result.where("id=?", id).first
					end
				end
				cresults.sort {|a,b| a[1] <=> b[1]}
				@results = Kaminari.paginate_array(cresults).page(params[:page]).per(10)
			else
				@results = @results.page(params[:page]).per(10)
			end
			
			
		@clusters = clusters

  end
  
  
  
  
  
  
  def results
  	
  	@title = "Seperate Results"
  	
  	request.session[:session_id] = "rake_task"#"3feeec33b4f6ebabcef4fc237e26fc81"
  	
  	# session id variable for returning appropriate results
  	sessionid = request.session[:session_id]
  	
  	if request.session[:q_num]
			@query ||= params[:query].nil? ? Result.select(:query).where(:session_id => sessionid).last.query : Result.select(:query).where(:query_number => params[:query]).last.query
		end
  	
  	
  	
  	# num of characters the description of results is truncated to in the view
  	# for all search results
  	@trunc = 50
  	
  	# if there is no request for a particular 
  	@query_number = params[:query].nil? ? Result.where("session_id = ? ", sessionid).maximum("query_number") : params[:query] 
  	
  	# sets instance variable according to whether the paramaeters request a particular engine result
  	@bing				= Result.where('db_name = ? and session_id = ? and query_number =?', "Bing", sessionid, @query_number).order("query_rank ASC").page(params[:page]).per(10)
  	@blekko			= Result.where('db_name = ? and session_id = ? and query_number =?', "Blekko", sessionid, @query_number).order("query_rank ASC").page(params[:page]).per(10)
  	@entireweb	= Result.where('db_name = ? and session_id = ? and query_number =?', "Entireweb", sessionid, @query_number).order("query_rank ASC").page(params[:page]).per(10)
  	
  	
  	##### Hack for including style sheets to give proper width to the search results columns #####
  	@engine_result_count = 3
  	if @bing.empty?
  		@engine_result_count -= 1
  	end
  	if @blekko.empty?
  		@engine_result_count -= 1
  	end
  	if @entireweb.empty?
  		@engine_result_count -= 1
  	end
  	
  	
  	# displays the sessions last 5 queries so the user can review the results of previous queries
  	@queries = Result.select("query,query_number").uniq.where('session_id = ?', sessionid).order("query_number DESC").first(5)
  	
	end
	
	def aggregated
		
		
		
		#request.session[:session_id] = "rake_task"#"3feeec33b4f6ebabcef4fc237e26fc81"
				
		# session_id for the test queries
  	sessionid =  request.session[:session_id]
  	
  	if request.session[:q_num]
			@query ||= params[:query].nil? ? Result.select(:query).where(:session_id => sessionid).last.query : Result.select(:query).where(:query_number => params[:query], :session_id => sessionid).first.query
		end
  	
  	if params[:query].nil?
  		@query_num = Result.where("session_id = ? ", sessionid).maximum("query_number")
  	else
  		@query_num = params[:query]
  	end
  	
  	# num of characters the description of results is truncated to in the view
  	# for all search results
  	@trunc = 150
  	
  	# These three instance variables populate the view with the data from the database.
  	#agg_res = Result.where('session_id = ? and query_number =?', sessionid, query_num).order("score DESC")
  	
  	
		
		urls = []
		
		agg_res = Result.where(:query_number => @query_num, :session_id => sessionid).order("score DESC")
		
		# removes results with duplicate urls from the but leaves the result with the highest score 
		agg_res.delete_if do |item|
			if urls.include? item[:url]
				true
			else
				urls << item[:url]
				false
			end
		end
		
  	# gets last 5 queries associated with the users session so they can go back to their older queries
  	@queries = Result.select("query,query_number").uniq.where('session_id = ?', sessionid).order("query_number DESC").first(5)
  	
  	# returns the number of queries associated with the surrent session
  	@num_of_queries = Result.select(:query).uniq.where('session_id = ?', sessionid).all.count

  	# paginated array of results for the view
  	@agg = Kaminari.paginate_array(agg_res).page(params[:page]).per(10)
  			
	end
end
  
