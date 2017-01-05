require 'rails_helper'

RSpec.describe "seasons/show", type: :view do
  before(:each) do
    @season = assign(:season, Season.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
