require 'rails_helper'

RSpec.describe "team_outcomes/show", type: :view do
  before(:each) do
    @team_outcome = assign(:team_outcome, TeamOutcome.create!(
      :team => "blue",
      :takedowns => 2,
      :throws => 3,
      :pickups => 4
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Team/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
  end
end
