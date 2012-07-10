# spec/controllers/pages_controller_spec.rb
# rspec spec/models/pages_spec.rb
require 'spec_helper'

include ActiveModel::Lint::Tests

describe PagesController do
  describe "GET #index" do	
	
  	it "renders the :index view" do
			get :index
			response.should render_template :index
		end
	
	end
	
  describe "GET #cluster" do
	
  	it "renders the :cluster view" do
			get :cluster
			response.should render_template :cluster
		end
	
	end
		
	describe "POST #search" do
	
		it "should post the query to the search action" do
			assert_routing({ :path => "/pages", :method => :post }, 
				{ :controller => "pages", :action => "search" })
		end
	
	end
end