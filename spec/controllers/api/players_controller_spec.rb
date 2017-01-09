require 'rails_helper'


describe API::PlayersController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # Player. As you add validations to Player, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
        name: 'Alice',
        password: 'password',
        team: 'blue'
    }
  }

  let(:invalid_attributes) {
    {
        name: 'Bob',
        team: 'mango'
    }
  }

  def player
    @current_player
  end

  let!(:galoshes) { Gear.new(name: 'galoshes', gear_type: 'shoes', coins: 1, gems: 0) }
  let!(:tee_shirt) { Gear.new(name: 'tee-shirt', gear_type: 'shirt') }
  before { Gear.all = [galoshes, tee_shirt] }
  after { Gear.reset }

  before { start_session(Player.create! valid_attributes) }

  describe "GET #index" do

    it "assigns all players as @players" do
      get :index, {}, valid_session
      expect(assigns(:players)).to eq([@current_player])
    end

    it "renders all players as response_json" do
      get :index, {}, valid_session
      expect(response_json['status']).to eq('ok')
      expect(response_json['players'].size).to eq(1)
      expect(response_json['players'].first).to include({'name' => valid_attributes[:name]})
      expect(response_json['players'].first).to include({'id' => player.id})
    end
  end

  describe "GET #show" do

    it "renders the requested player as json" do
      get :show, {:id => player.to_param}, valid_session
      expect(response_json['status']).to eq('ok')
      expect(response_json['player']).to include({'name' => valid_attributes[:name]})
      expect(response_json['player']).to include({'id' => player.id})
    end

    it "includes the piece" do
      player.set_piece(role: 'offense')
      get :show, {:id => player.to_param}, valid_session
      expect(response_json['status']).to eq('ok')
      expect(response_json['player']['piece']).to include({'role' => 'offense'})
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
        expect(player.team).to eq('blue')
        expect(player.embodied).to be false

        put :update, {:id => player.to_param, :player => new_attributes}, valid_session
        player.reload
        expect(player.team).to eq('red')
        expect(player.embodied).to be true
      end

      it "renders the requested player as json" do
        put :update, {:id => player.to_param, :player => new_attributes}, valid_session
        expect(response_json['status']).to eq('ok')
        expect(response_json['player']).to include(new_attributes.stringify_keys)
        expect(response_json['player']).to include({'id' => player.id})
      end

    end

    context "with invalid params" do
      it "does not update the player" do
        put :update, {:id => player.to_param, :player => invalid_attributes}, valid_session
        expect(player.reload.team).to eq('blue')
      end

      it "renders error json" do
        put :update, {:id => player.to_param, :player => invalid_attributes}, valid_session
        expect_error("Team must be \"blue\" or \"red\"")
      end
    end
  end

  describe 'POST claim_steps' do
    it 'claims available steps' do
      player.activities.create!(date: Date.today, steps: 100)
      expect(player.coins).to eq(0)
      post :claim_steps, {:id => player.to_param}, valid_session

      expect_ok
      expect(response_json['status']).to eq('ok')

      player.reload
      expect(player.steps_available).to eq(0)
      expect(player.coins).to eq(10)
    end
  end

  describe 'POST claim_active_minutes' do
    it 'claims available active minutes' do
      player.activities.create!(date: Date.current, active_minutes: Player::GOAL_MINUTES + 10)
      expect(player.gems).to eq(0)

      post :claim_active_minutes, {:id => player.to_param}, valid_session

      expect(response_json['status']).to eq('ok')

      player.reload
      expect(player.active_minutes_claimed?).to eq(true)
      expect(player.gems).to eq(1)
    end
  end

  describe 'gear' do
    before { player.update(coins: 1000) }

    describe "POST #buy" do
      it "buys a gear item" do
        post :buy, {:id => player.to_param, :gear => {:name => 'galoshes'}}, valid_session
        expect_ok
        expect(player.reload.gear_owned).to eq(['galoshes'])
        expect(response_json['player']['piece']).to include({'gear_owned' => ['galoshes']})
      end

      it "buys an ammo item" do
        post :buy, {:id => player.to_param, :ammo => {:name => 'balloon'}}, valid_session
        expect_ok
        expect(player.reload.ammo).to eq(['balloon'])
        expect(response_json['player']['piece']).to include({'ammo' => ['balloon']})
        expect(player.coins).to eq(1000 - 25)
      end

      it "rejects a bogus ammo item" do
        post :buy, {:id => player.to_param, :ammo => {:name => 'tomato'}}, valid_session
        expect_error "Unknown ammo 'tomato'"
      end
    end

    describe "POST #equip" do
      before { player.buy_gear!('galoshes') }

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
          expect_error("current game is locked")
        end
      end
    end

    describe "POST #unequip" do # should be "DELETE equip"? meh
      before do
        player.buy_gear!('galoshes')
        player.equip_gear!('galoshes')
      end

      context "with valid params" do
        it "unequips an item" do
          post :unequip, {:id => player.to_param, :gear => {:name => 'galoshes'}}, valid_session
          expect(player.reload.gear_equipped).to eq([])
          expect(response_json['player']['piece']).to include({'gear_equipped' => []})
        end
      end

      context "while the current game is locked" do
        it "fails" do
          Game.current.lock_game!
          post :unequip, {:id => player.to_param, :gear => {:name => 'galoshes'}}, valid_session
          expect_error("current game is locked")
        end
      end
    end
  end

  describe 'arrange' do
    before { player.update(coins: 1000) }

    describe "POST #arrange" do
      context "with no ammo" do
        before { expect(player.ammo).to be_empty }

        it "rejects an missing ammo array param" do
          post :arrange, {id: player.to_param}, valid_session

          message = "parameter ammo required"
          expect_error(message)
          expect(player.reload.ammo).to eq([])
        end

        it "accepts an empty ammo array param" do
          post :arrange, {id: player.to_param, ammo: []}, valid_session
          expect_ok
          expect(player.reload.ammo).to eq([])
        end

        it "rejects a non-empty ammo array param" do
          post :arrange, {id: player.to_param, ammo: ['balloon']}, valid_session
          expect_error("ammo mismatch")
          expect(player.reload.ammo).to eq([])
        end

        it "rejects a non-empty string ammo param" do
          post :arrange, {id: player.to_param, ammo: 'balloon'}, valid_session
          expect_error("ammo mismatch")
          expect(player.reload.ammo).to eq([])
        end
      end

      context "with one ammo" do
        before { player.buy_ammo! 'balloon' }

        it "rejects an empty ammo array param" do
          post :arrange, {id: player.to_param, ammo: []}, valid_session
          expect_error("ammo mismatch")
          expect(player.reload.ammo).to eq(['balloon'])
        end

        it "accepts an ammo array param with the same ammo" do
          post :arrange, {id: player.to_param, ammo: ['balloon']}, valid_session
          expect_ok
          expect(player.reload.ammo).to eq(['balloon'])
        end

        it "rejects an ammo array param with different ammo" do
          post :arrange, {id: player.to_param, ammo: ['arrow']}, valid_session
          expect_error("ammo mismatch")
          expect(player.reload.ammo).to eq(['balloon'])
        end

        it "rejects an ammo array param with too much ammo" do
          post :arrange, {id: player.to_param, ammo: ['balloon', 'arrow']}, valid_session
          expect_error("ammo mismatch")
          expect(player.reload.ammo).to eq(['balloon'])
        end

      end

      context "with some ammo" do
        before do
          player.buy_ammo! 'arrow'
          player.buy_ammo! 'balloon'
        end

        it "accepts an ammo array param with the same items in the same order" do
          post :arrange, {id: player.to_param, ammo: ['arrow', 'balloon']}, valid_session
          expect_ok
          expect(player.reload.ammo).to eq(['arrow', 'balloon'])
        end

        it "accepts an ammo array param with the same items in different order" do
          post :arrange, {id: player.to_param, ammo: ['balloon', 'arrow']}, valid_session
          expect_ok
          expect(player.reload.ammo).to eq(['balloon', 'arrow'])
        end

        it "rejects an ammo array param with too much ammo" do
          post :arrange, {id: player.to_param, ammo: ['balloon', 'arrow', 'arrow']}, valid_session
          expect_error("ammo mismatch")
          expect(player.reload.ammo).to eq(['arrow', 'balloon'])
        end

        it "rejects an ammo array param with too little ammo" do
          post :arrange, {id: player.to_param, ammo: ['balloon']}, valid_session
          expect_error("ammo mismatch")
          expect(player.reload.ammo).to eq(['arrow', 'balloon'])
        end

        it "rejects an ammo array param with different ammo" do
          post :arrange, {id: player.to_param, ammo: ['balloon', 'bomb']}, valid_session
          expect_error("ammo mismatch")
          expect(player.reload.ammo).to eq(['arrow', 'balloon'])
        end

      end

      context "while the current game is locked" do
        it "fails" do
          Game.current.lock_game!
          post :arrange, {:id => player.to_param, :ammo => []}, valid_session
          expect_error("current game is locked")
        end
      end

    end


  end
end
