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

class Gear
  include ActiveModel::Model
  include ActiveModel::Serialization
  include ActiveModel::Serializers::JSON

  # workaround to get "Validation failed" message
  def self.i18n_scope
    :activerecord
  end

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

  ATTRIBUTE_MAP = {
      name: -> (row) { row["Name"] },
      gear_type: -> (row) { row["Type"].try :downcase },
      display_name: -> (row) { row["Display Name"] },
      description: -> (row) { row["Description"] },
      health_bonus: -> (row) { row["Health Bonus"].to_i },
      speed_bonus: -> (row) { row["Speed Bonus"].to_i },
      range_bonus: -> (row) { row["Range Bonus"].to_i },
      coins: -> (row) { row['Coins'].to_i },
      gems: -> (row) { row['Gems'].to_i },
      level: -> (row) { row['Level'].to_i },
      asset_name: -> (row) { row['Asset Name'] },
      icon_name: -> (row) { row['Icon Name'] },
      body_type: -> (row) { row['Body Type'].try :downcase },
      hair: -> (row) { row['Hair'] },
      equipped_by_default: -> (row) { row['Equipped By Default'].to_i.to_boolean },
      owned_by_default: -> (row) { row['Owned By Default'].to_i.to_boolean },
      color_decal: -> (row) { row['Color Decal'].to_i.to_boolean },
  }

  attr_accessor *ATTRIBUTE_MAP.keys

  def initialize **opts
    defaults = {
        owned_by_default: false, equipped_by_default: false,
        coins: 0, gems: 0
    }
    opts = defaults + opts
    super **opts
  end

  def attributes
    ATTRIBUTE_MAP.keys.map { |name| [name, nil] }.to_h
  end

  # The next time someone needs gear, reload the CSV.
  def self.reset
    @all = nil
  end

  def self.all
    if @all.nil?
      @all = []
      add(read_csv)
    else
      @all
    end
  end

  # Add the given piece (or set) of gear.
  # In tests, if you use this method, remember to call Gear.reset afterwards.
  def self.add gear
    if gear.is_a? Gear
      raise ArgumentError, "Gear name must be unique, but we already have gear named '#{gear.name}'" if find_by_name(gear.name)
      all << gear
    else
      gear.each do |g|
        add g
      end
    end
  end

  # Use the given set of gear instead of the CSV.
  # In tests, if you use this method, remember to call Gear.reset afterwards.
  def self.all=(gears)
    @all = []
    add(gears)
  end

  def self.read_csv(f = ::Path.db_file_path("gear.csv"))
    rows = CSV.read(f, headers: :first_row)
    gears = rows.map do |row|
      next if row.empty?
      hash = ATTRIBUTE_MAP.each_pair.map do |key, operation|
        [key, operation.call(row)]
      end.to_h
      g = Gear.new(hash)
      raise(ArgumentError, "Validation failed: #{g.errors.full_messages.join(", ")}") unless g.valid?
      g
    end.compact


    item_gear_names = Item.select('gear_name').uniq.map(&:gear_name)
    csv_gear_names = gears.map(&:name)
    missing_gear_names = item_gear_names - csv_gear_names
    unless missing_gear_names.empty?
      Item.where(gear_name: missing_gear_names).delete_all
      raise ArgumentError, "Found items with gear ('#{missing_gear_names.join(', ')}') missing from the current gear list. Deleting."
    end
    gears
  end

  # todo: unit test
  def self.where(**opts)
    all.select do |gear|
      ok = true
      opts.each_pair do |attribute_name, desired_value|
        if gear.send(attribute_name) != desired_value
          ok = false
          break
        end
      end
      ok
    end
  end

  def self.find_by_name(name)
    where(name: name).first
  end

end
