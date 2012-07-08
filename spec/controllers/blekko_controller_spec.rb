# spec/controllers/blekko_controller_spec.rb

require 'spec_helper'

describe BlekkoController do
  describe "GET #results" do
  
  
  	it "renders the :results view" do
    get :results
    response.should render_template :results
  end
end


  
  
end