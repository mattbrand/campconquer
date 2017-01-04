require 'rails_helper'


describe Path do


  describe 'where' do
    it 'can select by team' do
      paths = Path.where(team: 'red')
      expect(paths).not_to be_empty
      paths.each do |p|
        expect(p.team).to eq('red')
      end
    end

    it 'can select by role' do
      paths = Path.where(role: 'offense')
      expect(paths).not_to be_empty
      paths.each do |p|
        expect(p.role).to eq('offense')
      end
    end

    it 'can select by team and role' do
      paths = Path.where(team: 'blue', role: 'defense')
      expect(paths).not_to be_empty
      paths.each do |p|
        expect(p.team).to eq('blue')
        expect(p.role).to eq('defense')
      end
    end
  end

  let(:path) { Path.new(team: 'red',
                        button_position: Point.new(x: 1, y: 2),
                        button_angle: -45,
                        role: 'defense',
                        points: [Point.new(x: 1, y: 2)]) }

  describe 'count' do
    it 'can be incremented' do
      expect(path.count).to eq(0)
      path.increment_count
      expect(path.count).to eq(1)
    end
  end

  describe 'as_json' do
    it 'works' do
      path.increment_count
      expect(path.as_json).to eq({
                                   'team' => 'red',
                                   "button_position"=>{"x"=>1, "y"=>2},
                                   "button_angle"=>-45,
                                   'role' => 'defense',
                                   'active' => true,
                                   'count' => 1,
                                   'points' => [{'x' => 1, 'y' => 2}],
                                 })
    end
  end

  describe 'equality' do

    def expect_equal(path_1, path_2)
      expect(path_1).to eq(path_2)
      expect(path_2).to eq(path_1)
    end

    def expect_not_equal(path_1, path_2)
      expect(path_1).not_to eq(path_2)
      expect(path_2).not_to eq(path_1)
    end

    it 'works' do
      red_offense_path_1 = Path.new(team: 'red', role: 'offense', points: [Point.new(x: 1, y: 2)])
      red_offense_path_2 = Path.new(team: 'red', role: 'offense', points: [Point.new(x: 1, y: 2)])

      expect_equal(red_offense_path_1, red_offense_path_1)
      expect_equal(red_offense_path_1, red_offense_path_2)

      red_offense_path_3 = Path.new(team: 'red', role: 'offense', points: [Point.new(x: 1, y: 2),
                                                                           Point.new(x: 2, y: 1)])

      expect_not_equal(red_offense_path_1, red_offense_path_3)

      red_defense_path_1 = Path.new(team: 'red', role: 'defense', points: [Point.new(x: 1, y: 2)])

      expect_not_equal(red_offense_path_1, red_defense_path_1)

      red_defense_path_2 = Path.new(team: 'red', role: 'defense', points: [Point.new(x: 1, y: 3)])

      expect_not_equal(red_offense_path_1, red_defense_path_2)
      expect_not_equal(red_defense_path_1, red_defense_path_2)

      blue_defense_path = Path.new(team: 'blue', role: 'defense', points: [Point.new(x: 1, y: 2)])

      blue_offense_path = Path.new(team: 'blue', role: 'offense', points: [Point.new(x: 1, y: 2)])
      expect_not_equal(red_offense_path_1, blue_offense_path)
      expect_not_equal(red_offense_path_1, blue_defense_path)

    end
  end
end
