class Team
  NAMES = Enum.new([
                     [:blue, "Blue Team"],
                     [:red, "Red Team"],
                   ])


  # todo: test

  attr_reader :offense_paths, :defense_points

  def initialize(team_name)
    @team_name = team_name

    @offense_paths = Path.where(team: team_name, role: 'offense').map(&:points)
    @defense_points = Path.where(team: team_name, role: 'defense').map(&:point)
  end

end
