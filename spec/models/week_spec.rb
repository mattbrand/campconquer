require 'rails_helper'

describe Week do

  describe 'weighted activity lottery' do

    # The week includes Monday to Friday, not Saturday or Sunday.
    # The players who have worn their fitbit more should have a
    # higher probability of their name being drawn. If they wore
    # their fitbit on the first day, their name should be entered
    # into the drawing once, if they wore their fitbit 5 days, they
    # should be entered into the drawing 5 times.

    def activity_on date
      Activity.new(date: date, steps: 1)
    end

    def player_active_on(*active_dates)
      double("Player", activities: active_dates.map{|date| activity_on(date)})
    end

    describe 'active players' do

      let(:some_sunday) { Date.parse('2017-01-01') }
      let(:week) { Week.new number: 1, start_at: some_sunday }
      let(:monday) { some_sunday + 1.day }
      let(:tuesday) { some_sunday + 2.days }

      it 'includes those with activity inside the week' do
        player = player_active_on(monday)
        expect(week.active_players([player])).to eq([player])
      end

      it 'excludes those with activity outside the week' do
        player = player_active_on(monday + 1.week)
        expect(week.active_players([player])).to eq([])
      end

      it 'excludes those with activity inside the weekend' do
        player = player_active_on(some_sunday)
        expect(week.active_players([player])).to eq([])
      end

      it 'de-dupes those with activity on several days' do
        player = player_active_on(monday, tuesday)
        expect(week.active_players([player])).to eq([player])
      end
    end

  end
end
