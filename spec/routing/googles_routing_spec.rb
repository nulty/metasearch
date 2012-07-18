require "spec_helper"

describe GooglesController do
  describe "routing" do

    it "routes to #index" do
      get("/googles").should route_to("googles#index")
    end

    it "routes to #new" do
      get("/googles/new").should route_to("googles#new")
    end

    it "routes to #show" do
      get("/googles/1").should route_to("googles#show", :id => "1")
    end

    it "routes to #edit" do
      get("/googles/1/edit").should route_to("googles#edit", :id => "1")
    end

    it "routes to #create" do
      post("/googles").should route_to("googles#create")
    end

    it "routes to #update" do
      put("/googles/1").should route_to("googles#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/googles/1").should route_to("googles#destroy", :id => "1")
    end

  end
end
