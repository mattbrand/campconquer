# == Schema Information
#
# Table name: gears
#
#  id                  :integer          not null, primary key
#  name                :string
#  display_name        :string
#  description         :string
#  health_bonus        :integer          default("0"), not null
#  speed_bonus         :integer          default("0"), not null
#  range_bonus         :integer          default("0"), not null
#  gear_type           :string
#  asset_name          :string
#  icon_name           :string
#  coins               :integer          default("0"), not null
#  gems                :integer          default("0"), not null
#  level               :integer          default("0"), not null
#  equipped_by_default :boolean          default("f"), not null
#  owned_by_default    :boolean          default("f"), not null
#

class Gear < ActiveRecord::Base

  GEAR_TYPES = Enum.new([
                     [:head], [:shirt], [:belt], [:shoes], [:accessory], [:pet],
                   ])

  validates :gear_type, inclusion: {
    in: GEAR_TYPES.values,
    message: GEAR_TYPES.validation_message
  }, allow_nil: true

  validates_uniqueness_of :name

  def as_json(options=nil)
    if options.nil?
      options = {
        only: [
          :name,
          :gear_type,
          :display_name,
          :description,
          :health_bonus,
          :speed_bonus,
          :range_bonus,
          :coins,
          :gems,
          :level,
          :asset_name,
          :icon_name,
          :equipped_by_default,
          :owned_by_default,
        ],
      }
    end
    super(options)
  end

  # todo: unit test
  def self.read_csv(f)
    gears = CSV.read(f, headers: :first_row)

    gears.each do |row|
      Gear.create!([
                     {
                       name: row["Name"],
                       gear_type: row["Type"].downcase,
                       display_name: row["Display Name"],
                       description: row["Description"],
                       health_bonus: row["Health Bonus"],
                       speed_bonus: row["Speed Bonus"],
                       range_bonus: row["Range Bonus"],
                       coins: row['Coins'],
                       gems: row['Gems'],
                       level: row['Level'],
                       asset_name: row['Asset Name'],
                       icon_name: row['Icon Name'],
                       equipped_by_default: row['Equipped By Default'].to_i.to_boolean,
                       owned_by_default: row['Owned By Default'].to_i.to_boolean,
                     },
                   ])

    end
  end

end
