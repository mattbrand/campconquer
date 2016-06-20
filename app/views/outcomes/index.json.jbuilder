json.array!(@outcomes) do |outcome|
  json.extract! outcome, :id, :winner, :team_stats_id, :match_length
  json.url outcome_url(outcome, format: :json)
end
