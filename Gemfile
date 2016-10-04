source 'https://rubygems.org'
ruby '2.2.4'

gem 'rails', '4.2.7'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'jquery-rails'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'activeadmin', github: 'activeadmin'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

gem 'awesome_print'
gem 'oauth2'
gem 'bulk_insert' # https://github.com/jamis/bulk_insert
gem 'faker' # https://github.com/stympy/faker
gem 'state_machine' # https://github.com/pluginaweek/state_machine
gem 'chronic' # https://github.com/mojombo/chronic

gem 'puma'
gem 'rack-timeout'

group :development, :test do
  gem 'sqlite3'
  gem 'byebug'   # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "rspec-rails"
  gem 'dotenv-rails' # https://github.com/bkeepers/dotenv
  gem 'ruby-graphviz', :require => 'graphviz'

end

group :development do
  gem 'web-console', '~> 2.0'   # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'spring' # https://github.com/rails/spring
  gem 'annotate'
end

group :test do
  gem 'webmock'
  gem 'files' # https://github.com/alexch/files
  gem 'timecop' # https://github.com/travisjeffery/timecop
end

group :production do
  gem 'rails_12factor'
  gem 'pg'
end
