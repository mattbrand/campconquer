# == Schema Information
#
# Table name: games
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  locked     :boolean
#  current    :boolean          default("f")
#  season_id  :integer
#  state      :string           default("preparing")
#  moves      :text
#
# Indexes
#
#  index_games_on_current    (current)
#  index_games_on_season_id  (season_id)
#

class Game < ActiveRecord::Base
  belongs_to :season
  has_many :pieces, -> { includes :player, :items }
  has_one :outcome, -> { includes :player_outcomes }, dependent: :destroy

  serialize :moves, JSON

  validates_uniqueness_of :current,
                          unless: Proc.new { |game| !game.current? },
                          message: 'should be true for only one game'

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
      current_game = Game.create! locked: false, current: true
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
        {:outcome => Outcome.serialization_options},
      ]
    }
  end

  def winner
    self.outcome.try(:winner)
  end

  def do_lock_game
    update!(locked: true)
    copy_player_pieces
  end

  def do_unlock_game
    update!(locked: false)
    pieces.destroy_all
  end

  # params:  :winner,
  # :match_length,
  #     :moves,
  #     team_outcomes: [{
  #     :team, :takedowns, :throws, :pickups
  #                     }]

  # todo: test me
  def finish_game! params
    # todo: figure out how to use state_machine to check this
    raise "can only finish in_progress games but this game is '#{state}'" if state != 'in_progress'

    params = params.with_indifferent_access

    moves = params.delete(:moves)

    outcome = Outcome.new(params)
    outcome.validate! # force a RecordInvalid exception on the outcome before saving the game

    # should these be in a transaction?
    old_outcome = self.outcome
    self.outcome = outcome # this saves it too
    self.current = false
    self.locked = false
    self.moves = moves if moves
    save!
    old_outcome.destroy! if old_outcome

    finish_game
    outcome
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
        new_piece = new_pieces.detect{|p| p.player_id == original_item.piece.player_id}
        item_attrs = original_item.attributes + {piece_id: new_piece.id}
        bulk_items.add(item_attrs)
      end
    end
  end

end
