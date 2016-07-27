# todo:
# error handling
# unit tests
# refresh

class Fitbit

  # todo: get these from ENV

  def client_id
    '227W5K'
  end

  def client_secret
    'd4d5c9c23c517c19ba238851c153f771'
  end

  def callback_url
    'http://localhost:3000/players/auth-callback' # must correspond with https://dev.fitbit.com/apps/edit/227W5K
  end

  def authorize_url
    'https://www.fitbit.com/oauth2/authorize'
  end

  def token_url
    'https://api.fitbit.com/oauth2/token'
  end

  def api_url
    'https://api.fitbit.com'
  end


  attr_reader :token

  def initialize(code: nil, token_hash: nil)
    self.code = code if code
    @token = ::OAuth2::AccessToken.from_hash(client, token_hash) if token_hash
  end

  protected

  # see https://dev.fitbit.com/docs/oauth2/#authorization-header
  def authorization_header
    "Basic " + Base64.encode64([client_id, client_secret].join(':')).chomp
  end

  def client
    @client ||= OAuth2::Client.new(client_id,
                                   client_secret,
                                   site: api_url,
                                   authorize_url: authorize_url,
                                   token_url: token_url
    )
  end

  # see https://dev.fitbit.com/docs/oauth2/#scope
  def scope
    'activity heartrate location nutrition profile settings sleep social weight'
  end

  public

  def has_token?
    @token
  end

  # @param open_in_browser for local development, open the redirect URL in a local browser
  # @param state the anti-forgery token, for finding the user during the callback
  # @return the URL to the fitbit.com oauth2 authorize page, which asks users to allow us permissions
  def authorization_url(open_in_browser: false, state: nil)
    require 'oauth2'

    authorize_url = client.auth_code.authorize_url(redirect_uri: callback_url,
                                                   scope: scope,
                                                   state: state,
                                                   expires_in: 604800
    )

    `open '#{authorize_url}'` if open_in_browser

    authorize_url

  end

  # makes a network call back to Fitbit to authenticate this app + this code
  # @param code the value of the code parameter sent from fitbit.com to our callback endpoint
  def code=(code)
    @token = client.auth_code.get_token(code,
                                        headers: headers,
                                        redirect_uri: callback_url
    )

  end

  def token_hash
    token.to_hash
  end

  def refresh!
    token.refresh! headers: headers
  end

  def get(path, params = {})
    # todo: test this error
    raise "No access token; you must auth" unless token

    token.get(path, {
      params: params,
      headers: headers,
      raise_errors: true
    })
  end

  def headers
    {'Authorization' => authorization_header}
  end

  def get_user_profile
    response = self.get('/1/user/-/profile.json')
    # todo: error check
    JSON.parse(response.body)
  end


end
