require 'rails_helper'

describe Player, type: :model do
  describe 'Activities' do
    let!(:player) { create_player(player_name: "Alice", password: "password", team: 'blue', coins: 0, gems: 0) }
    let!(:fake_fitbit) { instance_double(Fitbit) }
    let(:today) { Time.current.strftime('%F') }
    let(:yesterday) { (Time.current - 1.day).strftime('%F') }

    before do
      Timecop.freeze
      player.instance_variable_set(:@fitbit, fake_fitbit)
    end

    describe 'claim_steps!' do
      context 'with one day of activity' do
        before { player.activities.create!(date: Date.current, steps: 1000) }

        it 'converts steps into coins' do
          expect(player.coins).to eq(0)
          player.claim_steps!
          player.reload
          expect(player.coins).to eq(100)
        end

        it 'adds to existing coin amount' do
          player.update!(coins: 9)
          player.claim_steps!
          player.reload
          expect(player.coins).to eq(109)
        end

        it 'edits activity to reflect the claimed count' do
          player.claim_steps!
          expect(player.activities.first.steps_claimed).to eq(1000)
        end
      end

      context 'with several days of activity' do
        let!(:activity_yesterday) { player.activities.create!(date: Date.current - 1.day, steps: 100) }
        let!(:activity_today) { player.activities.create!(date: Date.current, steps: 50) }

        it 'converts steps into coins' do
          expect(player.coins).to eq(0)
          player.claim_steps!
          player.reload
          expect(player.coins).to eq(15)
        end

        it 'edits activity to reflect the claimed count' do
          player.claim_steps!
          expect(activity_yesterday.reload.steps_claimed).to eq(100)
          expect(activity_today.reload.steps_claimed).to eq(50)
        end

        it "keeps the remainder of steps (if we didn't have enough for one coin)" do
          activity_yesterday.update!(steps: 101)
          activity_today.update!(steps: 53)

          player.claim_steps!

          expect(player.coins).to eq(15)
          expect(activity_yesterday.reload.steps_claimed).to eq(101)
          expect(activity_today.reload.steps_claimed).to eq(49)
          expect(player.steps_available).to eq(4)

        end

        it "spreads claims over several days" do
          activity_yesterday.update!(steps: 7)
          activity_today.update!(steps: 4)

          player.claim_steps!

          expect(player.coins).to eq(1)

          expect(activity_yesterday.reload.steps_claimed).to eq(7)
          expect(activity_today.reload.steps_claimed).to eq(3)
          expect(player.steps_available).to eq(1)

        end
      end

      it 'maxes out at 10000 steps' do
        player.activities.create!(date: Date.current, steps: 12345)
        player.claim_steps!
        expect(player.coins).to eq(1000)
        expect(player.steps_available).to eq(0)
      end

    end

    describe 'steps_available' do
      it 'adds up steps (one record)' do
        player.activities.create!(date: Date.current, steps: 100)
        expect(player.steps_available).to eq(100)
      end

      context 'several records' do
        it 'adds up steps (several records)' do
          player.activities.create!(date: Date.current - 1.day, steps: 100)
          player.activities.create!(date: Date.current, steps: 50)

          expect(player.steps_available).to eq(150)
        end

        it 'adds up steps and subtracts redemptions' do
          player.activities.create!(date: Date.current - 1.day, steps: 100, steps_claimed: 100)
          player.activities.create!(date: Date.current, steps: 50, steps_claimed: 25)

          expect(player.steps_available).to eq(25)
        end
      end
    end

    describe 'pull_activity!' do

      def summary(steps: 12612, fairly_active: 20, very_active: 10)
        {
            "summary" => {
                "steps" => steps,
                "fairlyActiveMinutes" => fairly_active,
                "veryActiveMinutes" => very_active,
            }
        }
      end

      it 'pulls steps from the fitbit' do
        expect(fake_fitbit).to receive(:get_activities).with(today).and_return(summary)
        player.pull_activity!
        expect(player.steps_available).to eq(12612)
      end

      it 'logs the time' do
        expect(fake_fitbit).to receive(:get_activities).with(today).and_return(summary)
        player.pull_activity!
        expect(player.activities_synced_at).to eq(Time.current)
      end

      it "idempotently ignores steps it's already pulled" do
        expect(fake_fitbit).to receive(:get_activities).with(today).and_return(summary, summary)
        player.pull_activity!
        player.pull_activity!
        expect(player.steps_available).to eq(12612)
      end

      it "subtracts steps it's already claimed from new steps" do
        expect(fake_fitbit).to receive(:get_activities).with(today).and_return(summary(steps: 400), summary(steps: 600))
        player.pull_activity!
        expect(player.steps_available).to eq(400)
        player.claim_steps!
        player.pull_activity!
        expect(player.steps_available).to eq(200)
      end

      it 'pulls minutes from the fitbit' do
        expect(fake_fitbit).to receive(:get_activities).with(today).and_return(summary)
        player.pull_activity!
        expect(player.active_minutes).to eq(30)
      end

      describe 'pull_recent_activity!' do
        it "calls pull_activity for today" do
          allow(fake_fitbit).to receive(:get_activities).and_return(summary) # no-op for previous days
          expect(fake_fitbit).to receive(:get_activities).with(today).and_return(summary(steps: 100))
          player.pull_recent_activity!
        end

        it "calls pull_activity for each of the past 7 days" do
          (0...7).each do |days_ago|
            expect(fake_fitbit).to receive(:get_activities).with((Date.current - days_ago).strftime("%F")).and_return(summary(steps: 100))
          end
          player.pull_recent_activity!
          expect(player.steps_available).to eq(100 * 7)
        end

        it "stops calling pull_activity when it reaches a day it already knows about" do

          # we already know they walked 100 steps yesterday and 200 each previous day
          player.activity_for(Date.current - 1).update!({steps: 100, active_minutes: 10})
          player.activity_for(Date.current - 2).update!({steps: 200, active_minutes: 30})
          player.activity_for(Date.current - 3).update!({steps: 200, active_minutes: 30})
          player.activity_for(Date.current - 4).update!({steps: 200, active_minutes: 30})
          player.activity_for(Date.current - 5).update!({steps: 200, active_minutes: 30})
          player.activity_for(Date.current - 6).update!({steps: 200, active_minutes: 30})

          # but now we learn that they walked 50 today and 150 yesterday
          expect(fake_fitbit).to receive(:get_activities).with((Date.current).strftime("%F")).and_return(summary(steps: 50))
          expect(fake_fitbit).to receive(:get_activities).with((Date.current - 1).strftime("%F")).and_return(summary(steps: 150))

          # ...and 200 the day before, which matches what we know...
          expect(fake_fitbit).to receive(:get_activities).with((Date.current - 2).strftime("%F")).and_return(summary(steps: 200))

          # ...so the rest of the days should not get fetched
          expect(fake_fitbit).not_to receive(:get_activities).with((Date.current - 3).strftime("%F"))
          expect(fake_fitbit).not_to receive(:get_activities).with((Date.current - 4).strftime("%F"))
          expect(fake_fitbit).not_to receive(:get_activities).with((Date.current - 5).strftime("%F"))
          expect(fake_fitbit).not_to receive(:get_activities).with((Date.current - 6).strftime("%F"))

          player.pull_recent_activity!

          expect(player.activity_for(Date.current).steps).to eq(50)
          expect(player.activity_for(Date.current - 1).steps).to eq(150)
          expect(player.activity_for(Date.current - 2).steps).to eq(200)
          expect(player.activity_for(Date.current - 3).steps).to eq(200)
          expect(player.activity_for(Date.current - 4).steps).to eq(200)
          expect(player.activity_for(Date.current - 5).steps).to eq(200)
          expect(player.activity_for(Date.current - 6).steps).to eq(200)

          # todo: same deal for minutes
        end

        it "treats '0 step' days as unknown, since the user might not have synced their device yet, so fitbit would report 0"
      end
    end
  end

  describe 'active minute goals' do
    let(:player) { create_player(player_name: "Joe", password: "password", team: 'blue') }

    context "when today's goal has not been reached" do
      before { player.activities.create!(date: Date.current, active_minutes: 20) }

      it "is not met" do
        expect(player.active_goal_met?).to be_falsey
      end

      it "is not claimable" do
        expect { player.claim_active_minutes! }.to raise_error(Player::GoalNotMet)
        expect(player.gems).to eq(0)
        expect(player.activity_today.active_minutes_claimed).to be_falsey
      end
    end

    context "when today's goal has been reached" do
      before { player.activities.create!(date: Date.current,
                                         active_minutes: Player::GOAL_MINUTES + 20) }

      it "is met" do
        expect(player.active_goal_met?).to be_truthy
      end

      it "is claimable" do
        player.claim_active_minutes!
        expect(player.gems).to eq(1)
        expect(player.activity_today.active_minutes_claimed).to be_truthy
      end

      it "is only claimable once (idempotency)" do
        player.claim_active_minutes!
        player.claim_active_minutes!
        expect(player.gems).to eq(1)
      end
    end
  end
end
