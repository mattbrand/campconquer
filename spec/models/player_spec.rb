# == Schema Information
#
# Table name: players
#
#  id                   :integer          not null, primary key
#  name                 :string
#  team_name            :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  fitbit_token_hash    :text
#  anti_forgery_token   :string
#  coins                :integer          default(0), not null
#  gems                 :integer          default(0), not null
#  embodied             :boolean          default(FALSE), not null
#  session_token        :string
#  encrypted_password   :string
#  salt                 :string
#  admin                :boolean          default(FALSE), not null
#  activities_synced_at :datetime
#
# Indexes
#
#  index_players_on_session_token  (session_token)
#

require 'rails_helper'

describe Player, type: :model do
  it "validates team_name name" do
    player = Player.new(name: "Joe", password: "password", team_name: 'blue')
    expect(player).to be_valid
    player = Player.new(name: "Joe", password: "password", team_name: 'mystic')
    expect(player).not_to be_valid
  end

  it "validates player name uniqueness" do
    create_player(player_name: "Joe", password: "password", team_name: 'blue')
    player = Player.new(name: "Joe", password: "password", team_name: 'red')
    expect(player).not_to be_valid
  end

  describe 'json' do
    it 'includes embodied (true)' do
      p = create_player(player_name: "Joe", password: "password", team_name: 'blue', embodied: true)
      expect(p.as_json).to include({embodied: true}.stringify_keys)
    end

    it 'includes embodied (false)' do
      p = create_player(player_name: "Joe", password: "password", team_name: 'blue', embodied: false)
      expect(p.as_json).to include({embodied: false}.stringify_keys)
    end

    it 'includes activities_synced_at' do
      nowish = Time.current - 1.minute
      p = create_player(player_name: "Joe", password: "password", team_name: 'blue')
      p.activities_synced_at = nowish
      expect(p.as_json).to include({activities_synced_at: nowish}.stringify_keys)
    end

    it 'includes gamemaster' do
      p = create_gamemaster
      expect(p.as_json).to include({gamemaster: true}.stringify_keys)
      p = create_player
      expect(p.as_json).to include({gamemaster: false}.stringify_keys)
    end
  end

  describe 'set_piece' do
    let(:player) { create_player(player_name: "Joe", password: "password", team_name: 'blue') }

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

    it 'sets the team_name' do
      player.set_piece()
      player.reload
      expect(player.piece.team_name).to eq('blue')
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
          team_name: 'red',
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
    let(:player) { create_player(player_name: "Joe", password: "password", team_name: 'blue') }

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

  describe 'is_one_of_these?' do
    let!(:gertie) { create_gamemaster() }
    it 'works' do
      expect(gertie.is_one_of_these?(['gamemaster', 'admin'])).to eq(true)
      expect(gertie.is_one_of_these?(['in_control_group', 'admin'])).to eq(false)
    end
  end

end
