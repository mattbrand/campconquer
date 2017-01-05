# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end


# todo: move to a fixture factory or something

def create_gamemaster(player_name: 'gertie gamemaster',
                      password: 'password')
  Player.create!(name: player_name,
                 password: password,
                 team: 'gamemaster',
                 embodied: false)
end

def create_admin(player_name: 'annie admin',
                 password: 'password')
  Player.create!(name: player_name,
                 password: password,
                 team: 'red',
                 embodied: false,
                 admin: true)
end

def create_alice_with_piece
  create_player(player_name: 'alice', body_type: 'female', team: 'blue')
end

def create_bob_with_piece
  create_player(player_name: 'bob', body_type: 'male', team: 'blue')
end

def create_player(player_name: 'peter',
                  password: 'password',
                  team: 'red',
                  body_type: 'female',
                  role: 'defense',
                  coins: 100,
                  gems: 0,
                  embodied: true)
  player = Player.create!(name: player_name,
                          password: password,
                          team: team,
                          coins: coins,
                          gems: gems,
                          embodied: embodied)
  piece_attributes = {
      body_type: body_type,
      role: role,
      path: [[0, 0]]
  }
  player.set_piece(piece_attributes)
  player
end

def expire_session(session)
  last_week = Time.current - 8.days
  session.update_columns(created_at: last_week, updated_at: last_week)
end

