class Team
  GAME_TEAMS = Enum.new([
                            [:blue, "Blue Team"],
                            [:red, "Red Team"],
                        ])

  ALL = Enum.new([
                           GAME_TEAMS.item_for(:blue),
                           GAME_TEAMS.item_for(:red),
                           [:control, "Control Group"],
                           [:gamemaster, "Gamemasters"],
                       ])

end
