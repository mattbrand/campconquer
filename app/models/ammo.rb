class Ammo
  def self.from_csv f = ::Path.db_file_path("ammo.csv")
    raise RuntimeError, "loading ammo from csv not implemented yet"
  end

  def self.all
    [
      Ammo.new(name: 'balloon', cost: 25, range_bonus: 0, damage: 1, splash_damage: 0, splash_radius: 0),
      Ammo.new(name: 'arrow', cost: 50, range_bonus: 30, damage: 1, splash_damage: 0, splash_radius: 0),
      Ammo.new(name: 'bomb', cost: 100, range_bonus: 0, damage: 3, splash_damage: 1, splash_radius: 0.25),
    ]
  end

  def self.names
    all.map(&:name)
  end

  def self.by_name
    Hash[all.map do |ammo|
      [ammo.name, ammo]
    end]
  end

  attr_reader :name, :cost

  # sadly and uncharacteristically un-DRY for Ruby
  def initialize name: , cost:, range_bonus: , damage: , splash_damage: , splash_radius:
    @name, @cost, @range_bonus, @damage, @splash_damage, @splash_radius =
      name, cost, range_bonus, damage, splash_damage, splash_radius
  end

  def serializable_hash
    {
      name: @name,
      cost: @cost,
      range_bonus: @range_bonus,
      damage: @damage,
      splash_damage: @splash_damage,
      splash_radius: @splash_radius,
    }
  end

end
