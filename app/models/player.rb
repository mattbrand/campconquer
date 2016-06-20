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
  # todo: use https://gist.github.com/alexch/a7be54e1b085718473ff for team enum (Rails enums are stupid)
  # todo: AR validation of enum values
  # todo: the above in every model with a `team` string
end
