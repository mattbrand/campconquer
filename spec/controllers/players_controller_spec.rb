require 'rails_helper'

describe PlayersController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # Player. As you add validations to Player, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
      name: 'Alice',
      team: 'blue'
    }
  }

  let(:invalid_attributes) {
    {
      name: 'Bob',
      team: 'mango'
    }
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # PlayersController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all players as @players" do
      player = Player.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:players)).to eq([player])
    end

    it "renders all players as response_json" do
      player = Player.create! valid_attributes
      get :index, {}, valid_session
      expect(response_json['status']).to eq('ok')
      expect(response_json['players'].size).to eq(1)
      expect(response_json['players'].first).to include(valid_attributes.stringify_keys)
      expect(response_json['players'].first).to include({'id' => player.id})
    end
  end

  describe "GET #show" do
    it "renders the requested player as json" do
      player = Player.create! valid_attributes
      get :show, {:id => player.to_param}, valid_session
      expect(response_json['status']).to eq('ok')
      expect(response_json['player']).to include(valid_attributes.stringify_keys)
      expect(response_json['player']).to include({'id' => player.id})
    end

    it "includes the piece" do
      player = Player.create! valid_attributes
      player.set_piece(role: 'offense')
      get :show, {:id => player.to_param}, valid_session
      expect(response_json['status']).to eq('ok')
      expect(response_json['player']['piece']).to include({'role' => 'offense'})
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Player" do
        expect {
          post :create, {:player => valid_attributes}, valid_session
        }.to change(Player, :count).by(1)
      end

      it "assigns a newly created player as @player" do
        post :create, {:player => valid_attributes}, valid_session
        expect(assigns(:player)).to be_a(Player)
        expect(assigns(:player)).to be_persisted
      end

      it "renders the created player" do
        post :create, {:player => valid_attributes}, valid_session
        player = Player.last
        expect(response_json['status']).to eq('ok')
        expect(response_json['player']).to include(valid_attributes.stringify_keys)
        expect(response_json['player']).to include({'id' => player.id})
      end
    end

    context "with invalid params" do
      it "renders an error template" do
        post :create, {:player => invalid_attributes}, valid_session
        expect(response_json['status']).to eq('error')
        expect(response_json['message']).to include("Team must be \"blue\" or \"red\"")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        { team: 'red' }
      }

      it "updates the requested player" do
        player = Player.create! valid_attributes
        put :update, {:id => player.to_param, :player => new_attributes}, valid_session
        player.reload
        expect(player.team).to eq('red')
      end

      it "renders the requested player as json" do
        player = Player.create! valid_attributes
        put :update, {:id => player.to_param, :player => new_attributes}, valid_session
        expect(response_json['status']).to eq('ok')
        expect(response_json['player']).to include(new_attributes.stringify_keys)
        expect(response_json['player']).to include({'id' => player.id})
      end

    end

    context "with invalid params" do
      it "does not update the player" do
        player = Player.create! valid_attributes
        put :update, {:id => player.to_param, :player => invalid_attributes}, valid_session
        expect(player.reload.team).to eq('blue')
      end

      it "renders error json" do
        player = Player.create! valid_attributes
        put :update, {:id => player.to_param, :player => invalid_attributes}, valid_session
        expect(response_json['status']).to eq('error')
        expect(response_json['message']).to include("Team must be \"blue\" or \"red\"")
      end
    end
  end

  describe 'GET #auth'

end
