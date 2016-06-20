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

  # todo: job enum
  # todo: role enum

  # todo: validate that `path` is an array of Points
  serialize :path


end
