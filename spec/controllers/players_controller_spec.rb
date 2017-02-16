# == Schema Information
#
# Table name: players
#
#  id                   :integer          not null, primary key
#  name                 :string
#  team_name            :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  fitbit_token_hash    :text
#  anti_forgery_token   :string
#  coins                :integer          default(0), not null
#  gems                 :integer          default(0), not null
#  embodied             :boolean          default(FALSE), not null
#  session_token        :string
#  encrypted_password   :string
#  salt                 :string
#  admin                :boolean          default(FALSE), not null
#  activities_synced_at :datetime
#
# Indexes
#
#  index_players_on_session_token  (session_token)
#

require 'rails_helper'

describe PlayersController, type: :controller do


  def current_user
    controller.send(:current_player)
  end

  def login_as(player)
    controller.send(:create_session, player)
  end


  let!(:admin) { create_admin }
  let!(:player) { create_player(player_name: 'bob', password: 'password') }

  describe 'GET #auth' do

    it "redirects to the player's auth URL" do
      login_as admin
      allow(Player).to receive(:find).with(admin.to_param) { admin }

      expect(Player).to receive(:find).with(player.to_param) { player }
      expect(player).to receive(:begin_auth) { "FITBIT.COM" }
      bypass_rescue
      get :auth, {:id => player.to_param}, valid_session
      expect(response).to redirect_to("FITBIT.COM")
    end

    it "requires user to be admin (even though the authed player is not an admin)" do
      login_as player

      get :auth, {:id => player.to_param}, valid_session
      expect(response.status).to eq(403)
    end
  end

  describe 'GET #auth-callback' do
    it "finds the player corresponding to the given auth token, finishes auth, and redirects to the admin players list" do
      login_as admin
      allow(Player).to receive(:find).with(admin.to_param) { admin }

      player.update({anti_forgery_token: "CALLBACK_STATE"})
      expect(Player).to receive(:find_by_anti_forgery_token).with("CALLBACK_STATE") { player }
      expect(player).to receive(:finish_auth).with("CALLBACK_CODE")
      bypass_rescue
      get :auth_callback, {:state => "CALLBACK_STATE", :code => "CALLBACK_CODE"}
      expect(response).to redirect_to(admin_players_path)
    end

    it "requires user to be admin (even though the authed player is not an admin)" do
      login_as player

      get :auth_callback, {:state => "CALLBACK_STATE", :code => "CALLBACK_CODE"}
      expect(response.status).to eq(403)
    end

  end


  # describe "GET #show" do
  #
  #   it "renders the requested player as json" do
  #     get :show, {:id => player.to_param}, valid_session
  #     expect(response_json['status']).to eq('ok')
  #     expect(response_json['player']).to include({'name' => valid_attributes[:name]})
  #     expect(response_json['player']).to include({'id' => player.id})
  #   end
  #
  #   it "includes the piece" do
  #     player.set_piece(role: 'offense')
  #     get :show, {:id => player.to_param}, valid_session
  #     expect(response_json['status']).to eq('ok')
  #     expect(response_json['player']['piece']).to include({'role' => 'offense'})
  #   end
  # end


end
