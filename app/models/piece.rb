# == Schema Information
#
# Table name: pieces
#
#  id         :integer          not null, primary key
#  team_name  :string
#  role       :string
#  path       :text
#  speed      :integer          default(0), not null
#  health     :integer          default(0), not null
#  range      :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :integer
#  player_id  :integer
#  body_type  :string
#  face       :string
#  hair       :string
#  skin_color :string
#  hair_color :string
#  ammo       :text
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

  has_many :items

  # has_many :items_equipped, -> { where(equipped: true).includes(:gear) },
  #          class_name: 'Item'
  # a method is quicker than a separate query for some weird eager preload reason
  def items_equipped
    items.select { |item| item.equipped? }
  end

  # todo: validate that `path` is an array of Points
  serialize :path
  serialize :ammo, JSON

  validates :team_name, inclusion: {
      in: Team::GAME_TEAMS.values,
      message: Team::GAME_TEAMS.validation_message
  }

  validates :body_type, inclusion: {
      in: BODY_TYPES.values,
      message: BODY_TYPES.validation_message
  }, allow_nil: true

  validates :role, inclusion: {
      in: ROLES.values,
      message: ROLES.validation_message
  }, allow_nil: true

  class AmmoValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      value.each do |ammo_name|
        record.errors.add attribute, (options[:message] || "unknown ammo name '#{ammo_name}'") if Ammo.by_name[ammo_name].nil?
      end
    end
  end

  validates :ammo, allow_nil: true, ammo: true

  def player_name
    self.player.try(:name)
  end

  # todo: save as Path object, not merely an array of Points

  def path=(value)
    if value.blank?
      super(nil)
    elsif value.is_a? String
      decoded = JSON.parse(value)
      if decoded.is_a? Hash and decoded["Points"]
        decoded = decoded["Points"]
        self.path = decoded
      end
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

  def gear_owned
    items.map { |item| item.gear_name }
  end

  def gear_equipped
    items_equipped.map { |item| item.gear_name }
  end

  def ammo
    super || []
  end

  def add_ammo! ammo_name
    # todo: validate

    self.ammo = self.ammo + [ammo_name]
    save!
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
        only: [:player_id,
               :team_name,
               :body_type,
               :role,
               :path,
               :speed,
               :health,
               :range,
               :face,
               :hair,
               :skin_color,
               :hair_color,
               :ammo,
        ],
        :methods => [:player_name, :gear_owned, :gear_equipped] # Rails is SO unencapsulated :-(
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
