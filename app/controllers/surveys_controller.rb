class SurveysController < ApplicationController
  
  def index
    @surveys = Survey.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @surveys }
    end
  end

  def show
    @survey = Survey.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @survey }
    end
  end

  def new
    @survey = Survey.new

    
    
    respond_to do |format|
      format.html {redirect_to "input" }
      format.json { render json: @survey }
    end
  end

  def edit
    @survey = Survey.find(params[:id])
  end

  def create
    @survey = Survey.new(params[:survey])

    respond_to do |format|
      if @survey.save
        format.html { redirect_to :thanks, notice: 'Survey was successfully created.' }
        format.json { render json: @survey, status: :created, location: @survey }
      else
        format.html { render action: "input" }
        format.json { render json: @survey.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @survey = Survey.find(params[:id])

    respond_to do |format|
      if @survey.update_attributes(params[:survey])
        format.html { redirect_to @survey, notice: 'Survey was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @survey.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /surveys/1
  # DELETE /surveys/1.json
  def destroy
    @survey = Survey.find(params[:id])
    @survey.destroy

    respond_to do |format|
      format.html { redirect_to surveys_url }
      format.json { head :no_content }
    end
  end
  
  def input
  	
  	@survey = Survey.new
  	
  end
  
  def thanks
  	
  	
  end
end
