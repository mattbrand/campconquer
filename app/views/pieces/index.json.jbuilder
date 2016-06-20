json.array!(@pieces) do |piece|
  json.extract! piece, :id, :team, :job, :role, :path, :speed, :hit_points, :range
  json.url piece_url(piece, format: :json)
end
