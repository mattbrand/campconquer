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

class TalliedOutcome
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  include ActiveModel::Serialization

  attr_reader :games

  STATS = [
    :takedowns,
    :throws,
    :pickups,
    :captures,
    :flag_carry_distance,
    :attack_mvp,
    :defend_mvp,
  ]

  attr_reader *STATS

  def initialize(games:)
    @games = games || []
    tally
  end

  def player_outcomes
    games.map{|o| o.player_outcomes}.flatten
  end

  def tally
    player_outcomes.each do |player_outcome|
      STATS.each do |stat|
        self.add_to_stat(stat, player_outcome.send(stat))
      end
    end
  end

  def attributes
    Hash[STATS.collect { |item| [item.to_s, 0] }]
  end

  protected

  def add_to_stat(stat, game_val)
    current_val = self.send(stat) || 0
    game_val ||= 0
    instance_variable_set("@#{stat}", current_val + game_val)
  end

end
