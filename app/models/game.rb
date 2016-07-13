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
          :outcome
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
    update!(locked: true)

    Player.all.includes(:piece).each do |player|
      self.pieces << player.piece.dup
    end
    save! # unnecessary?

  end

end
