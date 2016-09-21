namespace :db do
  task :seed_game => :environment do
    game = Game.current
    game.lock_game! unless game.in_progress?

    if rand(10) == 0
      puts "draw"
      winning_team = capturing_piece = nil
    else
      winning_team = Team::NAMES.values.sample(1).first
      capturing_piece = game.pieces_on_team(winning_team).where(role: 'offense').sample
      winning_team = nil if capturing_piece.nil?
    end

    outcomes = game.pieces.map do |piece|
      {
        player_id: piece.player_id,
        team: piece.team,
        takedowns: rand(10),
        throws: rand(10),
        pickups: rand(10),
        flag_carry_distance: (piece.role == 'offense') ? rand(20) : 0,
        captures: (capturing_piece == piece) ? 1 : 0,
      }
    end

    game.finish_game! winner: winning_team,
                      match_length: rand(100) + 1,
                      player_outcomes_attributes: outcomes # rails is weird http://stackoverflow.com/a/8719885/190135

    # log it
    ap({
      game_id: game.id,
      winner: game.winner,
      match_length: game.match_length,
     })

  end
end

