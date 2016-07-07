require 'rails_helper'

RSpec.describe "players/show", type: :view do
  before(:each) do
    @player = assign(:player, Player.create!(
      :name => "Name",
      :team => "blue",

    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
  end
end
