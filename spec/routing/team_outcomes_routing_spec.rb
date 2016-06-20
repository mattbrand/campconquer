require "rails_helper"

RSpec.describe TeamOutcomesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/team_outcomes").to route_to("team_outcomes#index")
    end

    it "routes to #new" do
      expect(:get => "/team_outcomes/new").to route_to("team_outcomes#new")
    end

    it "routes to #show" do
      expect(:get => "/team_outcomes/1").to route_to("team_outcomes#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/team_outcomes/1/edit").to route_to("team_outcomes#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/team_outcomes").to route_to("team_outcomes#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/team_outcomes/1").to route_to("team_outcomes#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/team_outcomes/1").to route_to("team_outcomes#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/team_outcomes/1").to route_to("team_outcomes#destroy", :id => "1")
    end

  end
end
