require 'rails_helper'

describe API::PlayersController, type: :controller do
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

  # PUT /players/1
  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        {
          team: 'red',
          embodied: true,
        }
      }

      it "updates the requested player" do
        player = Player.create! valid_attributes

        expect(player.team).to eq('blue')
        expect(player.embodied).to be false

        put :update, {:id => player.to_param, :player => new_attributes}, valid_session
        player.reload
        expect(player.team).to eq('red')
        expect(player.embodied).to be true
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

  describe 'GET #auth' do
    it "redirects to the player's auth URL" do
      player = Player.create! valid_attributes
      expect(Player).to receive(:find).with(player.to_param) { player }
      expect(player).to receive(:begin_auth) { "FITBIT.COM" }
      bypass_rescue
      get :auth, {:id => player.to_param}, valid_session
      expect(response).to redirect_to("FITBIT.COM")
    end
  end

  describe 'GET #auth-callback' do
    it "finds the player corresponding to the given auth token, finishes auth, and redirects to the admin players list" do
      player = Player.create! valid_attributes + {anti_forgery_token: "CALLBACK_STATE"}
      expect(Player).to receive(:find_by_anti_forgery_token).with("CALLBACK_STATE") { player }
      expect(player).to receive(:finish_auth).with("CALLBACK_CODE")
      bypass_rescue
      get :auth_callback, {:state => "CALLBACK_STATE", :code => "CALLBACK_CODE"}
      expect(response).to redirect_to(admin_players_path)
    end
  end

  describe 'POST claim_steps' do
    let!(:player) { Player.create! valid_attributes }

    it 'claims available steps' do
      player.activities.create!(date: Date.today, steps: 100)
      expect(player.coins).to eq(0)
      post :claim_steps, {:id => player.to_param}

      expect(response_json['status']).to eq('ok')

      player.reload
      expect(player.steps_available).to eq(0)
      expect(player.coins).to eq(10)
    end
  end

  describe 'POST claim_active_minutes' do
    let!(:player) { Player.create! valid_attributes }

    it 'claims available active minutes' do
      player.activities.create!(date: Date.current, active_minutes: Player::GOAL_MINUTES + 10)
      expect(player.gems).to eq(0)

      post :claim_active_minutes, {:id => player.to_param}

      expect(response_json['status']).to eq('ok')

      player.reload
      expect(player.active_minutes_claimed?).to eq(true)
      expect(player.gems).to eq(1)
    end
  end

  describe 'gear' do
    let!(:player) { Player.create! valid_attributes }
    let!(:galoshes) { Gear.create!(name: 'galoshes', gear_type: 'shoes') }

    describe "POST #buy" do
      context "with valid params" do
        it "buys an item" do
          post :buy, {:id => player.to_param, :gear => {:name => 'galoshes'}}, valid_session
          expect_ok
          expect(player.reload.gear_owned).to eq(['galoshes'])
          expect(response_json['player']['piece']).to include({'gear_owned' => ['galoshes']})
        end
      end
    end

    describe "POST #equip" do
      before do
        player.buy_gear!('galoshes')
      end

      context "with valid params" do
        it "equips an item" do
          post :equip, {:id => player.to_param, :gear => {:name => 'galoshes'}}, valid_session
          expect(player.reload.gear_equipped).to eq(['galoshes'])
          expect(response_json['player']['piece']).to include({'gear_equipped' => ['galoshes']})
        end
      end

      context "while the current game is locked" do
        it "fails" do
          Game.current.lock_game!
          post :equip, {:id => player.to_param, :gear => {:name => 'galoshes'}}, valid_session
          expect(response_json['status']).to eq('error')
          expect(response_json['message']).to include("current game is locked")
        end
      end
    end

  end

  describe 'ammo' do
    let!(:player) { Player.create! valid_attributes }

    describe "POST #buy" do
      context "with valid params" do
        it "buys an item" do
          player.update!(coins: 1000)
          post :buy, {:id => player.to_param, :ammo => {:name => 'balloon'}}, valid_session
          expect_ok
          expect(player.reload.ammo).to eq(['balloon'])
          expect(response_json['player']['piece']).to include({'ammo' => ['balloon']})
          expect(player.coins).to eq(1000 - 25)
        end
      end
    end
  end

end
