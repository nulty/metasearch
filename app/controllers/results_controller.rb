class ResultsController < ApplicationController

	include ResultsHelper
	include ApplicationHelper
	
  # GET /results
  # GET /results.json
  def index
    @results = Result.page(params[:page]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @results }
    end
  end

  # GET /results/1
  # GET /results/1.json
  def show
    @result = Result.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @result }
    end
  end

  # GET /results/new
  # GET /results/new.json
  def new
  	
  	@result = Result.new#(:session_id => "e08c13a99f21a91520fcc393e0860c94", :db_name => "Bing", :query => "Whats the story", :query_rank => 1, :title => "The Title", :description => "descript", :url => "www.google.ie",:query_number => 1)
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @result }
    end
  end

  # GET /results/1/edit
  def edit
    @result = Result.find(params[:id])
  end

  # POST /results
  # POST /results.json
  def create
    @result = Result.new(params[:result])
    

    respond_to do |format|
      if @result.save
        format.html { redirect_to pages_path, notice: 'Result was successfully created.' }
        format.json { render json: @result, status: :created, location: @result }
      else
        format.html { render action: "new" }
        format.json { render json: @result.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /results/1
  # PUT /results/1.json
  def update
    @result = Result.find(params[:id])

    respond_to do |format|
      if @result.update_attributes(params[:result])
        format.html { redirect_to @result, notice: 'Result was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @result.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /results/1
  # DELETE /results/1.json
  def destroy
    @result = Result.find(params[:id])
    @result.destroy

    respond_to do |format|
      format.html { redirect_to results_url }
      format.json { head :no_content }
    end
  end
  
  def store
   	 
   	# id query count is not set in session variable set it to 1
		request.session[:q_num] ||= 1
		
		# put session variables into local variables
		query_number = request.session[:q_num]
		sessionid = request.session[:session_id]
		
		# parse the query by encoding it for URL
		query = query_preprocesser(params[:query]) # this is in a helper
				
		#resArray = [[{:engine => "bing, :results => [{:Description => "abc", :Title => "def"}, {:Description => "ghi", :Title => "jkl"}]}, {etc},{etc} ],[{:eng...}]]
				 
		# localise the search engine parameters
		bing_p 		= params[:bing]
		entire_p	= params[:entireweb]
		blekko_p	= params[:blekko]
		
		# method for collecting results of search from multiple engines - In ResultsHelper
		resArray = getResults(bing_p, entire_p, blekko_p, query) # Also a helper method returning an array of up to 3 arrays
		
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
						:session_id => sessionid, 
						:db_name => db_name,
						:query_number => query_number,
						:query => params[:query],
						:query_rank => result[:rank],
						:description => result[:description],
						:title => result[:title],
						:url => result[:url] )
						
					res.save!
					end
				end
			end
		end
		
		# method available to ActiveRecord-import
		#Result.import results
		
		# increase the search count for the session
		request.session[:q_num]+=1
			
		respond_to do |format|
			format.html { redirect_to searchresults_path }
				format.json { head :no_content }
			end
		end

  
end
