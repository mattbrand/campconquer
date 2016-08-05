# == Schema Information
#
# Table name: pieces
#
#  id         :integer          not null, primary key
#  team       :string
#  role       :string
#  path       :text
#  speed      :float
#  health     :integer
#  range      :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :integer
#  player_id  :integer
#  body_type  :string
#

class Piece < ActiveRecord::Base

  BODY_TYPES = Enum.new([
                          [:gender_neutral_1],
                          [:gender_neutral_2],
                          [:male],
                          [:female],
                        ])

  ROLES = Enum.new([
                     [:offense],
                     [:defense],
                   ])

  belongs_to :game
  belongs_to :player

  # todo: validate that `path` is an array of Points
  serialize :path

  validates :team, inclusion: {
    in: Team::NAMES.values,
    message: Team::NAMES.validation_message
  }

  validates :body_type, inclusion: {
    in: BODY_TYPES.values,
    message: BODY_TYPES.validation_message
  }, allow_nil: true

  validates :role, inclusion: {
    in: ROLES.values,
    message: ROLES.validation_message
  }, allow_nil: true

  def player_name
    self.player.try(:name)
  end

  def path=(value)
    if value.blank?
      super(nil)
    else
      super(value.map do |p|
        if p.is_a? Point
          p
        elsif p.is_a? Hash
          Point.from_hash(p)
        else
          Point.from_a(p)
        end
      end)
    end
  end

  include ActiveModel::Serialization

  def as_json(options=nil)
    if options.nil?
      options = self.class.serialization_options
    end
    super(options)
  end

  # Rails doesn't recursively call as_json or serializable_hash
  # so we have to call these options explicitly from the parent's as_json
  def self.serialization_options
    {
      only: [:team, :body_type, :role, :path, :speed, :health, :range],
      :methods => [:player_name] # Rails is SO unencapsulated :-(
    }
  end

  def read_attribute_for_serialization(name)
    if name.to_sym == :path
      path && path.map { |point| point.to_hash }
    else
      self.send(name)
    end
  end

end
