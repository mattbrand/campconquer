# == Schema Information
#
# Table name: seasons
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  name       :string
#  current    :boolean          default("f"), not null
#

class Season < ActiveRecord::Base
  has_many :games, -> { includes :player, :items }

  validates_uniqueness_of :current,
                          unless: Proc.new { |game| !game.current? },
                          message: 'should be true for only one season'

  def self.current
    current_season = where(current: true).first
    if current_season.nil?
      current_season = Season.create! current: true
    end
    current_season
  end

  def self.previous
    where(current: false).order(updated_at: :desc).first
  end

  include ActiveModel::Serialization

  def as_json(options=nil)
    if options.nil?
      options = {
        include: [:games],
      }
    end
    super(options)
  end

end
