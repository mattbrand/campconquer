# todo:
# error handling
# unit tests
# refresh

class Fitbit

  attr_reader :token

  def initialize(code: nil, token_hash: nil)
    # todo: get these from ENV
    @client_id = '227W5K'
    @client_secret = 'd4d5c9c23c517c19ba238851c153f771'
    @callback_url = 'http://localhost:3000/players/auth-callback' # must correspond with https://dev.fitbit.com/apps/edit/227W5K

    @authorization_url = 'https://www.fitbit.com/oauth2/authorize'
    @token_uri = 'https://api.fitbit.com/oauth2/token'
    @api_url = 'https://api.fitbit.com'


    self.code = code if code
    @token = ::OAuth2::AccessToken.from_hash(client, token_hash) if token_hash

  end

  protected

  attr_reader :client_id, :client_secret, :callback_url,
              :authorization_url, :token_uri, :api_url

  # see https://dev.fitbit.com/docs/oauth2/#authorization-header
  def authorization_header
    "Basic " + Base64.encode64([client_id, client_secret].join(':'))
  end

  def client
    @client ||= OAuth2::Client.new(client_id, client_secret,
                                   site: api_url,
                                   authorize_url: authorization_url,
                                   token_url: token_uri
    )
  end

  # see https://dev.fitbit.com/docs/oauth2/#scope
  def scope
    'activity heartrate location nutrition profile settings sleep social weight'
  end

  public

  # @return the URL to the fitbit.com oauth2 authorize page, which asks users to allow us permissions
  def begin_authorization(open = false)
    require 'oauth2'


    authorize_url = client.auth_code.authorize_url(redirect_uri: callback_url,
                                                   scope: scope,
                                                   expires_in: 604800
    )

    `open '#{authorize_url}'` if open

    authorize_url

  end

  # @param code the value of the code parameter sent from fitbit.com to our callback endpoint
  def code=(code)
    @token = client.auth_code.get_token(code,
                                        redirect_uri: @callback_url,
                                        headers: headers)

    ap token
  end

  def refresh!
    token.refresh! headers: headers
  end

  def get(path, params = {})
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
    response = self.get('/1/user/-/profile.json', headers: headers)
    # todo: error check
    JSON.parse(response.body)
  end

  def token_hash
    token.to_hash
  end

end
