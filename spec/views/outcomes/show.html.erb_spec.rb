require 'rails_helper'

RSpec.describe "outcomes/show", type: :view do
  before(:each) do
    @outcome = assign(:outcome, Outcome.create!(
      :winner => "Winner",
      :team_stats_id => 1,
      :match_length => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Winner/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
  end
end
