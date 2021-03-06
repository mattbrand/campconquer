class SeasonsController < WebController
  before_action :find_season, except: [:new, :index, :create]

  before_action :find_player, only: [:update_player]

  before_action -> {
    require_role('gamemaster', 'admin')
  }

  # GET /seasons
  def index
    @seasons = Season.all
  end

  # GET /seasons/1
  def show
  end

  # GET /seasons/new
  def new
    @season = Season.new
  end

  # GET /seasons/1/edit
  def edit
  end

  # POST /seasons
  def create
    @season = Season.new(season_params)

    if @season.save
      redirect_to @season, notice: 'Season was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /seasons/1
  def update
    if @season.update(season_params)
      redirect_to @season, notice: 'Season was successfully updated.'
    else
      render :edit
    end
  end

  # sub-resources

  # GET /seasons/1/weeks
  def weeks
  end

  # GET /seasons/1/players
  def players
    @dump = SeasonPlayersDump.new(@season)
    respond_to do |format|
      format.html
      format.csv do
        send_data @dump.csv, filename: "#{@season.name}-players.csv"
      end
    end
  end

  # GET /seasons/1/dump
  def activities
    @dump = SeasonActivitiesDump.new(@season)
    respond_to do |format|
      format.html
      format.csv do
        send_data @dump.csv, filename: "#{@season.name}-activities.csv"
      end
    end
  end

  # todo: test
  # POST /seasons/1/players/1?team_name=red
  def update_player
    @season.switch_team(@player, params[:team_name])
    @season.reload
    redirect_to players_season_path(@season),
                notice: "Switched #{@player.name} to #{params[:team_name]} team for Season #{@season.name}"
  end


  def switch_teams

  end

  private
  def season_params
    params.require(:season).permit(:name)
  end

end
