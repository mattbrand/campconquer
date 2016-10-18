# team:
#   type: string
# captures:
#   type: integer
#   description: number of games this team won
# takedowns:
#   type: integer
#   description: count of players on *other* teams who died at this team's hand
# throws:
#   type: integer
#   description: number of balloons thrown
# pickups:
#   type: integer
#   description: number of times flag was picked up
# flag_carry_distance:
#   type: float
#   description: number of meters this team carried the flag

class TeamOutcome < TalliedOutcome
  attr_reader :team, :attack_mvps, :defend_mvps

  def initialize(games:, team:)
    @team = team
    super(games: games)
  end

  def valid?
    not @team.nil?
  end

  def player_outcomes
    super.select { |o| o.team == team }
  end

  # todo: test MVP merge
  def attributes
    {
      'team' => @team,
      'attack_mvps' => [],
      'defend_mvps' => [],
    } + super
  end

  def attack_mvps
    games.first.mvps[@team]['attack_mvps']
  end

  def defend_mvps
    games.first.mvps[@team]['defend_mvps']
  end

end
