require 'rails_helper'

RSpec.describe "games/index", type: :view do
  before(:each) do
    assign(:games, [
      Game.create!(
        :winner => "blue"
      ),
      Game.create!(
        :winner => "red"
      )
    ])
  end

  it "renders a list of games" do
    render
    assert_select "tr>td", :text => "Blue Team".to_s, :count => 1
    assert_select "tr>td", :text => "Red Team".to_s, :count => 1
  end
end
