require 'rails_helper'

describe Game::Schedule do

  describe 'scheduled start time' do

    # see http://stackoverflow.com/questions/4044574/how-calculate-the-day-of-the-week-of-a-date-in-ruby


    def check_time(current_time, expected_next_time)
      Timecop.freeze(current_time) do
        expect(Game::Schedule.new(current_time).next_game_time).to eq(expected_next_time)
      end
    end

    def time(date, hour: 0, minute: 0, second: 0)
      Time.zone.local(date.year, date.month, date.day, hour, minute, second)
    end

    one_winter_monday = Date.new(2008, 1, 14)
    one_winter_sunday = Date.new(2008, 8, 11)

    # repeat these tests once in Summer and once in Winter to account for Daylight Saving Time
    [one_winter_monday, one_winter_sunday].each do |monday|

      # current rules:
      # one game a day at 1:15
      # skip weekends
      game_hour = 13
      game_minute = 15

      # NOTE: if we go back to >1 game per day the test cases and rules will get more complicated;
      # check the version history for game_spec.rb

      describe "for the week of #{monday}" do

        tuesday = monday + 1.days
        wednesday = monday + 2.days
        thursday = monday + 3.days
        friday = monday + 4.days
        saturday = monday + 5.days
        sunday = monday + 6.days
        next_monday = monday + 1.week

        describe "early on weekdays" do
          [monday, tuesday, wednesday, thursday, friday].each do |day|
            dayname = day.strftime("%A")
            it "at midnight on #{dayname}, forwards to game time that day" do
              check_time(time(day, hour: 0, minute: 0),
                         time(day, hour: game_hour, minute: game_minute))
            end

            it "a bit before game time on #{dayname}, forwards to game time that day" do
              check_time(time(day, hour: game_hour - 1, minute: 0),
                         time(day, hour: game_hour, minute: game_minute))
            end

            it "a tiny bit before game time on #{dayname}, forwards to game time that day" do
              check_time(time(day, hour: game_hour, minute: game_minute - 1),
                         time(day, hour: game_hour, minute: game_minute))
            end
          end
        end

        describe "late on most weekdays (except Friday)" do
          [monday, tuesday, wednesday, thursday].each do |day|
            dayname = day.strftime("%A")

            it "after game time on #{dayname}, forwards to game time the next day" do
              check_time(time(day, hour: game_hour + 1, minute: 0),
                         time(day + 1.day, hour: game_hour, minute: game_minute))
            end
          end
        end

        describe "late on Friday" do
          it "after game time on Friday, forwards to game time the next Monday" do
            check_time(time(friday, hour: game_hour + 1, minute: 0),
                       time(next_monday, hour: game_hour, minute: game_minute))
          end
        end

        describe "any time on weekends" do
          [saturday, sunday].each do |day|
            dayname = day.strftime("%A")
            it "at midnight on #{dayname}, forwards to game time next Monday" do
              check_time(time(day, hour: 0, minute: 0),
                         time(next_monday, hour: game_hour, minute: game_minute))
            end

            it "a bit before game time on #{dayname}, forwards to game time next Monday" do
              check_time(time(day, hour: game_hour - 1, minute: 0),
                         time(next_monday, hour: game_hour, minute: game_minute))
            end

            it "a tiny bit before game time on #{dayname}, forwards to game time next Monday" do
              check_time(time(day, hour: game_hour, minute: game_minute - 1),
                         time(next_monday, hour: game_hour, minute: game_minute))
            end

            it "after game time on #{dayname}, forwards to game time the next Monday" do
              check_time(time(day, hour: game_hour + 1, minute: 0),
                         time(next_monday, hour: game_hour, minute: game_minute))
            end
          end
        end
      end
    end
  end
end


