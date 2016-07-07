# == Schema Information
#
# Table name: games
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  locked     :boolean
#

class Game < ActiveRecord::Base
  has_many :pieces
  has_one :outcome

  before_create do
    self.locked = true
  end
end
