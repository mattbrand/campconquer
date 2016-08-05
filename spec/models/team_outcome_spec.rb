# == Schema Information
#
# Table name: team_outcomes
#
#  id         :integer          not null, primary key
#  team       :string
#  takedowns  :integer
#  throws     :integer
#  pickups    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  outcome_id :integer
#
# Indexes
#
#  index_team_outcomes_on_outcome_id  (outcome_id)
#

require 'rails_helper'

RSpec.describe TeamOutcome, type: :model do
  it "requires team name" do
    team_outcome = TeamOutcome.new(team: nil)
    expect(team_outcome).not_to be_valid
  end

  it "validates team name" do
    team_outcome = TeamOutcome.new(team: 'blue')
    expect(team_outcome).to be_valid
  end
end
