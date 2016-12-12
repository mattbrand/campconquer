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
#  hair                :string
#  body_type           :string
#  color_decal         :boolean          default("f"), not null
#

class Gear < ActiveRecord::Base

  GEAR_TYPES = Enum.new([
                          [:head], [:shirt], [:belt], [:shoes], [:accessory], [:pet],
                        ])

  validates :gear_type, inclusion: {
    in: GEAR_TYPES.values,
    message: GEAR_TYPES.validation_message
  }, allow_nil: true

  validates :body_type, inclusion: {
    in: Piece::BODY_TYPES.values,
    message: Piece::BODY_TYPES.validation_message
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
          :body_type,
          :hair,
          :equipped_by_default,
          :owned_by_default,
          :color_decal,
        ],
      }
    end
    super(options)
  end

  # todo: unit test
  def self.read_csv(f)
    sanitize_items

    Gear.delete_all

    rows = CSV.read(f, headers: :first_row)

    rows.each do |row|
      body_type = row['Body Type'].try(:downcase)

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
                       body_type: body_type,
                       hair: row['Hair'],
                       equipped_by_default: row['Equipped By Default'].to_i.to_boolean,
                       owned_by_default: row['Owned By Default'].to_i.to_boolean,
                       color_decal: row['Color Decal'].to_i.to_boolean,
                     },
                   ])
    end

  end

  def self.sanitize_items
    # todo: make this faster?  store gear name too?
    bogus = Item.all.includes(:gear).select { |i| i.gear.nil? }
    unless bogus.empty?
      puts "Found items with bogus gear:"
      p bogus.map{|i| i.gear_name}.sort.uniq.join(", ")
      puts "Deleting #{bogus.size} bogus items."
      Item.where(id: bogus.map(&:id)).delete_all
    end
  end

end
