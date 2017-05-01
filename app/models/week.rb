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
    games.collect{|g| g.players}.flatten
  end

  def control_players
    Player.where(team_name: 'control').includes(:activities) # todo: allow player to change off control team between seasons?
  end

   # players who were active on at least one weekday during this week
  def physically_active_players players
    players.uniq.map do |player|
      player.activities.map do |activity|
        player if active_in_week?(activity)
      end.compact
    end.flatten
  end

  # sum of all game outcomes per player
  def player_summaries
    game_players.uniq.map do |player|
      PlayerSummary.new(games: self.games, player: player)
    end
  end

  # sum of all game outcomes per team_name
  def team_summaries
    Team::GAME_TEAMS.values.map do |team_name|
      TeamSummary.new(team_name: team_name, games: self.games)
    end
  end

  def all_top_attackers
    Player.find(team_summaries.inject(Set.new) { |tops, summary| tops.merge(summary.attack_mvps) }.to_a)
  end

  def all_top_defenders
    Player.find(team_summaries.inject(Set.new) { |tops, summary| tops.merge(summary.defend_mvps) }.to_a)
  end

  def active_and_gaming
    physically_active_players(game_players).uniq
  end

  private

   def active_in_week?(activity)
     self.includes?(activity.date) and
       activity.active? and
       activity.date.weekday?
   end

end
