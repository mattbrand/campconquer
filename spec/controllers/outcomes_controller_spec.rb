require 'rails_helper'

describe OutcomesController, type: :controller do

  let!(:bob) { Player.create! name: 'bob', team: 'blue' }
  let!(:rhoda) { Player.create! name: 'rhoda', team: 'red' }

  # This should return the minimal set of attributes required to create a valid
  # Outcome. As you add validations to Outcome, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
      winner: 'blue', # game[winner]=blue
      player_outcomes: [
        {
          team: 'blue',
          player_id: bob.id,
          takedowns: 2,
          throws: 3,
          pickups: 4,
          flag_carry_distance: 5,
          captures: 6,
          attack_mvp: true,
          defend_mvp: false,
        },
        {
          team: 'red',
          player_id: rhoda.id,
          takedowns: 12,
          throws: 13,
          pickups: 14,
          flag_carry_distance: 15,
          captures: 16,
          attack_mvp: false,
          defend_mvp: true,
        }
      ]
    }
  }

  let(:invalid_attributes) {
    {winner: 'neon'}
  }

  let(:empty_attributes) {
    {}
  }
  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # OutcomesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "POST #create" do

    before do
      @game = Game.current
    end

    context 'when the game is not locked' do
      it 'should fail to post an outcome' do
        post :create, {game_id: @game.id, outcome: valid_attributes}, valid_session
        expect(@game.reload.outcome).to be_nil
        expect(response.status).to eq(409) # HTTP 409: Conflict: "The request could not be completed due to a conflict with the current state of the target resource." https://httpstatuses.com/409
        expect(response_json['status']).to eq('error')
      end
    end

    context "when the game is locked" do
      before do
        @game.lock_game!
      end

      context "with valid params" do

        before { bypass_rescue }

        it "creates a new Outcome" do
          expect {
            post :create, {game_id: @game.id, outcome: valid_attributes}, valid_session
            expect_ok

          }.to change(Outcome, :count).by(1)
        end

        it "assigns a newly created outcome as @outcome" do
          post :create, {game_id: @game.id, outcome: valid_attributes}, valid_session
          expect(assigns(:outcome)).to be_a(Outcome)
          expect(assigns(:outcome)).to be_persisted
        end

        it "sets the newly created outcome on the game" do
          expect(@game.outcome).to be_nil
          post :create, {game_id: @game.id, outcome: valid_attributes}, valid_session
          @game.reload
          expect(@game.outcome).not_to be_nil
          expect(@game.winner).to eq("blue")
        end

        it "renders an 'ok' message" do
          post :create, {game_id: @game.id, outcome: valid_attributes}, valid_session
          expect_ok
        end

        it "replaces an existing outcome on the game" do
          existing_outcome = Outcome.create!({game_id: @game.id, winner: 'blue'})
          post :create, {game_id: @game.id, outcome: valid_attributes}, valid_session
          expect(@game.reload.outcome).not_to be_nil
          expect(@game.reload.outcome).not_to eq(existing_outcome)

          expect(Outcome.where(id: existing_outcome.id)).to be_empty
        end

        it 'sets player outcomes too' do
          post :create, {game_id: @game.id, outcome: valid_attributes}, valid_session
          player_outcomes = @game.reload.outcome.reload.player_outcomes
          expect(player_outcomes).not_to be_empty
          expect(player_outcomes.size).to eq(2)
        end

        it 'unlocks the game' do
          post :create, {game_id: @game.id, outcome: valid_attributes}, valid_session
          expect(@game.reload).not_to be_locked
        end

        it 'marks the game as no longer current or locked' do
          post :create, {game_id: @game.id, outcome: valid_attributes}, valid_session
          expect(@game.reload).not_to be_current
        end

        it 'reads & saves a move list as a raw json blob' do
          moves = "MOVESJSON"
          post :create, {game_id: @game.id, outcome: valid_attributes + {moves: moves}}, valid_session
          expect_ok
          expect(assigns(:outcome).reload.moves).to eq(moves)
        end
      end

      context "with invalid params" do
        it "does not reset the current or locked flags" do
          expect(@game).to be_current
          expect(@game).to be_locked
          post :create, {:game_id => @game.id, :outcome => invalid_attributes}, valid_session
          @game.reload
          expect(@game).to be_current
          expect(@game).to be_locked
        end

        it "renders an error body" do
          post :create, {:game_id => @game.id, :outcome => invalid_attributes}, valid_session
          expect(response_json).to include({
                                             'status' => 'error',
                                             'message' => 'Winner must be "blue" or "red" or "none"'
                                           })
        end
      end
    end
  end
end
