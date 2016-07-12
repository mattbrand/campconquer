require 'rails_helper'

describe PiecesController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # Piece. As you add validations to Piece, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
      job: 'striker',
      role: 'offense',
      path: '', # todo
    }
  }

  let(:invalid_attributes) {
    {job: 'coder'}
  }

  let(:empty_attributes) {
    {}
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # PiecesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  before do
    @player = Player.create!(name: 'Abby', team: 'blue')
  end

  describe "POST #create" do

    context "with valid params" do
      it "creates a new Piece" do
        expect {
          post :create, {player_id: @player.id, piece: valid_attributes}, valid_session
        }.to change(Piece, :count).by(1)
      end

      it "assigns a newly created piece as @piece" do
        post :create, {player_id: @player.id, piece: valid_attributes}, valid_session
        expect(assigns(:piece)).to be_a(Piece)
        expect(assigns(:piece)).to be_persisted
      end

      it "sets the team" do
        post :create, {player_id: @player.id, piece: valid_attributes}, valid_session
        expect(assigns(:piece).team).to eq(@player.team)
      end

      it "sets the newly created piece on the player" do
        expect(@player.piece).to be_nil
        post :create, {player_id: @player.id, piece: valid_attributes}, valid_session
        @player.reload
        expect(@player.piece).not_to be_nil
        expect(@player.piece.team).to eq("blue")
      end

      it "renders an 'ok' message" do
        post :create, {player_id: @player.id, piece: valid_attributes}, valid_session
        expect(response.body).to eq({status: 'ok'}.to_json)
      end

      it "updates an existing piece on the player" do
        existing_piece = Piece.create!({player_id: @player.id, team: @player.team, job: 'striker', role: 'offense'})

        post :create, {player_id: @player.id, piece: {job: 'bruiser'}}, valid_session

        @player.reload
        expect(@player.piece).not_to be_nil
        expect(@player.piece).to eq(existing_piece)
        expect(@player.piece.job).to eq('bruiser')
      end

    end

    context "with invalid params" do
      it "renders an error body" do
        post :create, {:player_id => @player.id, :piece => invalid_attributes}, valid_session
        expect(response_json).to include({
                                  'status' => 'error',
                                  'message' => 'Job must be "bruiser" or "striker" or "speedster"'
                                })
      end
    end
  end

end
