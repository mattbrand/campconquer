namespace :db do
  task :seed_players => :environment do
    Player.destroy_all
    Board.new.seed_teams
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

  def path
    # everyone starts in a base
    if @role == 'defense'
      [team.defense_points.sample]
    else
      team.offense_paths.sample
    end
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
    50.times do
      player = Player.create!(name: random_name, team: @team_name)

      @role = Piece::ROLES.values.sample

      body_type = Piece::BODY_TYPES.values.sample
      piece = Piece.create!(player_id: player.id,
                    team: @team_name,
                    role: @role,
                    path: path,
                    speed: 1 + rand(10),
                    health: 1 + rand(10),
                    range: 1 + rand(5),
                    body_type: body_type
      )

      puts ["created player ##{player.id}", player.name.ljust(20), @team_name, piece.role, piece.body_type].join("\t")
    end
  end
end

