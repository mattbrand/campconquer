require 'rails_helper'

describe Player, type: :model do
  let!(:galoshes) { Gear.new(name: 'galoshes', gear_type: 'shoes', coins: 10, gems: 1) }
  let!(:tee_shirt) { Gear.new(name: 'tee-shirt', gear_type: 'shirt', coins: 20, gems: 1) }
  before { Gear.all = [galoshes, tee_shirt] }
  after { Gear.reset }

  describe 'default gear' do

    describe 'owned' do
      before do
        tee_shirt.owned_by_default = true
        @player = create_player(player_name: "alice", coins: 100, gems: 10)
      end

      it 'is owned by a new player' do
        expect(@player.gear_owned).to eq(['tee-shirt'])
        expect(@player.gear_equipped).to eq([])
      end
    end

    describe 'equipped' do
      before do
        tee_shirt.equipped_by_default = true
        @player = create_player(player_name: "alice", coins: 100, gems: 10)
      end
      it 'is equipped by a new player' do
        expect(@player.gear_owned).to eq(['tee-shirt'])
        expect(@player.gear_equipped).to eq(['tee-shirt'])
      end
    end
  end

  describe 'gear' do
    let!(:player) { create_player(player_name: "alice", team_name: 'blue', coins: 15, gems: 1) }

    before do
      player.set_piece
    end

    describe 'buying' do
      it 'adds the gear to inventory' do
        expect(player.gear_owned).to be_empty
        player.buy_gear!('galoshes')
        expect(player.gear_owned).to eq(['galoshes'])
      end

      it 'does not automatically equip the gear' do
        expect(player.gear_owned).to be_empty
        player.buy_gear!('galoshes')
        expect(player.gear_equipped).to eq([])
      end

      it 'subtracts coins' do
        expect(player.reload.coins).to eq(15)
        player.buy_gear!('galoshes')
        expect(player.reload.coins).to eq(5)
      end

      it 'fails if not enough coins' do
        expect do
          player.buy_gear!('tee-shirt')
        end.to raise_error(Player::NotEnoughMoney)
        expect(player.reload.coins).to eq(15)
      end

      it 'subtracts gems' do
        expect(player.reload.gems).to eq(1)
        player.buy_gear!('galoshes')
        expect(player.reload.gems).to eq(0)
      end

      it 'fails if not enough gems' do
        player.update!(gems: 0)
        expect do
          player.buy_gear!('galoshes')
        end.to raise_error(Player::NotEnoughMoney)
        expect(player.reload.gems).to eq(0)
      end

      it 'does not allow buying twice' do
        player.buy_gear!('galoshes')
        expect do
          player.buy_gear!('galoshes')
        end.to raise_error(Player::AlreadyOwned)
        expect(player.reload.coins).to eq(5)
      end
    end

    describe 'equipping' do
      it 'equips owned gear' do
        player.buy_gear!('galoshes')
        expect(player.gear_equipped).to eq([])
        player.equip_gear!('galoshes')
        expect(player.gear_equipped).to eq(['galoshes'])
      end

      it 'fails to equip unowned gear' do
        expect do
          player.equip_gear!('galoshes')
        end.to raise_error(Player::NotOwned)
      end

      it 'equipping already equipped gear is a no-op' do
        player.buy_gear!('galoshes')
        player.equip_gear!('galoshes')
        player.equip_gear!('galoshes')
        expect(player.gear_equipped).to eq(['galoshes'])
      end

      it 'equipping gear of a certain type un-equips other gear of the same type' do
        player.update!(gems: 10, coins: 100)

        Gear.add Gear.new(name: 'slippers', gear_type: 'shoes', coins: 10, gems: 1)

        player.buy_gear!('galoshes')
        player.buy_gear!('slippers')

        player.equip_gear!('galoshes')
        player.equip_gear!('slippers')
        expect(player.gear_equipped).to eq(['slippers'])
      end
    end

    describe 'unequipping' do
      it 'unequips an equipped piece of gear' do
        player.buy_gear!('galoshes')
        player.equip_gear!('galoshes')
        expect(player.gear_equipped).to eq(['galoshes'])
        player.unequip_gear!('galoshes')
        expect(player.gear_equipped).to eq([])
      end

      it 'ignores a not equipped piece of gear' do
        player.update!(gems: 10, coins: 100)

        player.buy_gear!('tee-shirt')
        player.buy_gear!('galoshes')
        player.equip_gear!('galoshes')

        player.unequip_gear!('tee-shirt')
        expect(player.gear_equipped).to eq(['galoshes'])
      end

      it 'fails to equip unowned gear' do
        expect do
          player.unequip_gear!('galoshes')
        end.to raise_error(Player::NotOwned)
      end

      it 're-equips default gear' do
        Gear.add Gear.new(name: 'flip-flops', gear_type: 'shoes',
                          coins: 0, gems: 0,
                          equipped_by_default: true, owned_by_default: true)
        player.buy_gear!('flip-flops')
        player.buy_gear!('galoshes')
        player.equip_gear!('galoshes')
        expect(player.gear_equipped).to eq(['galoshes'])
        player.unequip_gear!('galoshes')
        expect(player.gear_equipped).to eq(['flip-flops'])
      end
    end

    describe 'dropping' do
      it 'drops owned gear' do
        player.buy_gear!('galoshes')
        player.drop_gear!('galoshes')
        expect(player.gear_owned).to eq([])
      end

      it 'unequips dropped gear' do
        player.buy_gear!('galoshes')
        player.equip_gear!('galoshes')
        player.drop_gear!('galoshes')
        expect(player.gear_equipped).to eq([])
      end

      it 'dropping unowned gear is a failure' do
        expect do
          player.drop_gear!('galoshes')
        end.to raise_error(Player::NotOwned)
      end
    end

  end

  describe 'ammo' do
    let!(:player) { create_player(player_name: "alice", team_name: 'blue', coins: 1500) }

    it 'is empty by default' do
      expect(player.ammo).to be_empty
    end

    describe 'buying one piece of ammo' do
      before { player.buy_ammo! 'balloon' }

      it 'puts it in the player' do
        expect(player.ammo).to eq(['balloon'])
      end

      it 'puts it in the piece' do
        expect(player.piece.ammo).to eq(['balloon'])
      end

      it 'puts it in the json' do
        json = player.as_json
        expect(json['piece']['ammo']).to eq(['balloon'])
      end

      it 'costs money' do
        expect(player.coins).to eq(1500 - 25)
      end
    end

    describe 'buying a few pieces of ammo' do
      before do
        player.buy_ammo! 'balloon'
        player.buy_ammo! 'arrow'
        player.buy_ammo! 'bomb'
      end

      it 'puts them at the end of the ammo list' do
        expect(player.ammo).to eq(['balloon', 'arrow', 'bomb'])
      end

      it 'costs money' do
        expect(player.coins).to eq(1500 - (25 + 50 + 100))
      end

      it 'bugfix: gets serialized correctly after locking/copying' do
        game = Game.current
        game.lock_game!
        game.as_json # was giving "JSON::ParserError" since ammo field became YAML during bulk copy
      end

    end

    it 'can only hold 10' do
      10.times do
        player.buy_ammo! 'balloon'
      end

      expect do
        player.buy_ammo! 'balloon'
      end.to raise_error Player::NotEnoughSpace

    end

    it 'fails if not enough money' do
      player.update!(coins: 10)
      expect do
        player.buy_ammo! 'balloon'
      end.to raise_error Player::NotEnoughMoney
    end

  end

end
