require 'rails_helper'

RSpec.describe "team_outcomes/index", type: :view do
  before(:each) do
    assign(:team_outcomes, [
      TeamOutcome.create!(
        :team => "blue",
        :takedowns => 2,
        :throws => 3,
        :pickups => 4
      ),
      TeamOutcome.create!(
        :team => "red",
        :takedowns => 2,
        :throws => 3,
        :pickups => 4
      )
    ])
  end

  it "renders a list of team_outcomes" do
    render
    assert_select "tr>td", :text => "Blue Team".to_s, :count => 1
    assert_select "tr>td", :text => "Red Team".to_s, :count => 1
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
  end
end
