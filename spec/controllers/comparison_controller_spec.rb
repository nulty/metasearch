require 'spec_helper'

describe ComparisonController do

  describe "GET 'single_query'" do
    it "returns http success" do
      get 'single_query'
      response.should be_success
    end
  end

  describe "GET 'summary'" do
    it "returns http success" do
      get 'summary'
      response.should be_success
    end
  end

end
