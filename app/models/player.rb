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
#  coins              :integer          default("0"), not null
#  gems               :integer          default("0"), not null
#

class Player < ActiveRecord::Base
  CANT_CHANGE_PIECE_WHEN_GAME_LOCKED = "you can't change your piece if the current game is locked"
  STEPS_PER_COIN = 10

  has_one :piece, -> { where(game_id: nil) }
  has_many :activities
  serialize :fitbit_token_hash

  validates_uniqueness_of :name
  validates :team, inclusion: {in: Team::NAMES.values, message: Team::NAMES.validation_message}

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
        except: [:fitbit_token_hash, :anti_forgery_token],
        methods: [:steps_available],
        include: [{:piece => Piece.serialization_options}],
      }
    end
    super(options)
  end

  def claim_steps!
    # todo: fetch latest step count

    new_coins = steps_available / STEPS_PER_COIN
    remaining_steps = steps_available % STEPS_PER_COIN
    steps_to_distribute = steps_available - remaining_steps

    self.coins += new_coins

    # this could be more efficient
    self.activities.order(date: :asc).where('steps != steps_claimed').each do |activity|
      if activity.steps_unclaimed >= steps_to_distribute
        activity.steps_claimed += steps_to_distribute
        activity.save!
        break
      else
        tranche = activity.steps_unclaimed
        activity.steps_claimed += tranche
        steps_to_distribute -= tranche
        activity.save!
      end
    end

    self.save!
  end

  def steps_available
    activities.sum('steps - steps_claimed')
  end

  # methods which call Fitbit

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
    # puts "update_token called: #{fitbit.token_hash}"
    self.fitbit_token_hash = fitbit.token_hash
    save!
    @fitbit = nil
  end

  def fitbit_profile
    fitbit.get_user_profile
  end

  def authenticated?
    fitbit_token_hash
  end

  def pull_activity!(date = Time.current)
    summary = fitbit.get_activities(date.strftime('%F'))["summary"]
    activity = self.activities.find_or_create_by!(date: date)
    activity.update!(
      steps: summary["steps"].to_i,
      very_active_minutes: summary["veryActiveMinutes"].to_i,
      fairly_active_minutes: summary["fairlyActiveMinutes"].to_i,
      lightly_active_minutes: summary["lightlyActiveMinutes"].to_i)
  end
end

