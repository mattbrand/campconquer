require "rails_helper"

RSpec.describe OutcomesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/outcomes").to route_to("outcomes#index")
    end

    it "routes to #new" do
      expect(:get => "/outcomes/new").to route_to("outcomes#new")
    end

    it "routes to #show" do
      expect(:get => "/outcomes/1").to route_to("outcomes#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/outcomes/1/edit").to route_to("outcomes#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/outcomes").to route_to("outcomes#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/outcomes/1").to route_to("outcomes#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/outcomes/1").to route_to("outcomes#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/outcomes/1").to route_to("outcomes#destroy", :id => "1")
    end

  end
end
