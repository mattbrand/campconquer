namespace :db do
  task :seed_players => :environment do
    Season.current.games.destroy_all
    Player.destroy_all
    Player.create!(name: 'mod', password: 'xyzzy', team: 'gamemaster', admin: true)
    puts "Created mod"
    board = Board.new
    board.seed_teams
    board.seed_control_group
    Rake::Task['db:seed_activities'].invoke
  end

  task :setup_for_game => :environment do
    Board.new.setup_for_game
  end
end

class Board
  def initialize
    @names = Set.new
    @paths = {}
    @teams = {red: Team.new('red'), blue: Team.new('blue')}
  end

  def team
    @teams[@team_name.to_sym]
  end

  def random_name
    begin
      name = [Faker::Name.first_name, Faker::Pokemon.name, Faker::Superhero.name].sample.downcase
    end while @names.include? name
    @names << name
    name
  end

  def point_in_base
    Point.new(x: left_side_of_base + rand(5), y: 1 + rand(8))
  end

  def point_anywhere
    Point.new(x: rand(15), y: rand(10))
  end

  def seed_teams
    %w(red blue).each do |team_name|
      @team_name = team_name
      seed_team
    end
  end

  def seed_team
    10.times do
      player = Player.create!(name: random_name, password: 'password', team: @team_name)

      role = Piece::ROLES.values.sample
      path_points = random_path(role: role)

      body_type = Piece::BODY_TYPES.values.sample
      speed = rand(10)
      health = rand([0, 10 - speed].max)
      range = 10 - speed - health

      piece = player.set_piece(
          role: role,
          path: path_points,
          speed: speed,
          health: health,
          range: range,
          body_type: body_type,
          face: "face_01_f",
          hair: "hair_short_02_f",
          skin_color: "EFD8CC",
          hair_color: "2968c2",
          ammo: ["balloon", "arrow", "balloon"]
      )
      player.update(embodied: true)

      puts ["created player ##{player.id}", player.name.ljust(20), @team_name, piece.role, piece.body_type].join("\t")
    end
  end

  def random_path(team: @team_name, role:)
    Path.where(team: team, role: role).sample.points
  end

  def seed_control_group
    10.times do
      player = Player.new(name: random_name, password: 'password', team: 'control')
      player.save!
      puts ["created control player ##{player.id}", player.name.ljust(20)].join("\t")
    end
  end

  def setup_for_game
    Player.all.each do |player|
      path_points = random_path(role: player.role, team: player.team)
      if player.piece
        player.piece.update!(path: path_points, ammo: ["balloon", "arrow", "balloon"])
      end
    end
  end

end

