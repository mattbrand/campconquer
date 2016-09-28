# == Schema Information
#
# Table name: players
#
#  id                 :integer          not null, primary key
#  name               :string
#  team               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  fitbit_token_hash  :text
#  anti_forgery_token :string
#  coins              :integer          default("0"), not null
#  gems               :integer          default("0"), not null
#

require 'rails_helper'

describe Player, type: :model do
  it "validates team name" do
    player = Player.new(name: "Joe", team: 'blue')
    expect(player).to be_valid
    player = Player.new(name: "Joe", team: 'mystic')
    expect(player).not_to be_valid
  end

  it "validates player name uniqueness" do
    Player.create!(name: "Joe", team: 'blue')
    player = Player.new(name: "Joe", team: 'red')
    expect(player).not_to be_valid
  end

  describe 'set_piece' do
    let(:player) { Player.create!(name: "Joe", team: 'blue') }

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
          speed: 9,
          health: 9,
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

  context "fitbit" do
    let(:player) { Player.create!(name: "Joe", team: 'blue') }

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

  describe 'exercise - ' do
    let!(:player) { Player.create!(name: "Alice", team: 'blue') }
    let!(:fake_fitbit) { instance_double(Fitbit) }
    let(:today) { Time.current.strftime('%F') }
    let(:yesterday) { (Time.current - 1.day).strftime('%F') }

    before do
      player.instance_variable_set(:@fitbit, fake_fitbit)
    end

    describe 'claim_steps!' do
      context 'with one day of activity' do
        before { player.activities.create!(date: Date.current, steps: 1000) }

        it 'converts steps into coins' do
          expect(player.coins).to eq(0)
          player.claim_steps!
          player.reload
          expect(player.coins).to eq(100)
        end

        it 'adds to existing coin amount' do
          player.update!(coins: 9)
          player.claim_steps!
          player.reload
          expect(player.coins).to eq(109)
        end

        it 'edits activity to reflect the claimed count' do
          player.claim_steps!
          expect(player.activities.first.steps_claimed).to eq(1000)
        end
      end

      context 'with several days of activity' do
        let!(:activity_yesterday) { player.activities.create!(date: Date.current - 1.day, steps: 100) }
        let!(:activity_today) { player.activities.create!(date: Date.current, steps: 50) }

        it 'converts steps into coins' do
          expect(player.coins).to eq(0)
          player.claim_steps!
          player.reload
          expect(player.coins).to eq(15)
        end

        it 'edits activity to reflect the claimed count' do
          player.claim_steps!
          expect(activity_yesterday.reload.steps_claimed).to eq(100)
          expect(activity_today.reload.steps_claimed).to eq(50)
        end

        it "keeps the remainder of steps (if we didn't have enough for one coin)" do
          activity_yesterday.update!(steps: 101)
          activity_today.update!(steps: 53)

          player.claim_steps!

          expect(player.coins).to eq(15)
          expect(activity_yesterday.reload.steps_claimed).to eq(101)
          expect(activity_today.reload.steps_claimed).to eq(49)
          expect(player.steps_available).to eq(4)

        end

        it "spreads claims over several days" do
          activity_yesterday.update!(steps: 7)
          activity_today.update!(steps: 4)

          player.claim_steps!

          expect(player.coins).to eq(1)

          expect(activity_yesterday.reload.steps_claimed).to eq(7)
          expect(activity_today.reload.steps_claimed).to eq(3)
          expect(player.steps_available).to eq(1)

        end
      end

      it 'maxes out at 10000 steps' do
        player.activities.create!(date: Date.current, steps: 12345)
        player.claim_steps!
        expect(player.coins).to eq(1000)
        expect(player.steps_available).to eq(0)
      end

    end

    describe 'steps_available' do
      it 'adds up steps (one record)' do
        player.activities.create!(date: Date.current, steps: 100)
        expect(player.steps_available).to eq(100)
      end

      context 'several records' do
        it 'adds up steps (several records)' do
          player.activities.create!(date: Date.current - 1.day, steps: 100)
          player.activities.create!(date: Date.current, steps: 50)

          expect(player.steps_available).to eq(150)
        end

        it 'adds up steps and subtracts redemptions' do
          player.activities.create!(date: Date.current - 1.day, steps: 100, steps_claimed: 100)
          player.activities.create!(date: Date.current, steps: 50, steps_claimed: 25)

          expect(player.steps_available).to eq(25)
        end
      end
    end

    describe 'pull_activity!' do

      def summary(steps: 12612, fairly_active: 20, very_active: 10)
        {
            "summary" => {
                "steps" => steps,
                "fairlyActiveMinutes" => fairly_active,
                "veryActiveMinutes" => very_active,
            }
        }
      end

      it 'pulls steps from the fitbit' do
        expect(fake_fitbit).to receive(:get_activities).with(today).and_return(summary)
        player.pull_activity!
        expect(player.steps_available).to eq(12612)
      end

      it "idempotently ignores steps it's already pulled" do
        expect(fake_fitbit).to receive(:get_activities).with(today).and_return(summary, summary)
        player.pull_activity!
        player.pull_activity!
        expect(player.steps_available).to eq(12612)
      end

      it "subtracts steps it's already claimed from new steps" do
        expect(fake_fitbit).to receive(:get_activities).with(today).and_return(summary(steps: 400), summary(steps: 600))
        player.pull_activity!
        expect(player.steps_available).to eq(400)
        player.claim_steps!
        player.pull_activity!
        expect(player.steps_available).to eq(200)
      end

      it 'pulls minutes from the fitbit' do
        expect(fake_fitbit).to receive(:get_activities).with(today).and_return(summary)
        player.pull_activity!
        expect(player.active_minutes).to eq(30)
      end

    end
  end

  describe 'active minute goals' do
    let(:player) { Player.create!(name: "Joe", team: 'blue') }

    context "when today's goal has not been reached" do
      before { player.activities.create!(date: Date.current, active_minutes: 20) }

      it "is not met" do
        expect(player.active_goal_met?).to be_falsey
      end

      it "is not claimable" do
        expect { player.claim_active_minutes! }.to raise_error(Player::GoalNotMet)
        expect(player.gems).to eq(0)
        expect(player.activity_today.active_minutes_claimed).to be_falsey
      end
    end

    context "when today's goal has been reached" do
      before { player.activities.create!(date: Date.current,
                                         active_minutes: Player::GOAL_MINUTES + 20) }

      it "is met" do
        expect(player.active_goal_met?).to be_truthy
      end

      it "is claimable" do
        player.claim_active_minutes!
        expect(player.gems).to eq(1)
        expect(player.activity_today.active_minutes_claimed).to be_truthy
      end

      it "is only claimable once (idempotency)" do
        player.claim_active_minutes!
        player.claim_active_minutes!
        expect(player.gems).to eq(1)
      end
    end
  end

  describe 'default gear' do
    let!(:galoshes) { Gear.create!(name: 'galoshes', gear_type: 'shoes', coins: 10) }
    let!(:tee_shirt) { Gear.create!(name: 'tee-shirt', gear_type: 'shirt', coins: 0) }

    describe 'owned' do
      before do
        tee_shirt.update!(owned_by_default: true)
        @player = Player.create!(name: "alice", team: 'blue', coins: 15)
      end
      it 'is owned by a new player' do
        expect(@player.gear_owned).to eq(['tee-shirt'])
        expect(@player.gear_equipped).to eq([])
      end
    end

    describe 'equipped' do
      before do
        tee_shirt.update!(equipped_by_default: true)
        @player = Player.create!(name: "alice", team: 'blue', coins: 15)
      end
      it 'is equipped by a new player' do
        expect(@player.gear_owned).to eq(['tee-shirt'])
        expect(@player.gear_equipped).to eq(['tee-shirt'])
      end
    end
  end

  describe 'gear' do
    let!(:player) { Player.create!(name: "alice", team: 'blue', coins: 15) }
    let!(:galoshes) { Gear.create!(name: 'galoshes', gear_type: 'shoes', coins: 10) }
    let!(:tee_shirt) { Gear.create!(name: 'tee-shirt', gear_type: 'shirt', coins: 20) }

    before do
      player.set_piece
    end

    describe 'buying' do
      it 'adds the gear to inventory' do
        expect(player.gear_owned).to be_empty
        player.buy_gear!('galoshes')
        expect(player.gear_owned).to eq(['galoshes'])
      end
      it 'subtracts coins' do
        expect(player.reload.coins).to eq(15)
        player.buy_gear!('galoshes')
        expect(player.reload.coins).to eq(5)
      end
      it 'fails if not enough coins' do
        expect do
          player.buy_gear!('tee-shirt')
        end.to raise_error(Player::NotEnoughCoins)
        expect(player.reload.coins).to eq(15)
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
end
