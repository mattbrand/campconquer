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
  has_many :pieces
  has_one :outcome

  # todo: move winner from game to outcome
  validates_presence_of :winner, unless: :new_record?
  validates :winner, inclusion: {
    in: Team::NAMES.values,
    message: Team::NAMES.validation_message,
    allow_nil: true
  }

  before_create do
    self.locked = true
  end
end
