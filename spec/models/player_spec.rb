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
#

require 'rails_helper'

describe Player, type: :model do
  it "validates team name" do
    player = Player.new(name: "Joe", team: 'blue')
    expect(player).to be_valid
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
       path: [Point.new(x:0, y:0)]
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
end
