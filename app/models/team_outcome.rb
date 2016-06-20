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

class TeamOutcome < ActiveRecord::Base
  belongs_to :outcome
  # todo: team enum validation
end
