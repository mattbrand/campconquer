class Game < ActiveRecord::Base
  validates_presence_of :winner, unless: :new_record?
end
