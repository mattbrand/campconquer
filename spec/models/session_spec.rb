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
  it 'sets name as an instance var, to repopulate the form in case of error' do
    s = Session.new(name: "Agent Smith", token: 'WHATEVERMAN')
    expect(s.name).to eq("Agent Smith")
  end
end
