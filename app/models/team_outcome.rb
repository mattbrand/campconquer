# team:
#   type: string
# wins:
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

class TeamOutcome
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  include ActiveModel::Serialization

  attr_reader :team

  STATS = [:wins,
           :takedowns,
           :throws,
           :pickups,
           :captures,
           :flag_carry_distance]

  attr_reader *STATS

  def initialize(team:, games:)
    @team = team
    @wins = 0

    if games
      games.each do |game|
        outcome = game.outcome
        next unless outcome
        add_to_stat('wins', 1) if outcome.winner == team

        outcome.player_outcomes.each do |player_outcome|
          next unless player_outcome.team == team
          (STATS - [:wins]).each do |stat|
            self.add_to_stat(stat, player_outcome.send(stat))
          end
        end
      end
    end
  end

  def valid?
    not @team.nil?
  end

  def attributes
    {
      'team' => @team,
    } + Hash[STATS.collect { |item| [item.to_s, 0] } ]
  end

  protected

  def add_to_stat(stat, game_val)
    current_val = self.send(stat) || 0
    game_val ||=  0
    instance_variable_set("@#{stat}", current_val + game_val)
  end

end
