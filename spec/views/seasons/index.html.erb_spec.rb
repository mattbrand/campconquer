require 'rails_helper'

RSpec.describe "seasons/index", type: :view do
  before(:each) do
    assign(:seasons, [
      Season.create!(),
      Season.create!()
    ])
  end

  it "renders a list of seasons" do
    render
  end
end
