# == Schema Information
#
# Table name: gears
#
#  id                  :integer          not null, primary key
#  name                :string
#  display_name        :string
#  description         :string
#  health_bonus        :integer          default("0"), not null
#  speed_bonus         :integer          default("0"), not null
#  range_bonus         :integer          default("0"), not null
#  gear_type           :string
#  asset_name          :string
#  icon_name           :string
#  coins               :integer          default("0"), not null
#  gems                :integer          default("0"), not null
#  level               :integer          default("0"), not null
#  equipped_by_default :boolean          default("f"), not null
#  owned_by_default    :boolean          default("f"), not null
#  hair                :string
#  body_type           :string
#  color_decal         :boolean          default("f"), not null
#

require 'rails_helper'
require 'files'

describe Gear do
  include Files

  before do
    @f = file "foo.csv", <<-CSV
Name,Type,Body Type,Display Name,Description,Asset Name,Icon Name,Coins,Gems,Level,Health Bonus,Speed Bonus,Range Bonus,Hair,Owned By Default,Equipped By Default
hat0,HEAD,GENDER_NEUTRAL_1,Headscarf,a lovely scarf,hair_headscarf,scarf_icon,1,2,3,4,5,6,hair_short_01_gn1,1,0
    CSV
    Gear.read_csv(@f)
  end

  describe 'read_csv' do
    it 'loads a piece of gear with some values' do
      expect(Gear.all.size).to eq(1)
      g = Gear.first
      expect(g.attributes).to include({
                             name: 'hat0',
                             gear_type: 'head',
                             display_name: 'Headscarf',
                             description: 'a lovely scarf',
                             asset_name: 'hair_headscarf',
                             icon_name: 'scarf_icon',
                             health_bonus: 4,
                             speed_bonus: 5,
                             range_bonus: 6,
                             coins: 1,
                             gems: 2,
                             level: 3,
                             body_type: 'gender_neutral_1',
                             hair: 'hair_short_01_gn1',
                             owned_by_default: true,
                             equipped_by_default: false,
                           }.with_indifferent_access)
    end

    let(:player) { create_player(player_name: "Joe", team: 'blue', coins: 10) }

    it 'regenerates player/piece items' do
      expect(player.gear_owned).to eq(['hat0'])
      player.equip_gear! 'hat0'
      expect(player.gear_equipped).to eq(['hat0'])

      original_gear_id = Gear.find_by_name('hat0').id

      Gear.read_csv(@f)

      new_gear_id = Gear.find_by_name('hat0').id
      expect(new_gear_id).not_to eq(original_gear_id)

      player.reload
      expect(player.gear_owned).to eq(['hat0'])
      expect(player.gear_equipped).to eq(['hat0'])
    end
  end
end
