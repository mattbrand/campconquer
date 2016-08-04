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

  def as_json(options=nil)
    if options.nil?
      options = {
        only: [
          :name,
          :display_name,
          :description,
          :health_bonus,
          :speed_bonus,
          :range_bonus,
        ],
      }
    end
    super(options)
  end

end
