# == Schema Information
#
# Table name: team_outcomes
#
#  id            :integer          not null, primary key
#  team          :string
#  takedowns     :integer
#  throws        :integer
#  pickups       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  team_stats_id :integer
#  outcome_id    :integer
#
# Indexes
#
#  index_team_outcomes_on_outcome_id  (outcome_id)
#

class TeamOutcome < ActiveRecord::Base
  belongs_to :outcome
  validates :team, inclusion: { in: Team::NAMES.values, message: Team::NAMES.validation_message}
end
