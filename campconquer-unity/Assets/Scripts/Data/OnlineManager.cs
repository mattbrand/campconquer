using UnityEngine;
using UnityEngine.SceneManagement;
using System;
using System.Collections;
using System.Collections.Generic;
using BestHTTP;
using Newtonsoft.Json;
using gametheory.Utilities;
using CampConquer;

#region Enums
public enum OnlineGameStatus { NONE = 0, PREPARING, IN_PROGRESS, COMPLETED };
#endregion

public class OnlineManager : MonoBehaviour
{
    #region Constants
    const string LOCALHOST = "http://localhost:3000/api";
    const string STAGING = "https://campconquer-staging.herokuapp.com/api";
    const string PRODUCTION = "";
    const float METERS_PER_MAP_UNIT = 10.0f;
    #endregion

    #region Public Vars
    public static bool Local;
    public static bool Staging;
    public static bool Production;
    public static string _playerID;
    public static string Token;
    public static OnlineManager Instance;
    #endregion

    #region Private Vars
    GameData _gameData;
    GameData _previousGameData;
    SeasonData _seasonSyncData;
    PlayerResponseData _playerResponseData;
    GearResponseData _gearResponseData;
    //PathResponseData _pathResponseData;
    ResponseData _responseData;
    OnlineGameStatus _gameStatus;
    OnlineGameStatus _previousGameStatus;
    string _playerName;
    string _url;
    string _error;
    int _coinsClaimed;
    int _stepsClaimed;
    bool _requestFailure;
    #endregion

    #region Unity Methods
    void Start()
    {
        enabled = false;

        if (Instance == null)
        {
            Instance = this;

            if (SceneManager.GetActiveScene().name == "Moderator")
            {
                //Debug.Log("on start of OnlineManager, local = " + Local + " staging = " + Staging);
                SetServer(Local, Staging, false);
            }
        }
        else
        {
            Destroy(gameObject);
        }
    }

    void OnDestroy()
    {
        Instance = null;
    }
    #endregion

    #region Methods
    public void SetServer(bool local, bool staging, bool production)
    {
        if (Application.isWebPlayer)
        {
            _url = Application.absoluteURL + "/api";
        }
        else
        {
            _url = LOCALHOST;

            /*
            if (local)
            {
                _url = LOCALHOST;
            }
            else if (staging)
            {
                _url = STAGING;
            }
            */
        }
    }

    private List<HTTPTuple> NewParams() {
        List<HTTPTuple> tuples = new List<HTTPTuple>();
        tuples.Add(new HTTPTuple("token", Token));
        return tuples;
    }

    public IEnumerator StartLogin(string username, string password)
    {
        string url = _url + "/sessions";
        List<HTTPTuple> tuples = new List<HTTPTuple>();
        tuples.Add(new HTTPTuple("name", username));
        tuples.Add(new HTTPTuple("password", password));
        //Debug.Log(username + ", " + password);
        yield return StartCoroutine(BestHTTPHelper.Instance.CallToServerForJson(url, HTTPMethods.Post, tuples, SetToken, DisplayError, DisplayError, RequestFailure));
    }

    void SetToken(string json)
    {
        //Debug.Log("setting token");
        TokenResponseData tokenResponseData = JsonConvert.DeserializeObject<TokenResponseData>(json);
        if (tokenResponseData.status == "ok")
        {
            Token = tokenResponseData.token;
            _playerID = tokenResponseData.player_id;
        }
        else
        {
            HTTPAlert.Present("Error", "Login failed", null, null, true);
        }
    }

    public IEnumerator StartGetGame()
    {
        //Debug.Log("StartGetGame");
        string url = _url + "/games/current";
        yield return StartCoroutine(BestHTTPHelper.Instance.CallToServerForJson(url, HTTPMethods.Get, NewParams(), SetGameInfo, DisplayError, DisplayError, RequestFailure));
    }

