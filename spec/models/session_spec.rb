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
  it 'sets name (login username) as an instance var, to repopulate the form in case of error' do
    s = Session.new(name: "Agent Smith", token: 'WHATEVERMAN')
    expect(s.name).to eq("Agent Smith")
  end

  it 'does not expire immediately' do
    expect(Session.new).not_to be_expired
    expect(Session.create!).not_to be_expired
  end

  it 'expires after a week or so' do
    s = Session.create!
    expire_session(s)
    expect(s).to be_expired
  end
end
