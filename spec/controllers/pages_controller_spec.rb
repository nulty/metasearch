# spec/controllers/pages_controller_spec.rb
# rspec spec/models/pages_spec.rb
require 'spec_helper'

describe PagesController do
  describe "GET #index" do
  	
  it "renders the :index view" do
    get :index
    response.should render_template :index
  end
  
  it "renders the :cluster view" do
    get :cluster
    response.should render_template :cluster
  end
end
	
	it "should post the query to the results action" do
		assert_routing({ :path => "index", :method => :post }, 
			{ :controller => "index", :action => "results" })
  end
  
end