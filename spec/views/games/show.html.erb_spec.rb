require 'rails_helper'

RSpec.describe "games/show", type: :view do
  before(:each) do
    @game = assign(:game, Game.create!(
      # :winner => "blue"
    ))
  end

  it "renders attributes in <p>" do
    render
    # expect(rendered).to match(/Winner/)
  end
end
