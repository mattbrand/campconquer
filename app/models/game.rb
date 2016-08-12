# == Schema Information
#
# Table name: games
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  locked     :boolean
#  current    :boolean          default("f")
#
# Indexes
#
#  index_games_on_current  (current)
#

class Game < ActiveRecord::Base
  has_many :pieces
  has_one :outcome, dependent: :destroy

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
        root: true,
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

    duplicate_players

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

  def duplicate_players
    Player.all.includes(:piece).each do |player|
      original_piece = player.piece
      if original_piece
        copied_piece = original_piece.dup
        self.pieces << copied_piece
        duplicate_items(copied_piece, original_piece)
      end
    end
    save! # needed?
  end

  def duplicate_items(copied_piece, original_piece)
    original_piece.items.each do |item|
      copied_piece.items << item.dup
    end
  end

end
