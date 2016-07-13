require 'rails_helper'

describe OutcomesController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # Outcome. As you add validations to Outcome, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
      winner: 'blue', # game[winner]=blue
      team_outcomes: [
        {
          team: 'blue',
          takedowns: 2,
          throws: 3,
          pickups: 4,
        },
        {
          team: 'red',
          takedowns: 4,
          throws: 5,
          pickups: 6,
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
        it "creates a new Outcome" do
          expect {
            post :create, {game_id: @game.id, outcome: valid_attributes}, valid_session
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
          expect(response.body).to eq({status: 'ok'}.to_json)
        end

        it "replaces an existing outcome on the game" do
          existing_outcome = Outcome.create!({game_id: @game.id, winner: 'blue'})
          post :create, {game_id: @game.id, outcome: valid_attributes}, valid_session
          expect(@game.reload.outcome).not_to be_nil
          expect(@game.reload.outcome).not_to eq(existing_outcome)

          expect(Outcome.where(id: existing_outcome.id)).to be_empty
        end

        it 'sets team outcomes too' do
          post :create, {game_id: @game.id, outcome: valid_attributes}, valid_session
          team_outcomes = @game.reload.outcome.reload.team_outcomes
          expect(team_outcomes).not_to be_empty
          expect(team_outcomes.size).to eq(2)
        end

        it 'unlocks the game' do
          post :create, {game_id: @game.id, outcome: valid_attributes}, valid_session
          expect(@game.reload).not_to be_locked
        end

        it 'marks the game as no longer current' do
          post :create, {game_id: @game.id, outcome: valid_attributes}, valid_session
          expect(@game.reload).not_to be_current
        end
      end

      context "with invalid params" do
        it "assigns a newly created but unsaved outcome as @outcome" do
          post :create, {:game_id => @game.id, :outcome => invalid_attributes}, valid_session
          expect(assigns(:outcome)).to be_a_new(Outcome)
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
