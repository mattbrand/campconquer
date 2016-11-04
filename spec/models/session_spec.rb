# == Schema Information
#
# Table name: sessions
#
#  id         :integer          not null, primary key
#  player_id  :integer
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_sessions_on_player_id  (player_id)
#  index_sessions_on_token      (token)
#

require 'rails_helper'

RSpec.describe Session, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
