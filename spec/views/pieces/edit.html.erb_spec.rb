require 'rails_helper'

RSpec.describe "pieces/edit", type: :view do
  before(:each) do
    @piece = assign(:piece, Piece.create!(
      :team => "blue",
      :job => "MyString",
      :role => "MyString",
      :path => "MyText",
      :speed => 1.5,
      :hit_points => 1,
      :range => 1.5
    ))
  end

  it "renders the edit piece form" do
    render

    assert_select "form[action=?][method=?]", piece_path(@piece), "post" do

      assert_select "input#piece_team[name=?]", "piece[team]"

      assert_select "input#piece_job[name=?]", "piece[job]"

      assert_select "input#piece_role[name=?]", "piece[role]"

      assert_select "textarea#piece_path[name=?]", "piece[path]"

      assert_select "input#piece_speed[name=?]", "piece[speed]"

      assert_select "input#piece_hit_points[name=?]", "piece[hit_points]"

      assert_select "input#piece_range[name=?]", "piece[range]"
    end
  end
end
