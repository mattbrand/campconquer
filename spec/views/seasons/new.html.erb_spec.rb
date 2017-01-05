require 'rails_helper'

RSpec.describe "seasons/new", type: :view do
  before(:each) do
    assign(:season, Season.new())
  end

  it "renders new season form" do
    render

    assert_select "form[action=?][method=?]", seasons_path, "post" do
    end
  end
end
