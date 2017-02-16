class Path

  def self.db_file_path(file_name)
    File.join(Rails.root, "db", file_name)
  end

  # todo: test
  def self.from_csv f = db_file_path("paths.csv")
    rows = CSV.read(f, headers: :first_row)
    paths = rows.map do |row|
      team_name = row["team"]
      button_position = Point.from_s(row["button_position"])
      button_angle = row["button_angle"].to_i
      role = row["role"]
      points = parse_point_cells(row)
      Path.new(team_name: team_name,
               button_position: button_position,
               button_angle: button_angle,
               role: role,
               points: points)
    end
    paths
  end

  def self.parse_point_cells(row)
    (0..9).map do |i|
      row["point#{i}"]
    end.compact.map do |cell|
      Point.from_s(cell)
    end.compact
  end

  def self.all
    from_csv
  end

  def self.where(team_name: nil, role: nil)
    all.select do |path|
      (team_name.nil? or path.team_name == team_name) and (role.nil? or path.role == role)
    end
  end

  attr_reader :team_name, :button_position, :button_angle, :role, :points, :count, :active

  def initialize(team_name:, button_position:nil, button_angle:0, role:, points:, count: 0, active: true)
    @team_name = team_name
    @button_position = button_position
    @button_angle = button_angle
    @role = role
    @points = points
    @count = count
    @active = active
  end

  def ==(other)
    other.is_a? Path and
        other.team_name == self.team_name and
        other.role == self.role and
        other.points == self.points
  end

  # for export to gdoc sheet
  def to_row
    [@team_name, @role] + @points.map { |p| p.to_a.join(',') }
  end

  def serializable_hash(options=nil)
    {
        team_name: @team_name,
        button_position: @button_position.as_json, # serialization is dumb
        button_angle: @button_angle,
        role: @role,
        count: @count,
        active: @active,
        points: @points.map(&:as_json), # serialization is nuts
    }.deep_stringify_keys
  end

  def point
    raise "can't get a single point from an offense path" if @role == 'offense'
    @points.first
  end

  def increment_count
    @count += 1
  end

end
