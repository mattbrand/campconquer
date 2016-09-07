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
  attr_reader :team

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

  def attributes
    {'team' => @team} + super
  end

end
