require 'rails_helper'

RSpec.describe "pieces/index", type: :view do
  before(:each) do
    assign(:pieces, [
      Piece.create!(
        :team => "Team",
        :job => "Job",
        :role => "Role",
        :path => "MyText",
        :speed => 1.5,
        :hit_points => 1,
        :range => 1.6
      ),
      Piece.create!(
        :team => "Team",
        :job => "Job",
        :role => "Role",
        :path => "MyText",
        :speed => 1.5,
        :hit_points => 1,
        :range => 1.6
      )
    ])
  end

  it "renders a list of pieces" do
    render
    assert_select "tr>td", :text => "Team".to_s, :count => 2
    assert_select "tr>td", :text => "Job".to_s, :count => 2
    assert_select "tr>td", :text => "Role".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 1.6.to_s, :count => 2
  end
end
