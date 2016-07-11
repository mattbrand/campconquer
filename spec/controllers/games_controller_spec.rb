require 'rails_helper'

describe GamesController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # Game. As you add validations to Game, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    # {winner: 'blue'}  # game[winner]=bob
  }

  let(:invalid_attributes) {
    # {winner: 'neon'}
  }

  let(:empty_attributes) {
    {}
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # GamesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  before do
    request.accept = "application/json"
  end

  describe "GET /games" do
    it "assigns all games as @games" do
      game = Game.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:games)).to eq([game])
    end

    it "returns games in reverse updated_at order" do
      game_a = Game.create! current: false
      game_a.update_columns(updated_at: Time.new(2008, 1, 1, 0, 0, 0))

      game_c = Game.create! current: true
      game_c.update_columns(updated_at: Time.new(2010, 1, 1, 0, 0, 0))

      game_b = Game.create! current: false
      game_b.update_columns(updated_at: Time.new(2009, 1, 1, 0, 0, 0))

      get :index, {}, valid_session
      expect(assigns(:games)).to eq([game_c, game_b, game_a])
    end
  end

  describe "GET /games/{id}" do
    it "assigns the requested game as @game" do
      game = Game.current
      get :show, {:id => game.to_param}, valid_session
      expect(assigns(:game)).to eq(game)
    end
  end

  describe "GET /games/current" do
    it "assigns the current game as @game" do
      game = Game.current
      get :show, {:id => game.to_param}, valid_session
      expect(assigns(:game)).to eq(game)
    end

    context "when there is no current game" do
      it "creates one and assigns it as @game" do
        Game.delete_all
        get :show, {:id => 'current'}, valid_session
        expect(assigns(:game)).not_to be_nil
        expect(assigns(:game).id).not_to be_nil
        expect(assigns(:game)).not_to be_new_record
        expect(assigns(:game)).to be_current
        expect(assigns(:game)).to eq(Game.find(assigns(:game).id))
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested game" do
      game = Game.create! valid_attributes
      expect {
        delete :destroy, {:id => game.to_param}, valid_session
      }.to change(Game, :count).by(-1)
    end

    it "says ok" do
      game = Game.create! valid_attributes
      delete :destroy, {:id => game.to_param}, valid_session
      expect(response.body).to eq({status: 'ok', message: "game #{game.id} deleted"}.to_json)
    end
  end

  describe 'locking' do
    before do
      @game = Game.current
    end

    describe 'POST /games/1/lock' do
      before do
        @betsy = Player.create!(name: 'Betsy', team: 'blue')
        @betsys_piece = @betsy.set_piece(job: 'striker', role: 'offense')

        @randy = Player.create!(name: 'Randy', team: 'red')
        @randys_piece = @randy.set_piece(job: 'bruiser', role: 'defense')

      end

      it 'locks the game' do
        post :lock, {:id => @game.to_param}, valid_session
        expect(@game.reload).to be_locked
      end

      it 'copies the pieces from the players into the game' do

        post :lock, {:id => @game.to_param}, valid_session

        @game.reload

        # make sure it's not the original
        expect(@game.pieces).not_to include(@betsys_piece)
        expect(@game.pieces).not_to include(@randys_piece)

        # make sure it has the original's values
        pieces_hash = @game.pieces.as_json.map do |hash|
          hash.pick(:team, :job, :role, :path)
        end
        betsys_hash = @betsys_piece.as_json.pick(:team, :job, :role, :path)
        randys_hash = @randys_piece.as_json.pick(:team, :job, :role, :path)
        expect(pieces_hash).to include(betsys_hash)
        expect(pieces_hash).to include(randys_hash)
      end

      it 'returns the entire game including pieces' do
        post :lock, {:id => @game.to_param}, valid_session

        json = JSON.parse(response.body)
        expect(json).to include({'status' => 'ok'})
        expect(json).to include('game')
        expect(json['game']).to include('pieces')
        expect(json['game']['pieces'].size).to eq(2)

      end
    end

    describe 'DELETE /games/1/lock' do
      before do
        @betsy = Player.create!(name: 'Betsy', team: 'blue')
        @betsys_piece = @betsy.set_piece(job: 'striker', role: 'offense')

        @game.lock_game!
      end

      it 'unlocks the game' do
        delete :unlock, {:id => @game.to_param}, valid_session
        expect(@game.reload).not_to be_locked
      end

      it 'says ok' do
        delete :unlock, {:id => @game.to_param}, valid_session
        json = JSON.parse(response.body)
        expect(json).to include({'status' => 'ok'})
        expect(json).to include({'message' => "game #{@game.id} unlocked"})
      end

      it 'removes the pieces' do
        delete :unlock, {:id => @game.to_param}, valid_session
        expect(@game.reload.pieces).to be_empty
      end

    end

  end
end
