require 'rbconfig'
default_worker_count = RbConfig::CONFIG["host_os"] == 'mingw32' ? 0 : 2
workers Integer(ENV['WEB_CONCURRENCY'] || default_worker_count)

threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end

before_fork do
  require 'puma_worker_killer'
  PumaWorkerKiller.enable_rolling_restart(0.5 * 3600) # restart every half hour; default is every 6 hours
end