    void SetGameInfo(string json)
    {
        //Debug.Log("SetGameInfo");
        GameResponseData responseData = JsonConvert.DeserializeObject<GameResponseData>(json);
        //Debug.Log("1");
        _gameData = responseData.game;
        //Debug.Log(json);
        _gameStatus = (OnlineGameStatus)Enum.Parse(typeof(OnlineGameStatus), _gameData.state.ToUpper(), true);
        //Debug.Log("2");
    }

    public IEnumerator StartGetPreviousGame()
    {
        string url = _url + "/games/previous";
        yield return StartCoroutine(BestHTTPHelper.Instance.CallToServerForJson(url, HTTPMethods.Get, NewParams(), SetPreviousGameInfo, null, null, RequestFailure));
    }

    void SetPreviousGameInfo(string json)
    {
        GameResponseData responseData = JsonConvert.DeserializeObject<GameResponseData>(json);
        _previousGameData = responseData.game;
        _previousGameStatus = (OnlineGameStatus)Enum.Parse(typeof(OnlineGameStatus), _previousGameData.state.ToUpper(), true);
    }

    public IEnumerator StartReplayGame()
    {
        string url = _url + "/games/previous";
        List<HTTPTuple> tuples = NewParams();
        tuples.Add(new HTTPTuple("include_moves", "true"));
        yield return StartCoroutine(BestHTTPHelper.Instance.CallToServerForJson(url, HTTPMethods.Get, tuples, SetReplayGameInfo, DisplayError, DisplayError, RequestFailure));
    }

    void SetReplayGameInfo(string json)
    {
        GameResponseData responseData = JsonConvert.DeserializeObject<GameResponseData>(json);
        _gameData = responseData.game;

        /*
        //Debug.Log(_gameData.team_outcomes[0].team + " --- " + _gameData.team_outcomes[0].attack_mvps.Count);
        if (_gameData.team_outcomes[0].attack_mvps.Count > 0)
            Debug.Log(_gameData.team_outcomes[0].attack_mvps[0]);
        //Debug.Log(_gameData.team_outcomes[0].defend_mvps.Count);
        if (_gameData.team_outcomes[0].defend_mvps.Count > 0)
            Debug.Log(_gameData.team_outcomes[0].defend_mvps[0]);
        //Debug.Log(_gameData.team_outcomes[1].team + " --- " + _gameData.team_outcomes[1].attack_mvps.Count);
        if (_gameData.team_outcomes[1].attack_mvps.Count > 0)
            Debug.Log(_gameData.team_outcomes[1].attack_mvps[0]);
        //Debug.Log(_gameData.team_outcomes[1].defend_mvps.Count);
        if (_gameData.team_outcomes[1].defend_mvps.Count > 0)
            Debug.Log(_gameData.team_outcomes[1].defend_mvps[0]);
        */
        /*
        for (int i = 0; i < _gameData.pieces.Count; i++)
        {
            Debug.Log(_gameData.pieces[i].player_id);
        }
        */

        DataRecorder.Instance.SetDataFromJson(_gameData.moves);
    }

    public IEnumerator StartLockGame()
    {
        string url = _url + "/games/" + _gameData.id + "/lock";
        yield return StartCoroutine(BestHTTPHelper.Instance.CallToServerForJson(url, HTTPMethods.Post, NewParams(), null, DisplayError, DisplayError, RequestFailure));
    }

    public IEnumerator StartGetPlayer(string id)
    {
        //Debug.Log("StartGetPlayerCoroutine " + id + " url = " + _url);
        _requestFailure = false;
        string url = _url + "/players/" + id;
        yield return StartCoroutine(BestHTTPHelper.Instance.CallToServerForJson(url, HTTPMethods.Get, NewParams(), SetPlayerInfo, StoreError, StoreError, RequestFailure));
    }

