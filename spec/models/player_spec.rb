# == Schema Information
#
# Table name: players
#
#  id         :integer          not null, primary key
#  name       :string
#  team       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

describe Player, type: :model do
  it "validates team name" do
    player = Player.new(name: "Joe", team: 'blue')
    expect(player).to be_valid
  end

  it "validates player name uniqueness"

  describe 'set_piece' do
    let(:player) { Player.create!(name: "Joe", team: 'blue') }

    it 'saves the piece' do
      player.set_piece()
      player.reload
      expect(player.piece).not_to be_nil
    end

    it 'only has one piece' do
      expect do
        player.set_piece(job: 'striker')
        player.set_piece(job: 'bruiser')
      end.to change(Piece, :count).by(1)

      player.reload
      expect(player.piece.job).to eq('bruiser')
    end

    it 'sets the team' do
      player.set_piece()
      player.reload
      expect(player.piece.team).to eq('blue')
    end

    it 'rejects all but a few attributes' do
      {job: 'striker', role: 'offense', path: [{'x' => 0, 'y' => 0}]}.each_pair do |key, value|
        params = {}
        params[key] = value
        player.set_piece(params)
        expect(player.piece.send(key)).to eq(value)
      end
      {
        team: 'red',
        speed: 9,
        hit_points: 9,
        range: 9,
        created_at: 9,
        updated_at: 9,
        game_id: 9999,
        player_id: 9999,
      }.each_pair do |key, value|
        params = {}
        params[key] = value
        player.set_piece(params)
        expect(player.piece.send(key)).not_to eq(value)
      end

    end
  end
end
