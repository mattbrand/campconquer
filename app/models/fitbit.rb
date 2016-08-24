# todo:
# error handling
# unit tests
# refresh

class Fitbit

  # 86400 for 1 day
  # 604800 for 1 week
  # 2592000 for 30 days
  # 31536000 for 1 year
  EXPIRES_IN_SEC = 86400

  class Unauthorized < RuntimeError
    def initialize
      super("No access token; you must auth")
    end
  end

  def from_env(key)
    ENV[key] || raise("You must set the environment variable #{key}")
  end

  def client_id
    from_env('FITBIT_CLIENT_ID')
  end

  def client_secret
    from_env('FITBIT_CLIENT_SECRET')
  end

  def callback_url
    from_env('FITBIT_CALLBACK_URL')
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

  def initialize(code: nil, token_hash: nil, token_saver: nil)
    self.code = code if code

    @token = ::OAuth2::AccessToken.from_hash(client, token_hash) if token_hash

    # set the token saver *after* setting the token,
    # so initializing it from a hash # does not trigger an update
    @token_saver = token_saver
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
                                                   prompt: 'login',
                                                   expires_in: EXPIRES_IN_SEC
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
    @token_saver.update_token(self) if @token_saver # todo: test
  end

  def token_hash
    token.to_hash
  end

  def refresh!
    @token = token.refresh! headers: headers
    @token_saver.update_token(self) if @token_saver # todo: test
  end

  def refreshing
    begin
      yield
    rescue OAuth2::Error => e
      hash = e.try(:response).try(:parsed) # defensive coding
      unless hash.nil?
        puts hash
        error_type = hash["errors"][0]["errorType"]
        if ['expired_token', 'invalid_token'].include? error_type
          print "Token invalid; refreshing..."
          refresh!
          return yield
        end
      end
      raise e
    end
  end


  def get(path, params = {})
    # todo: test this error
    raise Unauthorized unless token

    refreshing do
      puts "FITBIT fetching #{path} #{params}"
      response = token.get(path, {
        params: params,
        headers: headers,
        raise_errors: true
      })
      # todo: error check
      # if response.ok?
      JSON.parse(response.body)
    end
  end

  def headers
    {'Authorization' => authorization_header}
  end

  def get_user_profile
    self.get('/1/user/-/profile.json')
  end

  def yesterday
    (Time.current - 1.day).strftime('%F')
  end

  def get_activities(date = yesterday)
    date = date.strftime('%F') unless date.is_a? String
    get("/1/user/-/activities/date/#{date}.json")
  end

  # https://dev.fitbit.com/docs/devices/#get-devices
  def get_devices
    self.get('/1/user/-/devices.json')
  end
end
