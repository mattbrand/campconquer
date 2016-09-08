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
#  gear_type    :string
#  asset_name   :string
#  icon_name    :string
#  coins        :integer          default("0"), not null
#  gems         :integer          default("0"), not null
#  level        :integer          default("0"), not null
#

class Gear < ActiveRecord::Base

  GEAR_TYPES = Enum.new([
                     [:head], [:shirt], [:belt], [:shoes], [:accessory], [:pet],
                   ])

  validates :gear_type, inclusion: {
    in: GEAR_TYPES.values,
    message: GEAR_TYPES.validation_message
  }, allow_nil: true

  def as_json(options=nil)
    if options.nil?
      options = {
        only: [
          :name,
          :gear_type,
          :display_name,
          :description,
          :health_bonus,
          :speed_bonus,
          :range_bonus,
          :coins,
          :gems,
          :level,
          :asset_name,
          :icon_name,
        ],
      }
    end
    super(options)
  end

end