    void SetPlayerInfo(string json)
    {
        //Debug.Log("SetPlayerInfoJson - json = " + json);

        _playerResponseData = JsonConvert.DeserializeObject<PlayerResponseData>(json);

        //Debug.Log("converted json data");

        PlayerData playerData = _playerResponseData.player;

        //Debug.Log("1");

        // set player data
        _playerID = playerData.id.ToString();
        _playerName = playerData.name;
        if (playerData.team == "red")
            Avatar.Instance.Color = TeamColor.RED;
        else
            Avatar.Instance.Color = TeamColor.BLUE;
        Avatar.Instance.Name = playerData.name;
        Avatar.Instance.Coins = playerData.coins;
        Avatar.Instance.Gems = playerData.gems;
        Avatar.Instance.Embodied = playerData.embodied;
        Avatar.Instance.Steps = playerData.steps_available;
        Avatar.Instance.GemsAvailable = playerData.gems_available;
        //Debug.Log(playerData.gems_available);
        Avatar.Instance.ActiveMins = playerData.active_minutes;
        //Debug.Log(Avatar.Instance.ActiveMins);
        //Avatar.Instance.ActiveMet = playerData.active_goal_met;
        //Avatar.Instance.ActiveClaimed = playerData.active_minutes_claimed;
        //Debug.Log(Avatar.Instance.ActiveClaimed);

        //Debug.Log("2");

        // set avatar info from piece data
        PieceData piece = playerData.piece;
        if (piece.body_type != null)
        {
            //Debug.Log("read playerinfo - piece body type = " + piece.body_type);
            Avatar.Instance.BodyType = (AvatarBodyType)Enum.Parse(typeof(AvatarBodyType), piece.body_type.ToUpper(), true);
        }
        if (piece.face != null)
            Avatar.Instance.FaceAsset = piece.face;
        if (piece.hair != null)
            Avatar.Instance.HairAsset = piece.hair;
        if (piece.skin_color != null)
            Avatar.Instance.SkinColor = piece.skin_color;
        if (piece.hair_color != null)
            Avatar.Instance.HairColor = piece.hair_color;

        //Debug.Log("3");

        Avatar.Instance.Health = piece.health;
        Avatar.Instance.Speed = (int)piece.speed;
        Avatar.Instance.Range = (int)piece.range;

        //Debug.Log("3a");

        List<Point> points = piece.path;
        //Debug.Log("3b");
        Path path = new Path(points);
        //Debug.Log("3c");
        Avatar.Instance.Path = path;
        //Debug.Log("3d");
        if (piece.role == "offense")
            Avatar.Instance.Role = PieceRole.OFFENSE;
        else
        {
            Avatar.Instance.Role = PieceRole.DEFENSE;
            if (Avatar.Instance.Path != null && Avatar.Instance.Path.Points.Count > 0)
                Avatar.Instance.Position = new Vector2(Avatar.Instance.Path.Points[0].x, Avatar.Instance.Path.Points[0].y);
        }
        //Debug.Log("3e");

        // set gear
        int i = 0;
        //Debug.Log("gear equipped");
        if (playerData.gear_equipped != null)
        {
            for (i = 0; i < playerData.gear_equipped.Count; i++)
            {
                Avatar.Instance.AddEquippedItem(playerData.gear_equipped[i]);
            }
        }

        if (playerData.gear_owned != null)
        {
            //Debug.Log("gear owned");
            for (i = 0; i < playerData.gear_owned.Count; i++)
            {
                Avatar.Instance.AddPurchasedItem(playerData.gear_owned[i]);
            }
        }

        if (playerData.ammo != null)
        {
            //Debug.Log("ammo");
            for (i = 0; i < playerData.ammo.Count; i++)
            {
                AmmoType ammoType = (AmmoType)Enum.Parse(typeof(AmmoType), playerData.ammo[i].ToUpper(), true);
                Avatar.Instance.AddAmmo(ammoType);
            }
        }
    }

    public IEnumerator StartPutPlayer()
    {
        string url = _url + "/players/" + _playerID;

        List<HTTPTuple> tuples = NewParams();
        tuples.Add(new HTTPTuple("player[embodied]", "true"));
        yield return StartCoroutine(BestHTTPHelper.Instance.CallToServerForJson(url, HTTPMethods.Put, tuples, SetPutPlayerInfo, DisplayError, DisplayError, RequestFailure));
    }

