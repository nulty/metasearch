# encoding: utf-8

include Math

sess = "rake_task"#request.session[:session_id]
#query_number 
# all results for current query
results = Result.where(:query_number => 30, :session_id => "rake_task").order("score DESC").limit(12).all

puts "The query is #{results.first.query}"; sleep 2
urls=[]
# removes results with duplicate urls from the but leaves the result with the highest score 
results.delete_if do |item|
	if urls.include? item[:url]
		true
	else
		urls << item[:url]
		false
	end
end

## limit the result set to 100??
urls=nil

documents = []

file = File.open(Rails.root.join("app/assets/stopwords")).read.split

results.first.query.split.each {|word_q| file << word_q} 

# add pluralized / singularized query terms to end of stopwords
results.first.query.split.each {|word_q| file << word_q.pluralize; file << word_q.singularize}
file << " "

doc_collection =[]
result_phrases=[]
results.each do |result|
	
	(2..4).each do |c|
		# remove characters and stopwords from the descriptions
		result.description.downcase.gsub(/["•\[\]{}~:;|!?*+().,”“]/, "").gsub(/(\s-\s)/, " ").split.each_cons(c) {|phrase| result_phrases << phrase}
	
	end
	#delete if phrase starts or ends with a stopword 
	result_phrases.delete_if {|a| (file.include?(a.last) || file.include?(a.first) )}
	#result_phrases.map {|a| puts a.inspect}

	#exit 1
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
			count = count / max_frequency_phrase
			#puts "term #{term}, count #{count}"; puts term.inspect
			top_doc_freq.merge!({term =>0}) unless top_doc_freq.has_key? term or count < 0.2 or term.nil?
	end
end


#top_doc_freq.delete_if {|term| }
top_doc_freq.each do |term, count|
	documents.each do |doc|
		puts "This is 'term' #{term}"
		puts "This is 'term'.join(\" \") #{term.join(" ")}"
		if doc.description.match term.join(" ")
			top_doc_freq[term] +=1.0
			 #sleep 0.2
		end
	end
end

num_of_docs = documents.size

# create Inverse document frequency
top_doc_freq.map {|a,b| top_doc_freq[a] = log(num_of_docs/b)}
#puts top_doc_freq[0..10]


# getting 
#doc_collection.each do |doc_term_freq|
#	doc_term_freq.each do |term, freq|
#		
#		top_doc_freq.each do { |term|  }
#			
#	end
#end
#top_doc_freq.each {|a|
#puts "top_doc_freq.size = #{ a.inspect}"
#}
puts top_doc_freq.sort_by {|a,b| if b > 0.0}.reverse











##########################################

##########################################
#puts top_doc_freq.inspect

	
# inverst the document frequency of the terms with a tf of 0.4 or greater



#puts "Max Frequency:\t\t"+max_frequency_phrase.to_s
#puts "#{cluster} was counted in this many documents:\t #{x} "

#exit



#puts doc_collection
#.gsub(/(\.+\s)|[^[a-z]|[A-Z]|0-9]|\s+/, " ").gsub(/\s+/, " ").gsub(/^(\s)|(\s)$/, "")
#.gsub(/["\[\]{}~:;|!?*+().,]/, "")
#words = descriptions.downcase.gsub(/(\.+\s)|[^[a-z]|[A-Z]|0-9]/, " ")
#words.split.delete_if {|a| file.include?(a)}

#counts = {}

#words.each do |w| 
#	if counts.has_key? w
#		counts[w] +=1
#		next
#	else
#		counts.store(w,1)
#	end
#end

#counts.each_pair do |k,v| 
#	if v > 14
#		puts "#{k}\t counts #{v}"
#	end
#end
