# == Schema Information
#
# Table name: memberships
#
#  id        :integer          not null, primary key
#  season_id :integer          not null
#  team_name :string           not null
#  player_id :integer          not null
#

class Membership < ActiveRecord::Base
  belongs_to :season
  belongs_to :player
  has_one :piece, through: :player

  # todo: unit test (it is tested through season)
  def set_player_team!
    player.update!(team_name: team_name) if player.team_name != team_name
    piece.update!(team_name: team_name) if piece.team_name != team_name
  end

end
