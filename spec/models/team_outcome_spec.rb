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

require 'rails_helper'

RSpec.describe TeamOutcome, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
