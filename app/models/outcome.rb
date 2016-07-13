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

class Outcome < ActiveRecord::Base
  belongs_to :game
  has_many :team_outcomes, dependent: :destroy
  accepts_nested_attributes_for :team_outcomes

  validates :winner, inclusion: {
    in: Team::NAMES.values + ["none"],
    message: Team::NAMES.validation_message + ' or "none"',
  }

end
