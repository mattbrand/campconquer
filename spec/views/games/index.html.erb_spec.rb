require 'rails_helper'

RSpec.describe "games/index", type: :view do
  before(:each) do
    assign(:games, [
      Game.create!(
        :winner => "Winner"
      ),
      Game.create!(
        :winner => "Winner"
      )
    ])
  end

  it "renders a list of games" do
    render
    assert_select "tr>td", :text => "Winner".to_s, :count => 2
  end
end
