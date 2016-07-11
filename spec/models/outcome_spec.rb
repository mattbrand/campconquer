# == Schema Information
#
# Table name: outcomes
#
#  id           :integer          not null, primary key
#  winner       :string
#  match_length :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  game_id      :integer
#
# Indexes
#
#  index_outcomes_on_game_id  (game_id)
#

require 'rails_helper'

RSpec.describe Outcome, type: :model do

  it "requires a winner" do
    team_outcome = Outcome.new(winner: nil)
    expect(team_outcome).not_to be_valid
  end

  it "validates winner's team name" do
    outcome = Outcome.new(winner: 'blue')
    expect(outcome).to be_valid
  end
end
