json.array!(@team_outcomes) do |team_outcome|
  json.extract! team_outcome, :id, :team, :deaths, :takedowns, :throws, :captures
  json.url team_outcome_url(team_outcome, format: :json)
end