    void SetPutPlayerInfo(string json)
    {
        PlayerResponseData responseData = JsonConvert.DeserializeObject<PlayerResponseData>(json);
        PlayerData playerData = responseData.player;

        // set player data
        Avatar.Instance.Embodied = playerData.embodied;
    }

    public IEnumerator StartPieceInfoPostCoroutine(bool firstTime = false)
    {
        string url = _url + "/players/" + _playerID + "/piece";
        List<HTTPTuple> tuples = NewParams();
        tuples.Add(new HTTPTuple("piece[role]", Avatar.Instance.Role.ToString().ToLower()));
        //Dictionary<string, string> parameters = new Dictionary<string, string>();
        //parameters.Add("piece[role]", Avatar.Instance.Role.ToString().ToLower());
        /*
        List<HTTPTuple> tuples = new List<HTTPTuple>();
        for (int i = 0; i < Avatar.Instance.Path.Points.Count; i++)
        {
            tuples.Add(new HTTPTuple("piece[path][][x]", Avatar.Instance.Path.Points[i].X.ToString()));
            tuples.Add(new HTTPTuple("piece[path][][y]", Avatar.Instance.Path.Points[i].Y.ToString()));
            //parameters.Add("piece[path][][x]", Avatar.Instance.Path.Points[i].X.ToString());
            //parameters.Add("piece[path][][y]", Avatar.Instance.Path.Points[i].X.ToString());
        }
        */
        if (Avatar.Instance != null && Avatar.Instance.Path != null)
        {
            string path = JsonConvert.SerializeObject(Avatar.Instance.Path);
            tuples.Add(new HTTPTuple("piece[path]", path));
            //parameters.Add("piece[path]", path);
            //Debug.Log("posted path " + path);
        }
        //Debug.Log("piece info post - " + Avatar.Instance.GetBodyTypeStr() + " --- " + Avatar.Instance.FaceAsset + " --- " + Avatar.Instance.HairAsset + " --- " + Avatar.Instance.SkinColor + " --- " + Avatar.Instance.HairColor);
        if (firstTime)
        {
            tuples.Add(new HTTPTuple("piece[health]", Avatar.Instance.Health.ToString()));
            tuples.Add(new HTTPTuple("piece[speed]", Avatar.Instance.Speed.ToString()));
            tuples.Add(new HTTPTuple("piece[range]", Avatar.Instance.Range.ToString()));
            tuples.Add(new HTTPTuple("piece[body_type]", Avatar.Instance.BodyType.ToString().ToLower()));
            tuples.Add(new HTTPTuple("piece[face]", Avatar.Instance.FaceAsset));
            tuples.Add(new HTTPTuple("piece[hair]", Avatar.Instance.HairAsset));
            tuples.Add(new HTTPTuple("piece[skin_color]", Avatar.Instance.SkinColor));
            tuples.Add(new HTTPTuple("piece[hair_color]", Avatar.Instance.HairColor));
            /*
            parameters.Add("piece[health]", Avatar.Instance.Health.ToString());
            parameters.Add("piece[speed]", Avatar.Instance.Speed.ToString());
            parameters.Add("piece[range]", Avatar.Instance.Range.ToString());
            //Debug.Log(Avatar.Instance.Health + " / " + Avatar.Instance.Speed + " / " + Avatar.Instance.Range);
            parameters.Add("piece[body_type]", Avatar.Instance.BodyType.ToString().ToLower());
            //Debug.Log("writing body type to " + Avatar.Instance.BodyType);
            parameters.Add("piece[face]", Avatar.Instance.FaceAsset);
            parameters.Add("piece[hair]", Avatar.Instance.HairAsset);
            parameters.Add("piece[skin_color]", Avatar.Instance.SkinColor);
            parameters.Add("piece[hair_color]", Avatar.Instance.HairColor);
            */
        }
        yield return StartCoroutine(BestHTTPHelper.Instance.CallToServerForJson(url, HTTPMethods.Post, tuples, null, DisplayError, DisplayError, RequestFailure));
    }

