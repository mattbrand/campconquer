require 'rails_helper'

RSpec.describe "pieces/show", type: :view do
  before(:each) do
    @piece = assign(:piece, Piece.create!(
      :team => "Team",
      :job => "Job",
      :role => "Role",
      :path => "MyText",
      :speed => 1.5,
      :hit_points => 1,
      :range => 1.5
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Team/)
    expect(rendered).to match(/Job/)
    expect(rendered).to match(/Role/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/1.5/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/1.5/)
  end
end
