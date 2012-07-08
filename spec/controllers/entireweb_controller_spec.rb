require 'spec_helper'

describe EntirewebController do

  describe "GET 'results'" do
    it "returns http success" do
      get 'results'
      response.should be_success
    end
  end
  
  describe "POST 'search'" do
    it "should perform search on query" do
      #Entireweb.should_receive(:search).with({'query' => "Linux"})
  		post 'search'# , :search => {'query' => "Linux" }
    end
  end

end
