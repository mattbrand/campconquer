class Team
  NAMES = Enum.new([
                     [:blue, "Blue Team"],
                     [:red, "Red Team"],
                   ])


  # todo: convert to read CSV not JSON
  # todo: test

  attr_reader :offense_paths, :defense_points

  def initialize(team_name)
    @team_name = team_name

    file = File.expand_path("../../db/#{team_name}Paths.json", File.dirname(__FILE__))
    @offense_paths = convert_offense(file)

    file = File.expand_path("../../db/#{team_name}DefensePos.json", File.dirname(__FILE__))
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
    JSON.parse(text).map{|hash| Point.from_hash(hash)}
  end


end
