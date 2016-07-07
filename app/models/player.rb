# == Schema Information
#
# Table name: players
#
#  id         :integer          not null, primary key
#  name       :string
#  team       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Player < ActiveRecord::Base
  validates :team, inclusion: { in: Team::NAMES.values, message: Team::NAMES.validation_message}
end
