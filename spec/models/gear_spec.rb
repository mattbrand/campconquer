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

  let(:csv_header) { "Name,Type,Body Type,Display Name,Description,Asset Name,Icon Name,Coins,Gems,Level,Health Bonus,Speed Bonus,Range Bonus,Hair,Owned By Default,Equipped By Default" }
  let(:good_row) { "hat0,HEAD,GENDER_NEUTRAL_1,Headscarf,a lovely scarf,hair_headscarf,scarf_icon,1,2,3,4,5,6,hair_short_01_gn1,1,0" }

  before { load_csv }
  after { Gear.reset }

  def load_csv(row = good_row)
    @f = file "foo.csv", [csv_header, row].join("\n")
    Gear.all = Gear.read_csv(@f)
  end

  describe 'read_csv' do
    it 'loads a piece of gear with some values' do
      expect(Gear.all.size).to eq(1)
      g = Gear.all.first
      expect(g.as_json.with_indifferent_access).to include({
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

    it 'checks for bogus gear types' do
      expect do
        load_csv(good_row.gsub('HEAD', 'ELBOW'))
      end.to raise_error(ArgumentError, 'Validation failed: Gear type must be "head" or "shirt" or "belt" or "shoes" or "accessory" or "pet"')
    end

    it 'checks for duplicate gear names' do
      expect do
        load_csv(good_row + "\n" + good_row)
      end.to raise_error(ArgumentError, 'Gear name must be unique, but we already have gear named \'hat0\'')
    end

    it 'checks for items with previously OK, but now missing gear names' do
      # let's say we have a player with a "hat0" (the default hat)
      p = create_player player_name: 'alice', coins: 10, gems: 10

      # but we (mistakenly) rename hat0 to beanie in the CSV
      expect do
        load_csv(good_row.gsub('hat0', 'beanie'))
      end.to raise_error(ArgumentError, "Found items with gear ('hat0') missing from the current gear list. Deleting.")

    end

  end
end
