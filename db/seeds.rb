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
  end

  def random_name
    @words[rand(@words.length)]
  end

  def left_side_of_base
    case @team_name
    when 'blue'
      10
    else
      0
    end
  end

  def team_paths
    {
      red: [
        [
          [3.75, 5.0],
          [5.25, 4.5],
          [9.75, 4.5],
          [11.25, 5.0],
          [14.5, 5.0],
        ],
        [
          [3.75, 5.0],
          [5.25, 4.5],
          [7.5, 9.0],
          [14.4, 9.0],
          [14.4, 8.5],
          [14.5, 5.0],
        ],
        [
          [3.75, 5.0],
          [5.25, 4.5],
          [7.5, 1.0],
          [14.4, 1.0],
          [14.4, 1.5],
          [14.5, 5.0],
        ],
      ],
      blue: [
        [
          [11.25, 5.0],
          [9.75, 4.5],
          [5.25, 4.5],
          [3.75, 5.0],
          [0.5, 5.0],
        ],
        [
          [11.25, 5.0],
          [9.75, 4.5],
          [7.5, 9.0],
          [0.5, 9.0],
          [0.5, 5.0],
        ],
        [
          [11.25, 5.0],
          [9.75, 4.5],
          [7.5, 1.0],
          [0.5, 1.0],
          [0.5, 5.0],
        ],
      ],
    }
  end

  def random_path
    # everyone starts in a base
    p = [point_in_base]
    if @role == 'offense'
      10.times { p << point_anywhere }
    end
    p
  end

  def path
    # everyone starts in a base
    if @role == 'defense'
      [point_in_base]
    else
      paths = team_paths[@team_name.to_sym]
      paths.sample.map{|tuple| Point.from_a(tuple)}
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

def convert_path(json)
  junk = JSON.load(json)
  junk.each do |stuff|
    puts '  ['
    xs = stuff["X"]
    ys = stuff["Y"]
    xs.size.times do |i|
      print "    "
      print [xs[i], ys[i]].inspect
      puts ","
    end
    puts '  ],'
  end
end

def convert_paths
  redPaths = '[{"X":[3.75, 5.25, 9.75, 11.25, 14.5],"Y":[5.0, 4.5, 4.5, 5.0, 5.0]},{"X":[3.75, 5.25, 7.5, 14.4, 14.4, 14.5],"Y":[5.0, 4.5, 9.0, 9.0, 8.5, 5.0]},{"X":[3.75, 5.25, 7.5, 14.4, 14.4, 14.5],"Y":[5.0, 4.5, 1.0, 1.0, 1.5, 5.0]}]'

  bluePaths = '[{"X":[11.25, 9.75, 5.25, 3.75, 0.5],"Y":[5.0, 4.5, 4.5, 5.0, 5.0]},{"X":[11.25, 9.75, 7.5, 0.5, 0.5],"Y":[5.0, 4.5, 9.0, 9.0, 5.0]},{"X":[11.25, 9.75, 7.5, 0.5, 0.5],"Y":[5.0, 4.5, 1.0, 1.0, 5.0]}]'

  puts "red: ["
  convert_path(redPaths)
  puts "],"

  puts "blue: ["
  convert_path(bluePaths)
  puts "],"
end

# convert_paths; exit

Player.destroy_all
Board.new.seed_teams
