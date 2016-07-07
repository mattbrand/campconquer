require 'rails_helper'

RSpec.describe "players/index", type: :view do
  before(:each) do
    assign(:players, [
      Player.create!(
        :name => "Name",
        :team => "blue",
      ),
      Player.create!(
        :name => "Name",
        :team => "blue",
      )
    ])
  end

  it "renders a list of players" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
