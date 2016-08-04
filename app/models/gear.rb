# == Schema Information
#
# Table name: gears
#
#  id           :integer          not null, primary key
#  name         :string
#  display_name :string
#  description  :string
#  health_bonus :integer
#  speed_bonus  :integer
#  range_bonus  :integer
#

class Gear < ActiveRecord::Base

end
