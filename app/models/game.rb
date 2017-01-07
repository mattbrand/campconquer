# == Schema Information
#
# Table name: games
#
#  id              :integer          not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  current         :boolean          default("f")
#  season_id       :integer
#  state           :string           default("preparing")
#  moves           :text
#  winner          :string
#  match_length    :integer          default("0"), not null
#  scheduled_start :datetime
#  mvps            :text
#  played_at       :datetime
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

  def self.next_game_time
    now = Time.current
    Chronic.time_class = Time.zone
    if now.hour < 11
      Chronic.parse('11 am')
    elsif now.hour < 16
      Chronic.parse('4 pm')
    else
      Chronic.parse('tomorrow 11 am')
    end
  end

  belongs_to :season
  has_many :pieces, -> { includes :player, :items }
  has_many :players, through: :pieces

  has_many :player_outcomes, class_name: 'Outcome', dependent: :destroy

  accepts_nested_attributes_for :player_outcomes

  serialize :moves, JSON
  serialize :mvps, JSON

  validates :season_id, presence: true
  validates_uniqueness_of :current,
                          unless: Proc.new { |game| !game.current? },
                          message: 'should be true for only one game'

  validates :winner, inclusion: {
      in: Team::GAME_TEAMS.values + ["none"],
      message: Team::GAME_TEAMS.validation_message + ' or "none"',
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

  def self.has_current?
    !where(current: true).empty?
  end

  def self.current
    current_game = where(current: true).first
    if current_game.nil?
      current_game = Game.create! current: true,
                                  season_id: Season.current.id,
                                  scheduled_start: Game.next_game_time
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
            {
                :pieces => Piece.serialization_options,
            },
            :team_summaries,
            :player_outcomes,
            :paths,
        ],
        methods: [
            :team_summaries,
            :paths,
            :locked,
        ],
    }
  end

  def team_summaries
    Team::GAME_TEAMS.values.map do |team_name|
      TeamSummary.new(team: team_name, games: [self])
    end
  end

  def outcome_for_player(player_id)
    player_id = player_id.id if player_id.is_a? Player
    player_outcomes.detect { |o| o.player_id == player_id }
  end

  alias_method :locked, :in_progress?
  alias_method :locked?, :in_progress?

  def do_lock_game
    copy_player_pieces
  end

  def do_unlock_game
    pieces.destroy_all
  end

  def pieces_on_team(team)
    pieces.where(team: team)
  end

  def paths
    all_paths = Path.all

    # todo: test using ready_players' pieces vs self.pieces based on state
    pieces = if self.preparing?
               ready_players.map(&:piece)
             else
               self.pieces
             end

    pieces.each do |piece|
      path_points = piece.path # # todo: resolve "path" vs "points" ambiguity
      seeking_path = Path.new(team: piece.team, role: piece.role, points: path_points)

      found_path = all_paths.detect { |p| p == seeking_path }
      if found_path
        found_path.increment_count
      else
        logger.warn("couldn't match path #{seeking_path.to_json}")
      end
    end

    all_paths #.as_json # serialization is weird
  end

  # params:
  # :winner,
  # :match_length,
  # :moves,
  # player_outcomes: [{
  #     :player_id, :team, :takedowns, :throws, :pickups, ...
  # }]

  def finish_game! params = {}
    # todo: figure out how to use state_machine to check this
    raise "can only finish in_progress games but this game is '#{state}'" if state != 'in_progress'

    params = params.with_indifferent_access
    moves = params.delete(:moves)
    defaults = {
        match_length: 0,
        played_at: Time.current,
    }

    # Rails is SO WEIRD
    params[:player_outcomes_attributes] ||= []

    leftover_ammo = {}
    params[:player_outcomes_attributes].each do |outcome|
      ammo = outcome.delete(:ammo) || []
      leftover_ammo[outcome[:player_id]] = ammo
    end

    self.update!(defaults + params)

    set_winner(params)

    self.current = false
    self.moves = moves if moves
    save!

    finish_game # call the state machine

    null_out_paths
    restore_leftover_ammo(leftover_ammo)
    calculate_mvps!
    set_mvps_in_outcomes!
    award_prizes!
    award_mvp_prizes!
  end

  def copy_player_pieces
    players = ready_players

    Piece.bulk_insert do |bulk_pieces|
      players.each do |player|
        original_piece = player.piece
        if original_piece
          piece_attrs = original_piece.attributes_before_type_cast + {game_id: self.id}
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

  def ready_players
    Player.all.includes(piece: :items).
        # where(embodied: true).
        where('pieces.game_id IS NULL').
        where('pieces.path IS NOT NULL').
        references(:pieces, :items)
  end

  def calculate_winner
    capture = player_outcomes.detect { |o| o.captures == 1 }
    if capture
      capture.team
    else
      nil
    end
  end

  private

  def calculate_mvps!
    winner = calculate_winner
    result = {}
    Team::GAME_TEAMS.values.each do |team|
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
    update!(mvps: result)
    result
  end

  def calculate_mvps_for team, role
    mvps = []
    best = 0

    relevant_outcomes = player_outcomes.select do |o|
      o.team == team and begin
        player_id = o.player_id
        piece = player_from_pieces(player_id)
        piece.role == role if piece
      end
    end
    relevant_outcomes.each do |outcome|
      value = yield outcome
      if value == 0
        # abort! 0 doesn't count
      elsif value > best
        mvps = [outcome.player_id]
        best = value
      elsif value == best
        mvps << outcome.player_id
      end
    end

    # only one max
    if mvps.size > 1
      puts "Choosing one from #{mvps.inspect}"
      mvps = [mvps.sample]
    end

    mvps
  end

  def player_from_pieces(player_id)
    piece = pieces.detect { |p| p.player_id == player_id }
  end

  def set_winner(params)
    given_winner = params.delete(:winner)
    given_winner = nil if given_winner == 'none'
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

  def null_out_paths
    player_ids = self.players.map(&:id)
    Piece.where(game_id: nil).where(player_id: player_ids).update_all(path: nil)

    # slower:
    # self.players.each do |player|
    #   player.set_piece(path: nil)
    # end
  end

  def restore_leftover_ammo(leftover_ammo)
    leftover_ammo.each_pair do |player_id, ammo|
      Player.find(player_id).set_piece(ammo: ammo)
    end
  end

  def award_prizes! winner: self.winner
    player_outcomes.each do |outcome|
      if outcome.team == winner
        outcome.player.increment_gems!
      end
    end
  end

  def award_mvp_prizes!
    self.mvps.each_pair do |team, team_mvps|
      team_mvps.each_pair do |mvp_type, players|
        players.each do |player_id|
          Player.find(player_id).increment_gems!
        end
      end
    end
  end

  def set_mvps_in_outcomes!
    self.mvps.each_pair do |team, team_mvps|
      team_mvps.each_pair do |mvp_type, players|
        players.each do |player_id|
          mvp_attr = mvp_type.chomp("s")
          outcome_for_player(player_id).update!({mvp_attr => true})
        end
      end
    end
  end

end
