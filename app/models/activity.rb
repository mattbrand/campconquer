# == Schema Information
#
# Table name: activities
#
#  id                     :integer          not null, primary key
#  player_id              :integer
#  date                   :date
#  created_at             :datetime
#  updated_at             :datetime
#  steps                  :integer          default("0"), not null
#  steps_redeemed         :integer          default("0"), not null
#  very_active_minutes    :integer          default("0"), not null
#  fairly_active_minutes  :integer          default("0"), not null
#  lightly_active_minutes :integer          default("0"), not null
#
# Indexes
#
#  index_activities_on_date       (date)
#  index_activities_on_player_id  (player_id)
#

class Activity < ActiveRecord::Base
  belongs_to :player
  validates :date, presence: true
  validates_uniqueness_of :date, scope: :player_id

  def steps_unredeemed
    steps - steps_redeemed
  end
end

