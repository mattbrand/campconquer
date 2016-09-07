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

class TalliedPlayerOutcome < TalliedOutcome
  attr_reader :player_id

  def initialize(games:, player:)
    @player_id = player.id
    super(games: games)
  end

  def valid?
    not @team.nil?
  end

  def player_outcomes
    super.select { |o| o.player_id == player_id }
  end

  def attributes
    {'player_id' => player_id} + super
  end

end
