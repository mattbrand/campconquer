# == Schema Information
#
# Table name: games
#
#  id           :integer          not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  locked       :boolean
#  current      :boolean          default("f")
#  season_id    :integer
#  state        :string           default("preparing")
#  moves        :text
#  winner       :string
#  match_length :integer          default("0"), not null
#
# Indexes
#
#  index_games_on_current    (current)
#  index_games_on_season_id  (season_id)
#

class Game < ActiveRecord::Base

  class WinnerMismatch < RuntimeError
    def initialize(sent, computed)
      super("client said #{sent.inspect} was the winner but we think it's #{computed.inspect}")
    end
  end

  belongs_to :season
  has_many :pieces, -> { includes :player, :items }
  has_many :player_outcomes, class_name: 'Outcome', dependent: :destroy # rename to player_outcomes?

  accepts_nested_attributes_for :player_outcomes

  serialize :moves, JSON

  validates :season_id, presence: true
  validates_uniqueness_of :current,
                          unless: Proc.new { |game| !game.current? },
                          message: 'should be true for only one game'

  validates :winner, inclusion: {
    in: Team::NAMES.values + ["none"],
    message: Team::NAMES.validation_message + ' or "none"',
  }, allow_nil: true

  before_validation do
    self.season_id = Season.current.id unless (self.season_id and self.season_id > 0)
  end

  state_machine :state, initial: :preparing do

    event :lock_game do
      transition :preparing => :in_progress
    end
    before_transition :preparing => :in_progress, do: :do_lock_game

    event :unlock_game do
      transition :in_progress => :preparing
    end
    before_transition :in_progress => :preparing, do: :do_unlock_game

    # don't call this; call finish_game!(params) instead
    event :finish_game do
      transition :in_progress => :completed
    end
  end

  def self.current
    current_game = where(current: true).first
    if current_game.nil?
      current_game = Game.create! locked: false, current: true, season_id: Season.current.id
    end
    current_game
  end

  def self.previous
    where(current: false).order(updated_at: :desc).first
  end

  include ActiveModel::Serialization

  def as_json(options=nil)
    options ||= self.class.serialization_options
    super(options)
  end

  def self.serialization_options
    {
      except: :moves,
      include: [
        {:pieces => Piece.serialization_options},
        :team_outcomes,
        :player_outcomes,
      ],
      methods: [:team_outcomes],
    }
  end

  def team_outcomes
    Team::NAMES.values.map do |team_name|
      TeamOutcome.new(team: team_name, games: [self])
    end
  end

  def do_lock_game
    update!(locked: true)
    copy_player_pieces
  end

  def do_unlock_game
    update!(locked: false)
    pieces.destroy_all
  end

  # params:
  # :winner,
  # :match_length,
  # :moves,
  # outcomes: [{
  #     :player_id, :team, :takedowns, :throws, :pickups, ...
  # }]

  def finish_game! params = {}
    # todo: figure out how to use state_machine to check this
    raise "can only finish in_progress games but this game is '#{state}'" if state != 'in_progress'

    params = params.with_indifferent_access

    self.match_length = params.delete(:match_length)

    moves = params.delete(:moves)
    defaults = {
      match_length: 0,
    }
    self.update!(defaults + params)

    set_winner(params)

    mvps = calculate_mvps
    player_outcomes.each do |outcome|
      if mvps[outcome.team]['attack_mvps'].include? outcome.player_id
        outcome.attack_mvp = 1
      end
      if mvps[outcome.team]['defend_mvps'].include? outcome.player_id
        outcome.defend_mvp = 1
      end
    end

    self.current = false
    self.locked = false
    self.moves = moves if moves
    save!

    # old_outcome.destroy! if old_outcome

    finish_game
  end

  def copy_player_pieces
    players = Player.all.includes(piece: :items).where('pieces.game_id IS NULL').references(:pieces, :items)

    Piece.bulk_insert do |bulk_pieces|
      players.each do |player|
        original_piece = player.piece
        if original_piece
          piece_attrs = original_piece.attributes + {game_id: self.id}
          bulk_pieces.add(piece_attrs)
        end
      end
    end

    # tack on the gear
    Item.bulk_insert do |bulk_items|
      piece_ids = players.map do |player|
        player.piece.try(:id)
      end.compact

      original_items = Item.where(piece_id: piece_ids).includes(:piece)
      new_pieces = self.pieces

      original_items.each do |original_item|
        new_piece = new_pieces.detect { |p| p.player_id == original_item.piece.player_id }
        item_attrs = original_item.attributes + {piece_id: new_piece.id}
        bulk_items.add(item_attrs)
      end
    end
  end

  def calculate_winner
    capture = player_outcomes.detect { |o| o.captures == 1 }
    if capture
      capture.team
    else
      nil # or "none"?
    end
  end

  def calculate_mvps
    winner = calculate_winner
    result = {}
    Team::NAMES.values.each do |team|
      result[team] = {}
      result[team]['attack_mvps'] = calculate_mvps_for(team, 'offense') do |outcome|
        if team == winner
          outcome.captures
        else
          outcome.flag_carry_distance
        end
      end
      result[team]['defend_mvps'] = calculate_mvps_for(team, 'defense') do |outcome|
        outcome.takedowns
      end
    end
    result
  end

  private

  def calculate_mvps_for team, role
    mvps = []
    best = -1

    relevant_outcomes = player_outcomes.select do |o|
      o.team == team and begin
                           piece = pieces.detect{|p| p.player_id == o.player_id}
                           piece.role == role
      end
    end
    relevant_outcomes.each do |outcome|

      value = yield outcome

      if value > best
        mvps = [outcome.player_id]
        best = value
      elsif value == best
        mvps << outcome.player_id
      end

    end

    mvps
  end

  def set_winner(params)
    given_winner = params.delete(:winner)
    if (player_outcomes.nil? or player_outcomes.empty?)
      self.winner = given_winner
    else
      calculated_winner = calculate_winner
      if given_winner && (given_winner != calculated_winner)
        raise Game::WinnerMismatch.new(given_winner, calculated_winner)
      end
      self.winner = calculated_winner
    end
  end

end
