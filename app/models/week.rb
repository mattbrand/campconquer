# todo: test
class Week
  attr_reader :number, :games, :start_at

  def initialize(number:, start_at:, games:[])
    @number, @start_at, @games = number, start_at, games
  end

  def size
    @games.size
  end

  def name
    if number == 0
      "Preseason"
    else
      "Week #{number}"
    end
  end

  def players
    game.collect{|g| g.players}.flatten.uniq
  end

  # sum of all game outcomes per team
  def team_summaries
    Team::GAME_TEAMS.values.map do |team_name|
      TeamSummary.new(team: team_name, games: self.games)
    end
  end

  # sum of all game outcomes per player
  def player_summaries
    players.map do |player|
      PlayerSummary.new(games: self.games, player: player)
    end
  end

  def all_top_attackers
    top_player_ids = team_summaries.inject(Set.new) { |tops, summary| tops.merge(summary.attack_mvps) }.to_a
  end

  def all_top_defenders
    top_player_ids = team_summaries.inject(Set.new) { |tops, summary| tops.merge(summary.defend_mvps) }.to_a
  end

  def player_names player_ids
    player_ids.map { |id| Player.find(id).name }.sort.join(', ')
  end

end
