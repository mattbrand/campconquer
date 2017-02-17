# team_name:
#   type: string
# captures:
#   type: integer
#   description: number of games this team_name won
# takedowns:
#   type: integer
#   description: count of players on *other* teams who died at this team_name's hand
# throws:
#   type: integer
#   description: number of balloons thrown
# pickups:
#   type: integer
#   description: number of times flag was picked up
# flag_carry_distance:
#   type: float
#   description: number of meters this team_name carried the flag

class TeamSummary < Summary
  attr_reader :team_name, :attack_mvps, :defend_mvps

  def initialize(games:, team_name:, max: {})
    @team_name = team_name
    @max = max
    super(games: games)
  end

  def valid?
    not @team_name.nil?
  end

  def player_outcomes
    super.select { |o| o.team_name == team_name }
  end

  # todo: test MVP merge
  def attributes
    {
      'team_name' => @team_name,
      'attack_mvps' => [],
      'defend_mvps' => [],
    } + super
  end

  def attack_mvps
    fetch_mvps('attack_mvps')
  end

  def defend_mvps
    fetch_mvps('defend_mvps')
  end

  private

  def fetch_mvps(role_key)

    # todo: test
    player_ids = Set.new
    games.each do |game|
      next if game.mvps.nil?
      player_ids.merge game.mvps[@team_name][role_key]
    end
    player_ids.to_a

  end

end
