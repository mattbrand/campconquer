# Walks through a list of outcomes and totals up the fields.
# Used for post-game per-team report (TeamSummary)
# and for per-player season report (PlayerSummary).
class Summary
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
    STATS.each do |stat|
      self.set_stat(stat, 0)
    end
    tally_up
  end

  def player_outcomes
    games.map{|o| o.player_outcomes}.flatten
  end

  def attributes
    Hash[STATS.collect { |item| [item.to_s, 0] }]
  end

  protected

  def tally_up
    player_outcomes.each do |player_outcome|
      STATS.each do |stat|
        self.add_to_stat(stat, player_outcome.send(stat))
      end
    end
  end

  def add_to_stat(stat, game_val)
    game_val = 1 if game_val == true
    game_val = 0 if game_val == false

    current_val = self.send(stat) || 0
    game_val ||= 0
    new_val = current_val + game_val
    set_stat(stat, new_val)
  end

  def set_stat(stat, value)
    check_max(stat, value)
    instance_variable_set("@#{stat}", value)
  end

  def check_max(stat, new_val)
    if (@max && @max[stat] && new_val > @max[stat])
      message = "exceeded maximum value for #{stat}"
      Rails.logger.error(player_outcomes.as_json)
      raise message
    end
  end

end