    public IEnumerator StartPostOutcomeToServer(Team redTeam, Team blueTeam, float matchLength)
    {
        string url = _url + "/games/" + _gameData.id;
        string winner = "";
        if (redTeam.Status == TeamStatus.WON)
            winner = "red";
        else if (blueTeam.Status == TeamStatus.WON)
            winner = "blue";
        else
            winner = "none";

        List<HTTPTuple> tuples = NewParams();

        // outcome data
        tuples.Add(new HTTPTuple("game[winner]", winner));
        tuples.Add(new HTTPTuple("game[match_length]", matchLength.ToString()));
        string turnData = DataRecorder.Instance.GetJsonTurnData();
        tuples.Add(new HTTPTuple("game[moves]", turnData));

        //Debug.Log("before " + tupleList.Count);

        // player data
        OutputPlayerOutcomesForTeam(redTeam, tuples);
        OutputPlayerOutcomesForTeam(blueTeam, tuples);

        //Debug.Log("after " + tupleList.Count);

        /*
        for (int i = 0; i < tupleList.Count; i++)
        {
            Debug.Log(tupleList[i].Key + " --- " + tupleList[i].Value);
        }
        */

        yield return StartCoroutine(BestHTTPHelper.Instance.CallToServerForJson(url, HTTPMethods.Put, tuples, SetGameInfo, DisplayError, DisplayError, RequestFailure));
    }

	HTTPTuple PlayerOutcomeTuple(string key, string value)
	{
		return new HTTPTuple("game[player_outcomes][][" + key + "]", value);
	}

    void OutputPlayerOutcomesForTeam(Team team, List<HTTPTuple> tupleList)
    {
        Piece piece = null;
        int i = 0;
        for (i = 0; i < team.Pieces.Count; i++)
        {
            piece = team.Pieces[i];

			tupleList.Add(PlayerOutcomeTuple("team", team.GetColor.ToString().ToLower()));
			tupleList.Add(PlayerOutcomeTuple("player_id", piece.ID.ToString()));
			tupleList.Add(PlayerOutcomeTuple("takedowns", piece.Takedowns.ToString()));
			tupleList.Add(PlayerOutcomeTuple("throws", piece.BalloonsThrown.ToString()));
			tupleList.Add(PlayerOutcomeTuple("pickups", piece.Pickups.ToString()));
			tupleList.Add(PlayerOutcomeTuple("flag_carry_distance", Utilities.RoundToDecimals(piece.DistanceWithFlag * METERS_PER_MAP_UNIT, 2).ToString()));
			tupleList.Add(PlayerOutcomeTuple("captures", Utilities.OneOrZero(team.Status == TeamStatus.WON && piece == team.AttackMVP)));
            //Debug.Log(team.GetColor + " player " + i + " ammo count = " + piece.Ammo.AmmoList.Count);
            for (int j = 0; j < piece.Ammo.AmmoList.Count; j++)
            {
                //Debug.Log(piece.Ammo.AmmoList[j].ToString().ToLower());
                tupleList.Add(new HTTPTuple("game[player_outcomes][][ammo][]", piece.Ammo.AmmoList[j].ToString().ToLower()));
            }
        }
    }

    public IEnumerator StartBuyGear(string gear)
    {
        string url = _url + "/players/" + _playerID + "/buy";
        List<HTTPTuple> tuples = NewParams();
        tuples.Add(new HTTPTuple("gear[name]", gear));
        //Dictionary<string, string> parameters = new Dictionary<string, string>();
        //parameters.Add("gear[name]", gear);
        _responseData = new ResponseData();
        _responseData.Success = false;
        yield return StartCoroutine(BestHTTPHelper.Instance.CallToServerForJson(url, HTTPMethods.Post, tuples, CheckBoughtGear, DisplayError, DisplayError, RequestFailure));
    }

