require 'rails_helper'

RSpec.describe "team_outcomes/new", type: :view do
  before(:each) do
    assign(:team_outcome, TeamOutcome.new(
      :team => "blue",
      :deaths => 1,
      :takedowns => 1,
      :throws => 1,
      :captures => 1
    ))
  end

  it "renders new team_outcome form" do
    render

    assert_select "form[action=?][method=?]", team_outcomes_path, "post" do

      assert_select "input#team_outcome_team[name=?]", "team_outcome[team]"

      assert_select "input#team_outcome_deaths[name=?]", "team_outcome[deaths]"

      assert_select "input#team_outcome_takedowns[name=?]", "team_outcome[takedowns]"

      assert_select "input#team_outcome_throws[name=?]", "team_outcome[throws]"

      assert_select "input#team_outcome_captures[name=?]", "team_outcome[captures]"
    end
  end
end
