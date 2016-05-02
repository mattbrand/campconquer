json.array!(@games) do |game|
  json.extract! game, :id, :winner
  json.url game_url(game, format: :json)
end
