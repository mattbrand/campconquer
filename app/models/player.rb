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
  CANT_CHANGE_PIECE_WHEN_GAME_LOCKED = "you can't edit your piece if the current game is locked"
  STEPS_PER_COIN = 10
  MAXIMUM_CLAIMABLE_STEPS = 10000
  GOAL_MINUTES = 60
  MAXIMUM_AMMO_SLOTS = 10

  class GoalNotMet < RuntimeError
    def initialize(active_minutes)
      super("goal not met: #{active_minutes} of #{GOAL_MINUTES} achieved")
    end
  end

  class NotEnoughCoins < RuntimeError
    def initialize(gear)
      name = gear.name
      coins = if gear.respond_to? :coins
                gear.coins
              elsif gear.respond_to? :cost
                gear.cost
              else
                "UNKNOWN"
              end
      super("not enough coins to buy #{name}: #{coins} required")
    end
  end

  class NotEnoughSpace < RuntimeError
    def initialize(thing)
      name = thing.name
      super("not enough space to buy #{name}")
    end
  end

  class AlreadyOwned < RuntimeError
    def initialize(gear)
      super("player already owns #{gear.name}: purchase cancelled")
    end
  end

  class NotOwned < RuntimeError
    def initialize(gear)
      super("player attempted to equip unowned gear #{gear.name}")
    end
  end

  class GameLocked < RuntimeError
    def initialize
      super(Player::CANT_CHANGE_PIECE_WHEN_GAME_LOCKED)
    end
  end

  class NoPiece < RuntimeError
    def initialize
      super('piece must be set up')
    end
  end

  has_one :piece, -> { where(game_id: nil).includes(:items) }
  has_many :activities
  has_many :outcomes
  serialize :fitbit_token_hash

  validates_uniqueness_of :name
  validates :team, inclusion: {in: Team::NAMES.values, message: Team::NAMES.validation_message}

  def set_piece(params = {})
    if Game.current.locked?
      # todo: use an AR exception that lets the response be not a 500
      raise Player::GameLocked
    end

    params = params.pick(:body_type, :role, :path, :face, :hair, :skin_color, :hair_color)
    if self.piece
      self.piece.update!(params)
    else
      piece_defaults = {role: 'defense', health: 0, speed: 0, range: 0}
      self.piece = Piece.create!({player_id: self.id, team: self.team} + piece_defaults + params)
    end
    self.piece
  end

  # def require_piece
  #   raise NoPiece if self.piece.nil?
  # end

  after_create do
    set_piece

    Gear.where(owned_by_default: true, equipped_by_default: false).each do |gear|
      buy_gear! gear.name
    end

    Gear.where(equipped_by_default: true).each do |gear|
      buy_gear! gear.name
      equip_gear! gear.name
    end

  end

  include ActiveModel::Serialization

  def as_json(options=nil)
    if options.nil?
      options = {
        except: [:fitbit_token_hash, :anti_forgery_token],
        methods: [
          :steps_available,
          :active_minutes,
          :active_goal_met,
          :active_minutes_claimed,
          :player_outcomes,
          :gear_owned,
          :gear_equipped,
          :ammo,
        ],
        include: [{:piece => Piece.serialization_options}],
      }
    end
    super(options)
  end

  def claim_steps!
    # todo: fetch latest step count from Fitbit now?

    new_coins, steps_to_distribute = calculate_steps

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

  def active_minutes
    activity_today.active_minutes
  end

  def active_goal_met?
    active_minutes >= GOAL_MINUTES
  end
  alias_method :active_goal_met, :active_goal_met?

  def active_minutes_claimed?
    activity_today.active_minutes_claimed?
  end
  alias_method :active_minutes_claimed, :active_minutes_claimed?

  def claim_active_minutes!
    if active_goal_met?
      unless activity_today.active_minutes_claimed?
        activity_today.update!(active_minutes_claimed: true)
        self.gems += 1
        save!
      end
    else
      raise GoalNotMet, active_minutes
    end
  end

  def gear_owned
    # require_piece
    piece.try(:gear_owned)
  end

  def gear_equipped
    # require_piece
    piece.try(:gear_equipped)
  end

  def ammo
    piece.try(:ammo)
  end

  def gear_owned?(gear_name)
    piece.gear_owned.include?(gear_name)
  end

  def gear_equipped?(gear_name)
    piece.gear_equipped.include?(gear_name)
  end

  def buy_gear! gear_name
    raise Player::GameLocked if Game.current.locked? # todo: test

    gear = Gear.find_by_name(gear_name)
    if gear_owned?(gear_name)
      raise Player::AlreadyOwned, gear
    elsif self.coins >= gear.coins
      piece.items.create!(gear_id: gear.id, equipped: false)
      self.coins -= gear.coins
      self.save!
    else
      raise Player::NotEnoughCoins, gear
    end
  end

  def drop_gear! gear_name
    raise Player::GameLocked if Game.current.locked? # todo: test

    gear = Gear.find_by_name(gear_name)
    item = piece.items.find_by_gear_id(gear.id)
    raise NotOwned, gear if item.nil?
    item.destroy
    self.reload # ?
  end

  def equip_gear!(gear_name)
    raise Player::GameLocked if Game.current.locked? # todo: test

    gear = Gear.find_by_name(gear_name)
    item = piece.items.find_by_gear_id(gear.id)
    raise NotOwned, gear if item.nil?
    item.update!(equipped: true)
    self.reload
  end

  def buy_ammo!(ammo_name)
    raise Player::GameLocked if Game.current.locked? # todo: test

    # todo: term 'ammo' used for both singular and plural

    desired_ammo = Ammo.by_name[ammo_name]
    if ammo.size >= MAXIMUM_AMMO_SLOTS
      raise Player::NotEnoughSpace, desired_ammo
    elsif self.coins >= desired_ammo.cost
      piece.add_ammo! ammo_name
      self.coins -= desired_ammo.cost
      self.save!
    else
      raise Player::NotEnoughCoins, desired_ammo
    end

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

  def pull_activity!(date = Date.current)
    summary = fitbit.get_activities(date.strftime('%F'))["summary"]
    activity_for(date).update!(
      steps: summary["steps"].to_i,
      active_minutes: summary["veryActiveMinutes"].to_i + summary["fairlyActiveMinutes"].to_i,
    )
  end

  def reload
    @activity_today = nil
    super
  end

  def activity_today
    @activity_today ||= activity_for(Date.current)
  end

  def activity_for(date)
    self.activities.find_or_create_by!(date: date)
  end

  def role
    self.piece.role
  end

  protected

  def calculate_steps
    steps_available = self.steps_available

    if steps_available >= MAXIMUM_CLAIMABLE_STEPS
      new_coins = MAXIMUM_CLAIMABLE_STEPS / STEPS_PER_COIN
      steps_to_distribute = steps_available
    else
      new_coins = steps_available / STEPS_PER_COIN
      remaining_steps = steps_available % STEPS_PER_COIN
      steps_to_distribute = steps_available - remaining_steps
    end
    return new_coins, steps_to_distribute
  end

end

