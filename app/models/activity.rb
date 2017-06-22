# == Schema Information
#
# Table name: activities
#
#  id                     :integer          not null, primary key
#  player_id              :integer
#  date                   :date
#  created_at             :datetime
#  updated_at             :datetime
#  steps                  :integer          default(0), not null
#  steps_claimed          :integer          default(0), not null
#  active_minutes         :integer          default(0), not null
#  active_minutes_claimed :boolean          default(FALSE), not null
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

  def steps_unclaimed
    steps - steps_claimed
  end

  def active_goal_met?
    active_minutes >= Player::GOAL_MINUTES
  end

  def active?
    steps > 0 or active_minutes > 0
  end

  def randomize!
  attrs = {
      steps: rand(12000),
      active_minutes: rand(100),
  }
    update!(attrs)
  end


end

