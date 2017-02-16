require 'rails_helper'

describe API::PiecesController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # Piece. As you add validations to Piece, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
        body_type: 'female',
        role: 'offense',
        face: 'happy',
        hair: 'the bieber',
        skin_color: 'pale',
        hair_color: 'blonde',
        health: 1,
        speed: 2,
        range: 3,
    }
  }

  let(:invalid_attributes) {
    {role: 'coach'}
  }

  let(:empty_attributes) {
    {}
  }


  let!(:abby) { create_player(player_name: 'Abby', team_name: 'blue') }
  before { start_session(abby) }

  describe "POST #create" do

    context "with valid params" do
      it "assigns a newly created piece as @piece" do
        post :create, {player_id: abby.id, piece: valid_attributes}, valid_session
        expect(assigns(:piece)).to be_a(Piece)
        expect(assigns(:piece)).to be_persisted
      end

      it "sets all the given attributes" do
        post :create, {player_id: abby.id, piece: valid_attributes}, valid_session
        expect(assigns(:piece).attributes).to include(valid_attributes.stringify_keys)
      end

      it "sets the team based on the player's team" do
        post :create, {player_id: abby.id, piece: valid_attributes}, valid_session
        expect(assigns(:piece).team_name).to eq(abby.team_name)
      end

      it "sets the newly created piece on the player" do
        post :create, {player_id: abby.id, piece: valid_attributes}, valid_session
        abby.reload
        expect(abby.piece).not_to be_nil
        expect(abby.piece).to eq(assigns(:piece))
      end

      it "renders an 'ok' message" do
        post :create, {player_id: abby.id, piece: valid_attributes}, valid_session
        expect(response.body).to eq({status: 'ok'}.to_json)
      end

      it "updates an existing piece on the player" do
        abby.set_piece(body_type: 'female', role: 'offense')
        post :create, {player_id: abby.id, piece: {body_type: 'gender_neutral_1'}}, valid_session
        abby.reload
        expect(abby.piece.body_type).to eq('gender_neutral_1')
      end

      context "while the current game is locked" do
        before do
          @game = Game.current
          @game.lock_game!
        end

        it "prevents updating the player's piece" do
          post :create, {:player_id => abby.id,
                         :piece => valid_attributes}, valid_session
          expect(response).not_to be_ok
          expect(response_json).to include({
                                               'status' => 'error',
                                               'message' => Player::CANT_CHANGE_PIECE_WHEN_GAME_LOCKED
                                           })
        end
      end
    end

    context "with invalid params" do
      before do
        @game = Game.current
      end

      it "renders an error body" do
        post :create, {:player_id => abby.id,
                       :piece => invalid_attributes}, valid_session
        expect(response).not_to be_ok
        expect(response_json).to include(
                                     {
                                         'status' => 'error',
                                         'message' =>
                                             'Role must be "offense" or "defense"'
                                     })
      end
    end

    context 'with path' do
      before do
        @game = Game.current
      end

      it "accepts path as a json string" do
        for json_string in [
            '{"Points":[{"X":11.25,"Y":5.0},{"X":9.75,"Y":4.5},{"X":7.5,"Y":9.0},{"X":0.5,"Y":9.0},{"X":0.5,"Y":5.0}]}',
            '[{"X":11.25,"Y":5.0},{"X":9.75,"Y":4.5},{"X":7.5,"Y":9.0},{"X":0.5,"Y":9.0},{"X":0.5,"Y":5.0}]',
            '[{"x":11.25,"y":5.0},{"x":9.75,"y":4.5},{"x":7.5,"y":9.0},{"x":0.5,"y":9.0},{"x":0.5,"y":5.0}]',
        ]

          post :create, {:player_id => abby.id,
                         :piece => {:path => json_string}}, valid_session

          expect(response.status).to eq(201)
          expect(response.body).to eq({status: 'ok'}.to_json)

          abby.reload
          expect(abby.piece.path).to eq(
                                            [
                                                Point.new(x: 11.25, y: 5.0),
                                                Point.new(x: 9.75, y: 4.5),
                                                Point.new(x: 7.5, y: 9.0),
                                                Point.new(x: 0.5, y: 9.0),
                                                Point.new(x: 0.5, y: 5.0)
                                            ]
                                        )

        end
      end
    end
  end

end