    void CheckBoughtGear(string json)
    {
        _responseData = JsonConvert.DeserializeObject<ResponseData>(json);
        _responseData.Success = true;
    }

    public IEnumerator StartBuyAmmo(string ammo)
    {
        string url = _url + "/players/" + _playerID + "/buy";
        List<HTTPTuple> tuples = NewParams();
        tuples.Add(new HTTPTuple("ammo[name]", ammo));
        //Dictionary<string, string> parameters = new Dictionary<string, string>();
        //parameters.Add("ammo[name]", ammo);
        _responseData = new ResponseData();
        _responseData.Success = false;
        yield return StartCoroutine(BestHTTPHelper.Instance.CallToServerForJson(url, HTTPMethods.Post, tuples, CheckBoughtAmmo, DisplayError, DisplayError, RequestFailure));
    }

    void CheckBoughtAmmo(string json)
    {
        _responseData = JsonConvert.DeserializeObject<ResponseData>(json);
        _responseData.Success = true;
    }

    public IEnumerator StartEquipGear(string gear)
    {
        string url = _url + "/players/" + _playerID + "/equip";
        List<HTTPTuple> tuples = NewParams();
        tuples.Add(new HTTPTuple("gear[name]", gear));
        //Dictionary<string, string> parameters = new Dictionary<string, string>();
        //parameters.Add("gear[name]", gear);
        _responseData = new ResponseData();
        _responseData.Success = false;
        yield return StartCoroutine(BestHTTPHelper.Instance.CallToServerForJson(url, HTTPMethods.Post, tuples, CheckEquippedGear, DisplayError, DisplayError, RequestFailure));
    }

    void CheckEquippedGear(string json)
    {
        //Debug.Log(json);
        _responseData = JsonConvert.DeserializeObject<ResponseData>(json);
        _responseData.Success = true;
        //Debug.Log(json);
    }

    public IEnumerator StartUnequipGear(string gear)
    {
        string url = _url + "/players/" + _playerID + "/unequip";
        List<HTTPTuple> tuples = NewParams();
        tuples.Add(new HTTPTuple("gear[name]", gear));
        _responseData = new ResponseData();
        _responseData.Success = false;
        yield return StartCoroutine(BestHTTPHelper.Instance.CallToServerForJson(url, HTTPMethods.Post, tuples, CheckEquippedGear, DisplayError, DisplayError, RequestFailure));
    }

    public IEnumerator StartRedeemSteps()
    {
        string url = _url + "/players/" + _playerID + "/claim_steps";
        yield return StartCoroutine(BestHTTPHelper.Instance.CallToServerForJson(url, HTTPMethods.Post, NewParams(), RedeemSteps, DisplayError, DisplayError, RequestFailure));
    }

    void RedeemSteps(string json)
    {
        PlayerResponseData responseData = JsonConvert.DeserializeObject<PlayerResponseData>(json);
        PlayerData playerData = responseData.player;
        int newPlayerCoins = playerData.coins;
        _coinsClaimed = newPlayerCoins - Avatar.Instance.Coins;
        int newPlayerSteps = playerData.steps_available;
        _stepsClaimed = Avatar.Instance.Steps - newPlayerSteps;
        Avatar.Instance.Coins = newPlayerCoins;
        Avatar.Instance.Steps = newPlayerSteps;
    }

    public IEnumerator StartRedeemActiveMinutes()
    {
        string url = _url + "/players/" + _playerID + "/claim_active_minutes";
        yield return StartCoroutine(BestHTTPHelper.Instance.CallToServerForJson(url, HTTPMethods.Post, NewParams(), RedeemActiveMinutes, DisplayError, DisplayError, RequestFailure));
    }

