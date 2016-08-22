# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# This is a little dangerous;
# we have to make sure not to leave any gear lists / refs containing
# obsolete gear names
Gear.destroy_all

# To update the gear database, go to
# https://docs.google.com/spreadsheets/d/1LY9Iklc3N7RkdJKkiuVNsMJ07TFsBi973VmIqgnLO6c/
# select "File > Download As > CSV (current sheet)"
# save as db/gear.csv

f = File.expand_path("gear.csv", File.dirname(__FILE__))
gears = CSV.read(f, headers: :first_row)

gears.each do |row|
  Gear.create!([
                 {
                   name: row["ObjectId"],
                   gear_type: row["Type"].downcase,
                   display_name: row["Item Name"],
                   description: row["Description"],
                   health_bonus: row["Health Bonus"],
                   speed_bonus: row["Speed Bonus"],
                   range_bonus: row["Range Bonus"],
                   gold: row['Gold'],
                   gems: row['Gems'],
                   level: row['Level'],
                   asset_name: row['Asset Name'],
                   icon_name: row['Icon Name']
                 },
               ])

end


class Board
  def initialize
    @words = File.read("/usr/share/dict/words").split
    @paths = {}
    @teams = {red: Team.new('red'), blue: Team.new('blue')}

  end

  def team
    @teams[@team_name.to_sym]
  end

  def random_name
    @words[rand(@words.length)]
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

      Piece.create!(player_id: player.id,
                    team: @team_name,
                    role: @role,
                    path: path,
                    speed: 1 + rand(10),
                    health: 1 + rand(10),
                    range: 1 + rand(5),
                    body_type: Piece::BODY_TYPES.values.sample
      )

      ap player.as_json
    end
  end
end

# todo: merge into team.rb
class Team
  attr_reader :offense_paths, :defense_points

  def initialize(team_name)
    @team_name = team_name

    file = File.expand_path("#{team_name}Paths.json", File.dirname(__FILE__))
    @offense_paths = convert_offense(file)

    file = File.expand_path("#{team_name}DefensePos.json", File.dirname(__FILE__))
    @defense_points = convert_defense(file)
  end

  def convert_offense(json_file)
    junk = JSON.parse(File.read(json_file))
    junk.map do |stuff|
      xs = stuff["X"]
      ys = stuff["Y"]
      points = []
      xs.size.times do |i|
        points << Point.new(x: xs[i], y: ys[i])
      end
      points
    end
  end

  def convert_defense(json_file)
    text = File.read((json_file))
    text.gsub!(/("Y".*),/, '\1')
    p text
    JSON.parse(text).map{|hash| Point.from_hash(hash)}
  end

end

# todo: split player seeding into separate rake task

Player.destroy_all
Board.new.seed_teams
