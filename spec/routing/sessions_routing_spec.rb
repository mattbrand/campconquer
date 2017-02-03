# == Schema Information
#
# Table name: sessions
#
#  id         :integer          not null, primary key
#  player_id  :integer
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_sessions_on_player_id  (player_id)
#  index_sessions_on_token      (token)
#

require "rails_helper"

RSpec.describe SessionsController, type: :routing do
  describe "routing" do

    it "routes to #new" do
      expect(:get => "/login").to route_to("sessions#new")
    end

    it "routes to #create" do
      expect(:post => "/sessions").to route_to("sessions#create")
    end

    it "routes to #destroy" do
      expect(:delete => "/logout").to route_to("sessions#destroy")
    end

  end
end
