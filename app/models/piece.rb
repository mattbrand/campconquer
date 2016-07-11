# == Schema Information
#
# Table name: pieces
#
#  id         :integer          not null, primary key
#  team       :string
#  job        :string
#  role       :string
#  path       :text
#  speed      :float
#  hit_points :integer
#  range      :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :integer
#  player_id  :integer
#

class Piece < ActiveRecord::Base
  belongs_to :game
  belongs_to :player

  # todo: job enum
  # todo: role enum

  # todo: validate that `path` is an array of Points
  serialize :path

  validates :team, inclusion: {
    in: Team::NAMES.values,
    message: Team::NAMES.validation_message
  }

  validates :job, inclusion: {
    in: Job::NAMES.values,
    message: Job::NAMES.validation_message
  }, allow_nil: true

  validates :role, inclusion: {
    in: Role::NAMES.values,
    message: Role::NAMES.validation_message
  }, allow_nil: true

  def player_name
    self.player.try(:name)
  end
end
