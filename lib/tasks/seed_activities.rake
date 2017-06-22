namespace :db do
  desc 'create up to 10 recent activities for each player'
  task :seed_activities => :environment do
    Player.all.each do |player|

      rand(10).times do |days_ago|
        date = Date.current - days_ago.day
        puts "#{date}: #{attrs.inspect}"
        activity = player.activity_for(date)
        activity.randomize!
        ap activity
      end
    end
  end
end
