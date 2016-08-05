# == Schema Information
#
# Table name: items
#
#  piece_id :integer          not null
#  gear_id  :integer          not null
#  equipped :boolean          default("f"), not null
#
# Indexes
#
#  index_items_on_piece_id_and_gear_id  (piece_id,gear_id)
#


class Item < ActiveRecord::Base
  belongs_to :piece
  belongs_to :gear

  def gear_name
    gear.name
  end
end
