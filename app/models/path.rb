class Path

  def self.from_json team, role
    file_name = team + (role == 'offense' ? "Paths" : "DefensePos") + ".json"
    file_path = File.join(Rails.root, "db", file_name)
    read_json_value = json = JSON.parse(File.read(file_path))
    json = read_json_value
    json.map do |path_json|
      Path.new(team, role, path_json)
    end
  end

  def self.print_rows(team, role)
    from_json(team, role).each do |zzz|
      puts zzz.to_row.join("\t")
    end
    nil
  end

  def initialize(team, role, json)
    @team = team
    @role = role

    if json["Points"]
      @points = json["Points"].map do |xy_hash|
        Point.from_hash(xy_hash)
      end
    elsif json["Point"]
      @points = [Point.from_hash(json["Point"])]
    else
      raise "don't understand json: #{json.inspect}"
    end

  end

  def to_row
    [@team, @role] + @points.map{|p| p.to_a.join(',')}
  end

end
