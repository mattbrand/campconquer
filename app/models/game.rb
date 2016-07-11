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

    previous_game = previous
    if previous_game
      copy_pieces(previous_game, current_game)
    end

    current_game
  end

  def self.copy_pieces(from_game, to_game)
    from_game.pieces.each do |piece|
      to_game.pieces << piece.dup
    end
    to_game.save!   # unnecessary?
  end

  def self.previous
    where(current: false).order(updated_at: :desc).first
  end

  # include ActiveModel::Serialization
  #
  # def as_json(options={})
  #   serializable_hash(options)  # default
  # end

end
