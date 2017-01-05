class Team
  GAME_TEAMS = Enum.new([
                            [:blue, "Blue Team"],
                            [:red, "Red Team"],
                        ])

  ALL = Enum.new([
                           GAME_TEAMS.item_for(:blue),
                           GAME_TEAMS.item_for(:red),
                           [:control, "Control Group"],
                       ])

  # todo: test better

  attr_reader :offense_paths, :defense_points

  def initialize(team_name)
    @team_name = team_name

    @offense_paths = Path.where(team: team_name, role: 'offense').map(&:points)
    @defense_points = Path.where(team: team_name, role: 'defense').map(&:point)
  end

end
