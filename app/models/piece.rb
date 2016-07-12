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

  # include ActiveModel::Serialization
  # def as_json(options=nil)
  #   if options.nil?
  #     options = {root: true} + self.class.serialization_options
  #   end
  #   super(options)
  # end

  # Rails doesn't recursively call as_json or serializable_hash
  # so we have to call these options explicitly from the parent's as_json
  def self.serialization_options
    {
      only: [:team, :job, :role, :path, :speed, :hit_points, :range],
      :methods => [:player_name] # Rails is SO unencapsulated :-(
    }
  end

end
