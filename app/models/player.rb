# == Schema Information
#
# Table name: players
#
#  id                 :integer          not null, primary key
#  name               :string
#  team               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  fitbit_token_hash  :text
#  anti_forgery_token :string
#

class Player < ActiveRecord::Base
  CANT_CHANGE_PIECE_WHEN_GAME_LOCKED = "you can't change your piece if the current game is locked"

  has_one :piece
  serialize :fitbit_token_hash

  validates :team, inclusion: { in: Team::NAMES.values, message: Team::NAMES.validation_message}

  def set_piece(params = {})
    if Game.current.locked?
      # todo: use an AR exception that lets the response be not a 500
      raise Player::CANT_CHANGE_PIECE_WHEN_GAME_LOCKED
    end

    params = params.pick(:body_type, :role, :path)
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

  # FitBit stuff

  def fitbit
    @fitbit ||= Fitbit.new(token_hash: fitbit_token_hash, token_saver: self)
  end

  def begin_auth
    anti_forgery_token = rand(100000).to_s # todo: better encryption
    update!(anti_forgery_token: anti_forgery_token)
    fitbit.authorization_url(state: anti_forgery_token)
  end

  def finish_auth(code)
    self.anti_forgery_token = nil
    fitbit.code = code # note: this should callback to update_token
  end

  # todo: test
  def update_token(fitbit)
    print "update_token called: #{fitbit.token_hash}"
    self.fitbit_token_hash = fitbit.token_hash
    save!
    @fitbit = nil
  end

  def fitbit_profile
    fitbit.get_user_profile
  end

end
