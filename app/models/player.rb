# == Schema Information
#
# Table name: players
#
#  id         :integer          not null, primary key
#  name       :string
#  team       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Player < ActiveRecord::Base
  has_one :piece

  validates :team, inclusion: { in: Team::NAMES.values, message: Team::NAMES.validation_message}

  def set_piece(params = {})
    params = params.pick(:job, :role, :path)
    if self.piece
      self.piece.update!(params) # todo: whitelist
    else
      self.piece = Piece.new({team: self.team} + params)
    end
    self.piece
  end

  include ActiveModel::Serialization
  def as_json(options=nil)
    if options.nil?
      options = {
        include: [{:piece => Piece.serialization_options}],
      }
    end
    super(options)
  end

end
