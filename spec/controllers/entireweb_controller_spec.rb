require 'spec_helper'

describe EntirewebController do

  describe "GET 'results'" do
    it "returns http success" do
      get 'results'
      response.should be_success
    end
  end
  
  

end
