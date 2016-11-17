desc "pull latest fitbit activity for all authed players"
task :pull_activity => :environment do
  Player.where.not(fitbit_token_hash: nil).each do |player|
    start = Time.current
    info = player.pull_recent_activity!
    finish = Time.current
    info[:duration] = (finish - start).to_f
    puts "Pulled Activity: #{info.inspect}"
  end
end
