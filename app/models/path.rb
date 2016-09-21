class Path

  def self.db_file_path(file_name)
    File.join(Rails.root, "db", file_name)
  end

  # todo: test
  def self.from_csv f = db_file_path("paths.csv")
    rows = CSV.read(f, headers: :first_row)
    paths = rows.map do |row|
      team = row["team"]
      role = row["role"]
      point_cells = (0..9).map do |i|
        row["point#{i}"]
      end.compact
      points = point_cells.map do |cell|
        Point.from_a(cell.split(',').map(&:to_f))
      end.compact
      Path.new(team, role, points)
    end
    paths
  end

  def self.all
    from_csv
  end

  def self.where(team: nil, role: nil)
    all.select do |path|
      (team.nil? or path.team == team) and (role.nil? or path.role == role)
    end
  end

  attr_reader :team, :role, :points

  def initialize(team, role, points)
    @team = team
    @role = role
    @points = points
  end

  # for export to gdoc sheet
  def to_row
    [@team, @role] + @points.map { |p| p.to_a.join(',') }
  end

  def serializable_hash
    {
      team: @team,
      role: @role,
      active: true,
      points: @points,
    }
  end

  def point
    raise "can't get a single point from an offense path" if @role == 'offense'
    @points.first
  end

end
