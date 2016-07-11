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

  # describe "PUT #update" do
  #   context "with valid params" do
  #     render_views #???
  #
  #     let(:updated_attributes) {
  #       # {winner: 'bob'}
  #     }
  #
  #     it "updates the requested game" do
  #       game = Game.create! valid_attributes
  #       put :update, {:id => game.to_param, :game => updated_attributes}, valid_session
  #       game.reload
  #       # expect(game.winner).to eq('blue')
  #     end
  #
  #     it "assigns the requested game as @game" do
  #       game = Game.create! valid_attributes
  #       put :update, {:id => game.to_param, :game => valid_attributes}, valid_session
  #       expect(assigns(:game)).to eq(game)
  #     end
  #
  #     it "redirects to the game page" do
  #       game = Game.create! valid_attributes
  #       put :update, {:id => game.to_param, :game => valid_attributes}, valid_session
  #       expect(response).to redirect_to(@game)
  #     end
  #
  #     it "returns JSON if asked" do
  #       request.accept = "application/json"
  #       game = Game.create! valid_attributes
  #       put :update, {:id => game.to_param, :game => valid_attributes}, valid_session
  #       expect(response).to be_success
  #       expect(response).to render_template("show")
  #
  #       # todo: move view testing to 'request spec' maybe
  #       print "body=#{response.body}"
  #       json = JSON.parse(response.body)
  #       expect(json['status']).to eq('ok')
  #       expect(json['game']).not_to be_nil
  #       expect(json['game']['locked']).to be_falsey
  #     end
  #
  #     it "unlocks the game" do
  #       game = Game.create! valid_attributes
  #       put :update, {:id => game.to_param, :game => valid_attributes}, valid_session
  #       expect(assigns(:game).locked).to be_falsey
  #       expect(game.reload.locked).to be_falsey
  #     end
  #
  #
  #   end
  #
  #   context "with invalid params" do
  #
  #     # todo: test bad params with JSON renders JSON not HTML
  #
  #     it "assigns the game as @game" do
  #       game = Game.create! valid_attributes
  #       put :update, {:id => game.to_param, :game => invalid_attributes}, valid_session
  #       expect(assigns(:game)).to eq(game)
  #     end
  #
  #     it "re-renders the 'edit' template" do
  #       game = Game.create! valid_attributes
  #       put :update, {:id => game.to_param, :game => invalid_attributes}, valid_session
  #       expect(response).to render_template("edit")
  #     end
  #
  #     it "leaves the game locked" do
  #       game = Game.create! valid_attributes
  #       put :update, {:id => game.to_param, :game => invalid_attributes}, valid_session
  #       expect(assigns(:game).locked).to be_truthy
  #       expect(game.reload.locked).to be_truthy
  #     end
  #
  #   end
  # end

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
      it 'locks the game' do
        post :lock, {:id => @game.to_param}, valid_session
        expect(@game.reload).to be_locked
      end

      it 'copies the pieces from the players into the game?'
    end

    describe 'DELETE /games/1/lock' do
      it 'unlocks the game' do
        @game.update!(locked: true)
        delete :unlock, {:id => @game.to_param}, valid_session
        expect(@game.reload).not_to be_locked
      end
    end

  end
end
