class StaticsController < WebController
  def index
  end


  def game
    require_role :can_see_game
  end
end
