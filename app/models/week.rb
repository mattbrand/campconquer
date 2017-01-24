# todo: test
class Week
  attr_reader :number, :games

  def initialize(number:, start_at:, finish_at:nil, games:[])
    @number, @start_at, @finish_at = number, start_at, finish_at
    @games = games
  end

  def size
    @games.size
  end

  def start_at
    @start_at.to_date
  end

  def finish_at
    @finish_at || (self.start_at + 1.week)
  end

  def range
    (start_at...finish_at) # three dots = exclusive range
  end

  def name
    if number == 0
      "Preseason"
    else
      "Week #{number}"
    end
  end

  def includes? date
    range.include? date
  end

  def game_players
    games.collect{|g| g.players}.flatten.uniq
  end

  def control_players
    Player.where(team: 'control').includes(:activities)
  end

  # todo: test, no really, i mean it
  def active_players players
    players.map do |player|
      player.activities.map do |activity|
        if self.includes?(activity.date) and
            activity.active? and
            activity.date.weekday?
          player
        else
          nil
        end
      end.compact
    end.flatten
  end

  # sum of all game outcomes per player
  def player_summaries
    game_players.map do |player|
      PlayerSummary.new(games: self.games, player: player)
    end
  end

  # sum of all game outcomes per team
  def team_summaries
    Team::GAME_TEAMS.values.map do |team_name|
      TeamSummary.new(team: team_name, games: self.games)
    end
  end

  def all_top_attackers
    Player.find(team_summaries.inject(Set.new) { |tops, summary| tops.merge(summary.attack_mvps) }.to_a)
  end

  def all_top_defenders
    Player.find(team_summaries.inject(Set.new) { |tops, summary| tops.merge(summary.defend_mvps) }.to_a)
  end

end
