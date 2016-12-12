# == Schema Information
#
# Table name: items
#
#  id        :integer          not null, primary key
#  piece_id  :integer          not null
#  equipped  :boolean          default("f"), not null
#  gear_name :string
#
# Indexes
#
#  index_items_on_piece_id_and_gear_id  (piece_id)
#

class Item < ActiveRecord::Base
  belongs_to :piece

  def gear
    Gear.find_by_name(gear_name)
  end
end
