class GooglesController < ApplicationController
	
	include GooglesHelper
	include ApplicationHelper
	
  # GET /googles
  # GET /googles.json
  def index
    @googles = Google.page(params[:page]).per(20)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @googles }
    end
  end

  # GET /googles/1
  # GET /googles/1.json
  def show
    @google = Google.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @google }
    end
  end

  # GET /googles/new
  # GET /googles/new.json
  def new
    @google = Google.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @google }
    end
  end

  # GET /googles/1/edit
  def edit
    @google = Google.find(params[:id])
  end

  # POST /googles
  # POST /googles.json
  def create
    @google = Google.new(params[:google])

    respond_to do |format|
      if @google.save
        format.html { redirect_to @google, notice: 'Google was successfully created.' }
        format.json { render json: @google, status: :created, location: @google }
      else
        format.html { render action: "new" }
        format.json { render json: @google.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /googles/1
  # PUT /googles/1.json
  def update
    @google = Google.find(params[:id])

    respond_to do |format|
      if @google.update_attributes(params[:google])
        format.html { redirect_to @google, notice: 'Google was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @google.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /googles/1
  # DELETE /googles/1.json
  def destroy
    @google = Google.find(params[:id])
    @google.destroy

    respond_to do |format|
      format.html { redirect_to googles_url }
      format.json { head :no_content }
    end
  end
  
  
  def store
   	 
   	# id query count is not set in session variable set it to 1
		request.session[:q_num] ||= 1
		
		# put session variables into local variables
		query_number = request.session[:q_num]
		
		# parse the query by encoding it for URL
		query = query_preprocesser(params[:query]) # this is in a helper
				
		# method for collecting results of search from multiple engines - In ResultsHelper
		gRes = google_search(query) # Also a helper method returning googles results
		
		#results = []
		

		unless gRes.empty?	
			Google.transaction do
				gRes.each do |result|
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
				end #end each
			end #end Transaction
		end #end unless
		
		# increase the search count for the session
		request.session[:q_num]+=1
			
		respond_to do |format|
			format.html { redirect_to searchresults_path }
				format.json { head :no_content }
			end
	end
	
	def search
		
		
		
	end
	
	def results
		
		
  	sessionid = request.session[:session_id]
  	
  	max = Result.where("session_id = ? ", sessionid).maximum("query_number")
  	
  	
  	# num of characters the description of results is truncated to in the view
  	# for all search results
  	@trunc = 150
  	
  	
  	# These three instance variables populate the view with the data from the database.
  	google = Result.where('query_number =? or query=?', max, q).order("query_rank ASC")
  	
  	@bing				= bing.empty? ? nil : bing.page(params[:page]).per(10)
  	@blekko			= blekko.empty? ? nil : blekko.page(params[:page]).per(10)
  	@entireweb	= entireweb.empty? ? nil : entireweb.page(params[:page]).per(10)
  	
  	@lastquery = Result.select(:query).where('session_id = ?', sessionid).last

  	
  	@num_of_queries = Result.select(:query).uniq.where('session_id = ?', sessionid).all.count

  	
		respond_to do |format|
			format.html #{ redirect_to results_path(@bing, @blekko, @entireweb)}
		end
  	
		
	end
  
end
