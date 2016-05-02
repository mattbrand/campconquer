# == Schema Information
#
# Table name: games
#
#  id         :integer          not null, primary key
#  winner     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  locked     :boolean
#

class Game < ActiveRecord::Base
  validates_presence_of :winner, unless: :new_record?

  before_create do
    self.locked = true
  end
end
