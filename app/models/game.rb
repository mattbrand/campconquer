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

  validates_uniqueness_of :current,
                          unless: Proc.new { |game| !game.current? },
                          message: 'should be true for only one game'

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
    if options.nil?
      options = {
        include: [
          {:pieces => Piece.serialization_options},
          {:outcome => Outcome.serialization_options},
        ]
      }
    end
    super(options)
  end

  def winner
    self.outcome.try(:winner)
  end

  # todo: test me
  def unlock_game!
    update!(locked: false)
  end

  # todo: test me
  def lock_game!
    if locked?
      # todo: use an AR exception that lets the response be not a 500
      raise "you can't lock a game that is already locked"
    end

    update!(locked: true)

    copy_player_pieces

  end

  # params:  :winner,
  # :match_length,
  #     :moves,
  #     team_outcomes: [{
  #     :team, :takedowns, :throws, :pickups
  #                     }]

  # todo: test me
  def finish_game! params
    # todo: fail if the game is already completed
    outcome = Outcome.new(params)
    outcome.validate! # force a RecordInvalid exception on the outcome before saving the game

    # should these be in a transaction?
    old_outcome = self.outcome
    self.outcome = outcome # this saves it too
    self.current = false
    self.locked = false
    save!
    old_outcome.destroy! if old_outcome
    outcome
  end

  private

  def copy_player_pieces
    players = Player.all.includes(piece: :items).where('pieces.game_id IS NULL').references(:pieces)

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
    # todo: move to Piece
    Item.bulk_insert do |bulk_items|
      pieces = self.pieces.includes(:items, :player)
      pieces.each do |piece|

        # optimization:
        # player = piece.player  # this needs to re-query the db for the player
        player = players.detect{|p| p.id == piece.player_id}   # this uses the players we already loaded

        original_piece = player.piece # :-)
        original_piece.items.each do |original_item|
          item_attrs = original_item.attributes + {piece_id: piece.id}
          bulk_items.add(item_attrs)
        end
      end
    end

  end

end
