# == Schema Information
#
# Table name: games
#
#  id           :integer          not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  locked       :boolean
#  current      :boolean          default("f")
#  season_id    :integer
#  state        :string           default("preparing")
#  moves        :text
#  winner       :string
#  match_length :integer          default("0"), not null
#
# Indexes
#
#  index_games_on_current    (current)
#  index_games_on_season_id  (season_id)
#

require 'rails_helper'
require 'files'

describe Gear do
  include Files

  before do
    @f = file "foo.csv", <<-CSV
Name,Type,Body Type,Display Name,Description,Asset Name,Icon Name,Coins,Gems,Level,Health Bonus,Speed Bonus,Range Bonus,Hair,Owned By Default,Equipped By Default
hat0,HEAD,GN1,Headscarf,a lovely scarf,hair_headscarf,scarf_icon,1,2,3,4,5,6,hair_short_01_gn1,1,0
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
                             owned_by_default: true,
                             equipped_by_default: false,
                           }.with_indifferent_access)
    end

    let(:player) { Player.create!(name: "Joe", team: 'blue', coins: 10) }

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
