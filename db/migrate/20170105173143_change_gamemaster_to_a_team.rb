class ChangeGamemasterToATeam < ActiveRecord::Migration
  def up
    Player.where(gamemaster: true).update_all(team: 'gamemaster')
    remove_column :players, :gamemaster, :boolean
  end
  def down
    add_column :players, :gamemaster, :boolean
    Player.where(team: 'gamemaster').update_all(gamemaster: true)
  end
end
