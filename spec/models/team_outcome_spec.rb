# == Schema Information
#
# Table name: team_outcomes
#
#  id         :integer          not null, primary key
#  team       :string
#  deaths     :integer
#  takedowns  :integer
#  throws     :integer
#  captures   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
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
