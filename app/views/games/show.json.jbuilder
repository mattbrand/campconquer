json.status("ok")
json.game do
  json.extract! @game, :id, :locked, :winner, :created_at, :updated_at
end

