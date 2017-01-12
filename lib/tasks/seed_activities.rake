namespace :db do
  task :seed_activities => :environment do
    Player.all.each do |player|

      rand(10).times do |days_ago|
        date  = Date.current - days_ago.day
        attrs = {
            steps: rand(12000),
            active_minutes: rand(100),
        }
        puts "#{date}: #{attrs.inspect}"
        player.activity_for(date).update!(attrs)
      end
    end
  end
end
