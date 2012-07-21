module ComparisonHelper
	
#	def statistics(engine, query)
#		
#		sess = "43c856b018bf6e536ec37b2edbdf9e16"  	
#  	
#  	engineRes = Result.select('url, query_rank').where("session_id=? AND db_name=? And query=?", sess, engine, query).order('query_rank ASC').all
#  	googleRes = Google.select('url, query_rank').where("query=?", query).order('query_rank ASC').all
#  	
#  	stats = Hash.new
#  	
#  	relevant = collect_relevant(engineRes, googleRes)
#  	
#  	stats[:rel] = relevant
#  	count = relevant.count
#  	stats[:rel_count] = count
#  	precision = ((count/engineRes.length.to_f)*100).to_i
#  	stats[:precision] = precision
#  	recall = ((count/googleRes.length.to_f)*100).to_i
#  	stats[:recall] = recall
#		
#  	stats[:p10] = p10(relevant)
#  	stats[:ave_prec] = ave_precision(relevant)
#  	stats
#	end
#	
#	def collect_relevant(eRes, gRes)
#		relevant = []
#		# Puts the URL, engine rank and google rank of relevant results in array, returns
#		eRes.each do |e| 
#  		gRes.each do |g|
#  			if g.url.downcase == e.url.downcase
#  			relevant << [e.url, e.query_rank, g.query_rank]
 # 		end
 # 		end
 # 	end
	#	relevant
	#end
	
#	def p10(eRel)
#		
#		# returns all relevant results where engine rank is <= 10
#  	p_at_10 = relevant.take_while {|r| r[1] <= 10  }
#  	p_at_10 = ((p_at_10.size.to_f/10)*100).to_i
#  	p_at_10
#	end
#	
#	def ave_precision(relevant)
#		
#  	running_score =0
#  	relevant.each do |rel|
#  		running_score += ((rel[1] / rel[2].to_f)*100).to_i
#  	end
#  	
#  	ave_precision = (running_score / googleRes.size)
#  
#	end
end
