# == Schema Information
#
# Table name: players
#
#  id         :integer          not null, primary key
#  name       :string
#  team       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Player < ActiveRecord::Base
  CANT_CHANGE_PIECE_WHEN_GAME_LOCKED = "you can't change your piece if the current game is locked"

  has_one :piece

  validates :team, inclusion: { in: Team::NAMES.values, message: Team::NAMES.validation_message}

  def set_piece(params = {})
    if Game.current.locked?
      # todo: use an AR exception that lets the response be not a 500
      raise Player::CANT_CHANGE_PIECE_WHEN_GAME_LOCKED
    end

    params = params.pick(:job, :role, :path)
    if self.piece
      self.piece.update!(params) # todo: whitelist
    else
      self.piece = Piece.create!({player_id: self.id, team: self.team} + params)
    end
    self.piece
  end

  include ActiveModel::Serialization
  def as_json(options=nil)
    if options.nil?
      options = {
        include: [{:piece => Piece.serialization_options}],
      }
    end
    super(options)
  end

end
