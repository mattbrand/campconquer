class PiecesController < ApplicationController
  before_action :set_player
  before_action :set_piece, only: [:show, :edit, :update, :destroy]

  # POST /pieces
  def create
    begin
      @piece = @player.piece
      if @piece
        @piece.update!(piece_params)
      else
        params = {player_id: @player.id, team: @player.team} + piece_params
        @piece = Piece.create!(params)
      end
      render json: {status: 'ok'}, status: :created
    end
  end

  private

  def set_piece
    @piece = Piece.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def piece_params
    params.require(:piece).permit(:job, :role, :path)
  end
end
