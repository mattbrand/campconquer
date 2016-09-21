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
end
