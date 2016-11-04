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

class Session < ActiveRecord::Base
  attr_accessor :name

  belongs_to :player

  def initialize(attrs={})
    @name = attrs.delete(:name) if attrs
    super
  end
end
