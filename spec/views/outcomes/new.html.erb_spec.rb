require 'rails_helper'

RSpec.describe "outcomes/new", type: :view do
  before(:each) do
    assign(:outcome, Outcome.new(
      :winner => "MyString",
      :team_stats_id => 1,
      :match_length => 1
    ))
  end

  it "renders new outcome form" do
    render

    assert_select "form[action=?][method=?]", outcomes_path, "post" do

      assert_select "input#outcome_winner[name=?]", "outcome[winner]"

      assert_select "input#outcome_team_stats_id[name=?]", "outcome[team_stats_id]"

      assert_select "input#outcome_match_length[name=?]", "outcome[match_length]"
    end
  end
end
