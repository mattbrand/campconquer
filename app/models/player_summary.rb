class PlayerSummary < Summary
  attr_reader :player_id

  def initialize(games:, player:)
    @player_id = player.id
    super(games: games)
  end

  def valid?
    not @player_id.nil?
  end

  def player_outcomes
    super.select { |o| o.player_id == player_id }
  end

  def attributes
    {'player_id' => player_id} + super
  end

end