    void RedeemActiveMinutes(string json)
    {
        Debug.Log(json);
        PlayerResponseData responseData = JsonConvert.DeserializeObject<PlayerResponseData>(json);
        PlayerData playerData = responseData.player;
        //Debug.Log("received player info with gems = " + playerData.gems);
        //Debug.Log("coins = " + playerData.coins);
        //Debug.Log("minutes = " + playerData.active_minutes);
        Avatar.Instance.ActiveMins = playerData.active_minutes;
        //Avatar.Instance.ActiveMet = playerData.active_goal_met;
        //Avatar.Instance.ActiveClaimed = playerData.active_minutes_claimed;
        Avatar.Instance.Gems = playerData.gems;
        Avatar.Instance.GemsAvailable = playerData.gems_available;
    }

    public IEnumerator StartGetSeason()
    {
        string url = _url + "/seasons/current";
        yield return StartCoroutine(BestHTTPHelper.Instance.CallToServerForJson(url, HTTPMethods.Get, NewParams(), SetSeasonInfo, DisplayError, DisplayError, RequestFailure));
    }

    void SetSeasonInfo(string json)
    {
        SeasonResponseData responseData = JsonConvert.DeserializeObject<SeasonResponseData>(json);
        _seasonSyncData = responseData.season;
    }

    public IEnumerator StartGetGear()
    {
        string url = _url + "/gears";
        yield return StartCoroutine(BestHTTPHelper.Instance.CallToServerForJson(url, HTTPMethods.Get, NewParams(), SetGearInfo, DisplayError, DisplayError, RequestFailure));
    }

    void SetGearInfo(string json)
    {
        _gearResponseData = JsonConvert.DeserializeObject<GearResponseData>(json);

        for (int i = 0; i < _gearResponseData.gears.Count; i++)
        {
            GearData data = _gearResponseData.gears[i];
        }
    }

    public IEnumerator StartArrangeAmmo()
    {
        string url = _url + "/players/" + _playerID + "/arrange/";
        List<HTTPTuple> tuples = NewParams();
        for (int i = 0; i < Avatar.Instance.Ammo.AmmoList.Count; i++)
        {
            tuples.Add(new HTTPTuple("ammo[]", Avatar.Instance.Ammo.AmmoList[i].ToString().ToLower()));
        }
        yield return StartCoroutine(BestHTTPHelper.Instance.CallToServerForJson(url, HTTPMethods.Post, tuples, null, DisplayError, DisplayError, RequestFailure));
    }
    #endregion

    #region Error Methods
    void StoreError(Dictionary<string, object> dict)
    {
        _error = "";
        if (dict != null)
        {
            _error = dict["message"].ToString();
            Debug.Log(_error);
        }
        else
            _error = "Error fetching data from server";
    }

    void DisplayError(Dictionary<string, object> dict)
    {
        _error = "";
        string message = "";
        if (dict != null)
        {
            message = dict["message"].ToString();
            _error = dict["message"].ToString();
        }
        else
            message = "Error fetching data from server";
        //Debug.Log("presenting error");
        LoadingAlert.FinishLoading();
        HTTPAlert.Present("Error", message, null, null, true);
    }

    void RequestFailure()
    {
        //Debug.Log("request failure");
        _requestFailure = true;
        LoadingAlert.FinishLoading();
        HTTPAlert.Present("HTTP Error", "Could not connect to the game server. Check your internet connection", null, null, true);
    }
    #endregion

    #region Accessors
    public GameData GameData
    {
        get { return _gameData; }
    }

    public GameData PreviousGameData
    {
        get { return _previousGameData; }
    }

    public string PlayerID
    {
        get { return _playerID; }
    }

    public string PlayerName
    {
        get { return _playerName; }
    }

    public SeasonData SeasonSyncData
    {
        get { return _seasonSyncData; }
    }

    public GearResponseData GearResponseData
    {
        get { return _gearResponseData; }
    }

    public int CoinsClaimed
    {
        get { return _coinsClaimed; }
    }

    public int StepsClaimed
    {
        get { return _stepsClaimed; }
    }

    /*
    public PathResponseData PathResponseData
    {
        get { return _pathResponseData; }
    }
    */

