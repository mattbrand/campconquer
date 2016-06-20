# == Schema Information
#
# Table name: outcomes
#
#  id            :integer          not null, primary key
#  winner        :string
#  team_stats_id :integer
#  match_length  :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Outcome < ActiveRecord::Base
  has_many :team_outcomes
end
