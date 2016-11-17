# == Schema Information
#
# Table name: players
#
#  id                   :integer          not null, primary key
#  name                 :string
#  team                 :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  fitbit_token_hash    :text
#  anti_forgery_token   :string
#  coins                :integer          default("0"), not null
#  gems                 :integer          default("0"), not null
#  embodied             :boolean          default("f"), not null
#  session_token        :string
#  encrypted_password   :string
#  salt                 :string
#  gamemaster           :boolean          default("f"), not null
#  admin                :boolean          default("f"), not null
#  activities_synced_at :datetime
#
# Indexes
#
#  index_players_on_session_token  (session_token)
#

require 'rails_helper'

describe Player, type: :model do
  it "validates team name" do
    player = Player.new(name: "Joe", password: "password", team: 'blue')
    expect(player).to be_valid
    player = Player.new(name: "Joe", password: "password", team: 'mystic')
    expect(player).not_to be_valid
  end

  it "validates player name uniqueness" do
    create_player(player_name: "Joe", password: "password", team: 'blue')
    player = Player.new(name: "Joe", password: "password", team: 'red')
    expect(player).not_to be_valid
  end

  describe 'json' do
    it 'includes embodied (true)' do
      p = create_player(player_name: "Joe", password: "password", team: 'blue', embodied: true)
      expect(p.as_json).to include({embodied: true}.stringify_keys)
    end

    it 'includes embodied (false)' do
      p = create_player(player_name: "Joe", password: "password", team: 'blue', embodied: false)
      expect(p.as_json).to include({embodied: false}.stringify_keys)
    end

    it 'includes activities_synced_at' do
      nowish = Time.current - 1.minute
      p = create_player(player_name: "Joe", password: "password", team: 'blue')
      p.activities_synced_at = nowish
      expect(p.as_json).to include({activities_synced_at: nowish}.stringify_keys)
    end
  end

  describe 'set_piece' do
    let(:player) { create_player(player_name: "Joe", password: "password", team: 'blue') }

    it 'saves the piece' do
      player.set_piece()
      player.reload
      expect(player.piece).not_to be_nil
    end

    it 'has a default role' do
      player.set_piece()
      player.reload
      expect(player.piece.role).to eq('defense')
    end

    it 'only has one piece' do
      expect do
        player.set_piece(body_type: 'female')
        player.set_piece(body_type: 'male')
      end.to change(Piece, :count).by(1)

      player.reload
      expect(player.piece.body_type).to eq('male')
    end

    it 'sets the team' do
      player.set_piece()
      player.reload
      expect(player.piece.team).to eq('blue')
    end

    it 'rejects all but a few attributes' do
      {body_type: 'female',
       role: 'offense',
       path: [Point.new(x: 0, y: 0)]
      }.each_pair do |key, value|
        params = {}
        params[key] = value
        player.set_piece(params)
        expect(player.piece.send(key)).to eq(value)
      end

      {
          team: 'red',
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

  context "fitbit" do
    let(:player) { create_player(player_name: "Joe", password: "password", team: 'blue') }

    it "saves & restores a fitbit token hash" do
      hash = {bogus: true}
      player.fitbit_token_hash = hash
      player.save!
      player.reload
      expect(player.fitbit_token_hash).to eq(hash)
    end

    it "has no fitbit at first" do
      expect(player.fitbit).to be
      expect(player.fitbit.has_token?).to be_falsey
    end

    it "has a fitbit with a token based on the stored hash" do
      hash = {bogus: true}
      player.fitbit_token_hash = hash
      expect(player.fitbit.has_token?).to be_truthy
      expect(player.fitbit.has_token?.params).to include(hash)
    end

    context 'when authenticating' do
      before do
        f = Fitbit.new
        stub_request(:post, "https://api.fitbit.com/oauth2/token").
            with(
                :headers => {
                    'Authorization' => f.send(:authorization_header)
                },
                :body => {
                    "client_id" => f.client_id,
                    "client_secret" => f.client_secret,
                    "code" => "AUTH_CODE",
                    "grant_type" => "authorization_code",
                    "redirect_uri" => f.callback_url
                },
            ).
            to_return(
                :status => 200,
                :headers => {
                    "content-type": "application/json"
                },
                :body =>
                    {
                        "access_token" => "ACCESS_TOKEN",
                        "expires_in" => 28800,
                        "refresh_token" => "REFRESH_TOKEN",
                        "scope" => "sleep weight social profile activity location heartrate nutrition settings",
                        "token_type" => "Bearer",
                        "user_id" => "FITBIT_USER_ID"
                    }.to_json
            )
      end

      it 'returns a URL' do
        url = player.begin_auth
        expect(url).to be
        expect(url).to eq(player.fitbit.authorization_url(state: player.anti_forgery_token))
      end

      it 'sets an anti-forgery token on itself' do
        url = player.begin_auth
        expect(player.anti_forgery_token).to be
      end

      it 'unsets an anti-forgery token on itself' do
        url = player.begin_auth
        player.finish_auth('AUTH_CODE')
        expect(player.anti_forgery_token).not_to be
        expect(player.reload.anti_forgery_token).to be_nil
      end

      it 'sets a fitbit token on itself' do
        expect(player.fitbit_token_hash).not_to be
        url = player.begin_auth
        player.finish_auth('AUTH_CODE')
        expect(player.fitbit_token_hash).to be
        expect(player.fitbit_token_hash).to include(access_token: 'ACCESS_TOKEN')
      end
    end

  end


  describe 'default gear' do
    let!(:galoshes) { Gear.create!(name: 'galoshes', gear_type: 'shoes', coins: 10) }
    let!(:tee_shirt) { Gear.create!(name: 'tee-shirt', gear_type: 'shirt', coins: 0) }

    describe 'owned' do
      before do
        tee_shirt.update!(owned_by_default: true)
        @player = create_player(player_name: "alice", password: "password", team: 'blue', coins: 15)
      end
      it 'is owned by a new player' do
        expect(@player.gear_owned).to eq(['tee-shirt'])
        expect(@player.gear_equipped).to eq([])
      end
    end

    describe 'equipped' do
      before do
        tee_shirt.update!(equipped_by_default: true)
        @player = create_player(player_name: "alice", team: 'blue', coins: 15)
      end
      it 'is equipped by a new player' do
        expect(@player.gear_owned).to eq(['tee-shirt'])
        expect(@player.gear_equipped).to eq(['tee-shirt'])
      end
    end
  end

  describe 'gear' do
    let!(:player) { create_player(player_name: "alice", team: 'blue', coins: 15, gems: 1) }
    let!(:galoshes) { Gear.create!(name: 'galoshes', gear_type: 'shoes', coins: 10, gems: 1) }
    let!(:tee_shirt) { Gear.create!(name: 'tee-shirt', gear_type: 'shirt', coins: 20, gems: 1) }

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
        slippers = Gear.create!(name: 'slippers', gear_type: 'shoes', coins: 10, gems: 1)

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
        Gear.create!(name: 'flip-flops', gear_type: 'shoes', coins: 0, gems: 0,
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
    let!(:player) { create_player(player_name: "alice", team: 'blue', coins: 1500) }

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

  context "login" do
    context "on player creation" do
      it 'needs a valid password' do
        expect do
          create_player(player_name: "alice", password: 'xyz')
        end.to raise_error(ActiveRecord::RecordInvalid)
      end

      let(:good_password) { 'mydoghasfleas' }

      it 'stores the password' do
        player = create_player(player_name: "alice", password: good_password)
        expect(player.has_password?(good_password)).to be_truthy
        expect(player.reload.has_password?(good_password)).to be_truthy
      end

      it 'stores the password encrypted and salted' do
        player = create_player(player_name: "alice", password: good_password)
        player.reload
        expect(player.encrypted_password).not_to be_blank
        expect(player.salt).not_to be_blank
      end
    end
  end

  context "after creation" do
    let(:good_password) { 'mydoghasfleas' }
    let!(:alice) { create_player(player_name: 'alice', password: good_password) }

    it "can create a session token" do
      token = alice.start_session
      expect(token).to be
      alice.reload
      expect(token).to eq(alice.session_token)
    end

    it "can be found via a session token" do
      token = alice.start_session
      player = Player.for_session(token)
      expect(player).to eq(alice)
    end
  end

  context "if a player has no password" do
    let!(:alice) { create_player(player_name: 'alice', password: nil) }

    it "has no encrypted password" do
      expect(alice.encrypted_password).to be_nil
    end

    it "is not equivalent to having a nil password" do
      expect(alice.has_password?(nil)).to be_falsey
    end

    it "is not equivalent to having a blank password" do
      expect(alice.has_password?('')).to be_falsey
    end
  end

end