    public ResponseData ResponseData
    {
        get { return _responseData; }
    }

    public string Error
    {
        get { return _error; }
    }

    public OnlineGameStatus GameStatus
    {
        get { return _gameStatus; }
    }

    public PlayerResponseData PlayerReponseData
    {
        get { return _playerResponseData; }
    }

    public bool GetRequestFailure
    {
        get { return _requestFailure; }
    }
    #endregion
}

#region Data Classes
public class GameResponseData
{
    public string status;
    public GameData game;
}

public class GameData
{
    public string id;
    public string created_at;
    public string updated_at;
    public bool locked;
    public bool current;
    public int season_id;
    public string state;
    public string winner;
    public string match_length;
    public string scheduled_start;
    public string moves;
    public List<TeamSummaryData> team_summaries;
    public List<PieceData> pieces;
    public List<PlayerOutcomeData> player_outcomes;
    public List<PathData> paths;
}

public class TeamOutcomeData
{
    public string team;
    public List<int> attack_mvps;
    public List<int> defend_mvps;
    public int takedowns;
    public int throws;
    public int pickups;
    public int captures;
    public int flag_carry_distance;
}

public class TeamSummaryData
{
    public string team;
    public List<int> attack_mvps;
    public List<int> defend_mvps;
    public int takedowns;
    public int throws;
    public int pickups;
    public int captures;
    public int flag_carry_distance;
}

public class PieceData
{
    public string team;
    public string role;
    public List<Point> path;
    public float speed;
    public int health;
    public float range;
    public int player_id;
    public string body_type;
    public string face;
    public string hair;
    public string skin_color;
    public string hair_color;
    public string player_name;
    public List<string> ammo;
    public List<string> gear_owned;
    public List<string> gear_equipped;
}

public class PlayerOutcomeData
{
    public int id;
    public string team;
    public int takedowns;
    public int throws;
    public int pickups;
    public string created_at;
    public string updated_at;
    public int player_id;
    public float flag_carry_distance;
    public int captures;
    public int attack_mvp;
    public int defend_mvp;
    public int game_id;
}

public class PlayerSummaryData
{
    public int player_id;
    public int takedowns;
    public int throws;
    public int pickups;
    public int captures;
    public int flag_carry_distance;
    public int attack_mvp;
    public int defend_mvp;
}

public class SeasonResponseData
{
    public string status;
    public SeasonData season;
}

public class SeasonData
{
    public int id;
    public string created_at;
    public string updated_at;
    public string name;
    public bool current;
    public List<TeamSummaryData> team_summaries;
    public List<PlayerSummaryData> player_summaries;
}

public class PlayerResponseData
{
    public string status;
    public PlayerData player;
}

public class PlayerData
{
    public int id;
    public string name;
    public string team;
    public string created_at;
    public string updated_at;
    public int coins;
    public int gems;
    public bool embodied;
    public bool gamemaster;
    public bool admin;
    public string activities_synced_at;
    public int steps_available;
    public int active_minutes;
    //public bool active_goal_met;
    //public bool active_minutes_claimed;
    public int gems_available;
    public List<string> gear_owned;
    public List<string> gear_equipped;
    public List<string> ammo;
    public PieceData piece;
}

public class PathData
{
    public string team;
    public Point button_position;
    public int button_angle;
    public string role;
    public List<Point> points;
    public int count;
    public bool active;
}

public class GearResponseData
{
    public string status;
    public List<GearData> gears;
}

public class GearData
{
    public string name;
    public string body_type;
    public string display_name;
    public string description;
    public int health_bonus;
    public int speed_bonus;
    public int range_bonus;
    public string hair;
    public string gear_type;
    public string asset_name;
    public string icon_name;
    public int coins;
    public int gems;
    public int level;
    public bool equipped_by_default;
    public bool owned_by_default;
    public bool color_decal;
}

public class TokenResponseData
{
    public string status;
    public string token;
    public string player_id;
}

public class ResponseData
{
    public bool Success;
}
#endregion