//#define SLOW_MOTION
//#define LOAD_GAME
//#define QUICK_WIN

using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using System;
using System.Collections;
using System.Collections.Generic;
using gametheory.UI;
using CampConquer;

public class GameManager : MonoBehaviour
{
    #region Constants
    const int NUM_OFF_PLAYERS = 25;
    const int NUM_DEF_PLAYERS = 25;
    const float COUNTDOWN_TIME = 3.0f;
    const float GAME_OVER_TIME = 2.0f;
    const float X_FACTOR = 0.5f; //0.704f;
    const float Y_FACTOR = 0.5f; //0.4575f;
    #endregion

    #region Public Vars
    public GameObject BlueFlagPrefab;
    public GameObject RedFlagPrefab;
    public PlayerInfo PlayerInfoPrefab;
    public Image PieceInfoPrefab;
    public Piece GN1Prefab;
    public Piece GN2Prefab;
    public Piece MPrefab;
    public Piece FPrefab;
    public ResultsView ResultsView;
    public Balloon BalloonPrefab;
    public List<SpriteRenderer> BGSprites;
    public ExtendedButton PlayButton;
    public ExtendedButton LockButton;
    public ExtendedButton LoadButton;
    public ExtendedText CountdownText;
    public static bool Client = false;
    public static TeamColor ClientColor;
    public Canvas Canvas;
    public Camera MainCamera;
    #endregion

    #region Private Vars
    List<Balloon> _balloons;
    Piece _replayWatcherPiece;
    Team _redTeam;
    Team _blueTeam;
    Flag _redFlag;
    Flag _blueFlag;
    DateTime _startTime;
    TimeSpan _gameTime;
    PlayerInfo _replayWatcherInfo;
    //Image _replayWatcherInfo;
    string _gameID;
    float _countdownTimer;
    float _gameOverTimer;
    int _replayIndex;
    bool _bgAssets;
    bool _replay;
    bool _countdown;
    bool _gameOver;
    #endregion

    #region Unity Methods
    void Start()
    {
        _bgAssets = false;
        _replay = false;
        _gameOver = false;
        enabled = false;
        SetUpButtons();
    }

    void FixedUpdate()
    {
        if (_replay)
        {
            if (_gameOver)
            {
                _gameOverTimer += Time.deltaTime;
                if (_gameOverTimer >= GAME_OVER_TIME)
                {
                    enabled = false;
                    LoadingAlert.Present();
                    PlayerPrefs.SetString("LAST_GAME_VIEWED", OnlineManager.Instance.GameData.id);
                    //Debug.Log("saved game id " + OnlineManager.Instance.GameData.id);
                    PlayerPrefs.Save();
                    ActivateResultsView();
                }
            }
            else
            {
                if (_countdown)
                {
                    _countdownTimer -= Time.deltaTime;
                    if (_countdownTimer < 0.0f)
                    {
                        UIViewController.DeactivateUIView("CountdownView");
                        _countdown = false;
                        //Debug.Log("here!");
                    }
                    else
                    {
                        int count = (int)Mathf.Ceil(_countdownTimer);
                        CountdownText.Text = count.ToString();
                    }
                }
                else
                {
                    if (_replayWatcherInfo != null)
                    {
                        _replayWatcherInfo.SetPosition(_replayWatcherPiece.transform.position);
                        //SetWatcherInfoPosition();
                    }

                    TurnData turnData = DataRecorder.Instance.TurnDataList[_replayIndex];
                    ReplayTurn(turnData);
                    _replayIndex++;

                    // game over
                    if (_gameOver)
                    {
                        _gameOverTimer += Time.deltaTime;
                        if (_gameOverTimer >= GAME_OVER_TIME)
                        {
                            enabled = false;
                            LoadingAlert.Present();
                            PlayerPrefs.SetString("LAST_GAME_VIEWED", OnlineManager.Instance.GameData.id);
                            //Debug.Log("saved game id " + OnlineManager.Instance.GameData.id);
                            PlayerPrefs.Save();
                            ActivateResultsView();
                        }
                    }
                    else if (_replayIndex >= DataRecorder.Instance.TurnDataList.Count)
                    {
                        if (_replayWatcherInfo != null)
                            Destroy(_replayWatcherInfo.gameObject);
                        _redTeam.StopPieceAnimations();
                        _blueTeam.StopPieceAnimations();
                        _gameOver = true;
                        _gameOverTimer = 0.0f;
                    }
                }
            }
        }
        else
        {
            if (_gameOver)
            {
                _gameOverTimer += Time.deltaTime;
                if (_gameOverTimer >= GAME_OVER_TIME)
                {
                    enabled = false;
                    LoadingAlert.Present();
                    _gameTime = DateTime.UtcNow - _startTime;
                    _redTeam.CalulateMVPs();
                    _blueTeam.CalulateMVPs();
                    DisplayGameResults();
                }
            }
            else
            {
#if SLOW_MOTION
                if (Input.GetKey(KeyCode.A))
#endif
                {
                    StartTurn(Time.deltaTime);
                    Attack(Time.deltaTime);
                    RecordMoves();
                    RemoveDoneBalloons();
                    if (CheckGameOver())
                    {
                        _redTeam.StopPieceAnimations();
                        _blueTeam.StopPieceAnimations();
                        SoundManager.Instance.PlaySoundEffect(SoundType.CHEER);
                        _gameOver = true;
                        _gameOverTimer = 0.0f;
                    }
                }
            }
        }
    }
    #endregion

    #region Game Setup Methods
    void ClearAllObjects()
    {
        //Debug.Log("ClearAllObjects");
        if (_redFlag != null && _redFlag.Obj != null)
            Destroy(_redFlag.Obj);
        if (_blueFlag != null && _blueFlag.Obj != null)
            Destroy(_blueFlag.Obj);
        int i;
        if (_redTeam != null && _redTeam.Pieces != null)
        {
            for (i = 0; i < _redTeam.Pieces.Count; i++)
            {
                if (_redTeam.Pieces[i] != null && _redTeam.Pieces[i].gameObject != null)
                    Destroy(_redTeam.Pieces[i].gameObject);
            }
            _redTeam.Pieces = null;
        }

        if (_blueTeam != null && _blueTeam.Pieces != null)
        {
            for (i = 0; i < _blueTeam.Pieces.Count; i++)
            {
                if (_blueTeam.Pieces[i] != null && _blueTeam.Pieces[i].gameObject != null)
                    Destroy(_blueTeam.Pieces[i].gameObject);
            }
            _blueTeam.Pieces = null;
        }

        if (_balloons != null)
        {
            for (i = 0; i < _balloons.Count; i++)
            {
                if (_balloons[i] != null && _balloons[i].gameObject != null)
                    Destroy(_balloons[i].gameObject);
            }
        }
        _balloons = new List<Balloon>();
    }

    void StartRecording()
    {
        _startTime = DateTime.UtcNow;
        DataRecorder.Instance.Initialize();
    }

    IEnumerator PlayGame()
    {
        // get the latest game data
        yield return StartCoroutine(OnlineManager.Instance.StartGetGame());

        // play the game
        SetUpGameFromData();
        StartRecording();
        StartGame();
    }

    void SetUpGameFromData()
    {
        UIViewController.DeactivateUIView("MainView");
        UIViewController.DeactivateUIView("ResultsView");

        if (!_bgAssets)
        {
            _bgAssets = true;
            for (int i = 0; i < BGSprites.Count; i++)
            {
                BGSprites[i].enabled = true;
            }
        }

        ClearAllObjects();
        if (_redTeam != null)
            _redTeam.Reset();
        if (_blueTeam != null)
            _blueTeam.Reset();

        CreateFlags();

        // create teams
        List<Piece> redPieces = new List<Piece>();
        _redTeam = new Team(TeamColor.RED, null, _redFlag.Position);
        List<Piece> bluePieces = new List<Piece>();
        _blueTeam = new Team(TeamColor.BLUE, null, _blueFlag.Position);
        List<Piece> currentPieceList;
        Team team;

        for (int i = 0; i < OnlineManager.Instance.GameData.pieces.Count; i++)
        {
            PieceData pieceData = OnlineManager.Instance.GameData.pieces[i];
            if (pieceData.team == "red")
            {
                team = _redTeam;
                currentPieceList = redPieces;
            }
            else
            {
                team = _blueTeam;
                currentPieceList = bluePieces;
            }
            CreatePiece(currentPieceList, pieceData);
        }

        _redTeam.Pieces = redPieces;
        _redTeam.SetPieceLookups();
        _blueTeam.Pieces = bluePieces;
        _blueTeam.SetPieceLookups();
        _startTime = DateTime.UtcNow;
    }

    void CreateFlags()
    {
        // create flags
        _redFlag = new Flag(TeamColor.RED, Team.RED_FLAG_POS);
        _redFlag.Obj = (GameObject)Instantiate(RedFlagPrefab, _redFlag.Position, Quaternion.identity);

        _blueFlag = new Flag(TeamColor.BLUE, Team.BLUE_FLAG_POS);
        _blueFlag.Obj = (GameObject)Instantiate(BlueFlagPrefab, _blueFlag.Position, Quaternion.identity);
    }

    void CreatePiece(List<Piece> pieceList, PieceData pieceData)
    {
        Piece piece = null;
        switch (pieceData.body_type)
        {
            case "gender_neutral_1":
                piece = (Piece)Instantiate(GN1Prefab, Vector3.zero, Quaternion.identity);
                break;
            case "gender_neutral_2":
                piece = (Piece)Instantiate(GN2Prefab, Vector3.zero, Quaternion.identity);
                break;
            case "male":
                piece = (Piece)Instantiate(MPrefab, Vector3.zero, Quaternion.identity);
                break;
            default:
                piece = (Piece)Instantiate(FPrefab, Vector3.zero, Quaternion.identity);
                break;
        }
        piece.name = pieceData.player_id + " / " + pieceData.player_name;
        //Debug.Log("creating piece with id " + pieceData.player_id + " loaded id = " + OnlineManager._playerID);
        piece.SetPieceFromPieceData(pieceData, _redTeam, _blueTeam);
        pieceList.Add(piece);

        // create watcher info bubble
        if (pieceData.player_id.ToString() == OnlineManager._playerID)
        {
            _replayWatcherPiece = piece;

            _replayWatcherInfo = (PlayerInfo)Instantiate(PlayerInfoPrefab, Vector3.zero, Quaternion.identity);
            _replayWatcherInfo.transform.SetParent(Canvas.transform, false);

            //_replayWatcherInfo = (Image)Instantiate(PieceInfoPrefab, Vector3.zero, Quaternion.identity);
            //_replayWatcherInfo.transform.SetParent(Canvas.transform, false);
            /*
            if (piece.GetTeam == _redTeam)
                _replayWatcherInfo.color = Colors.RedBannerColor;
            else
                _replayWatcherInfo.color = Colors.BlueBannerColor;
*/
            //Text replayWatcherName = _replayWatcherInfo.transform.GetChild(0).transform.GetChild(1).GetComponent<Text>();
            //replayWatcherName.text = pieceData.player_name;

            _replayWatcherInfo.Initialize(piece.GetTeam.GetColor, pieceData.player_name);
            _replayWatcherInfo.SetPosition(_replayWatcherPiece.transform.position);

            //SetWatcherInfoPosition();
        }
    }

    /*
    void SetWatcherInfoPosition()
    {
        if (_replayWatcherPiece != null)
        {
            RectTransform CanvasRect = Canvas.GetComponent<RectTransform>();
            Vector2 ViewportPosition = MainCamera.WorldToViewportPoint(_replayWatcherPiece.transform.position);
            Vector2 WorldObject_ScreenPosition = new Vector2(((ViewportPosition.x * CanvasRect.sizeDelta.x) - (CanvasRect.sizeDelta.x * X_FACTOR)), ((ViewportPosition.y * CanvasRect.sizeDelta.y) - (CanvasRect.sizeDelta.y * Y_FACTOR)));
            _replayWatcherInfo.rectTransform.anchoredPosition3D = new Vector3(WorldObject_ScreenPosition.x, WorldObject_ScreenPosition.y, 0.0f);
        }
        else
        {
            Destroy(_replayWatcherInfo.gameObject);
        }
    }
    */

    void StartGame()
    {
        enabled = true;
        SoundManager.Instance.StartBattleMusic();
    }
    #endregion

    #region Game Play Methods
    void StartTurn(float deltaTime)
    {
        DataRecorder.Instance.StartTurnData();

        _redTeam.UpdatePieces(_blueFlag);
        _blueTeam.UpdatePieces(_redFlag);
    }

    void Attack(float deltaTime)
    {
        TeamAttack(_redTeam, _blueTeam, deltaTime);
        TeamAttack(_blueTeam, _redTeam, deltaTime);
    }

    void TeamAttack(Team team, Team targetTeam, float deltaTime)
    {
        Piece attackPiece;
        Piece pieceToHit;
        int i;

        for (i = 0; i < team.Pieces.Count; i++)
        {
            attackPiece = team.Pieces[i];

            if (attackPiece.Status == PieceStatus.NORMAL && attackPiece.Ammo.AmmoCount() > 0 && !attackPiece.HasFlag)
            {
                if (attackPiece.CoolDownTimer <= 0.0f)
                {
                    AmmoData ammoData = AmmoManager.Instance.GetAmmoData((int)attackPiece.Ammo.GetNextAmmoType());
                    pieceToHit = targetTeam.FindClosestPiece(attackPiece.Position, attackPiece.RangeCalc, ammoData.RangeBonus);
                    if (pieceToHit != null)
                    {
                        AmmoType ammoType = attackPiece.Throw();
                        ThrowBalloon(attackPiece.GetTeam.GetColor, attackPiece.transform.localPosition, pieceToHit.transform.localPosition, ammoType);
                        if (pieceToHit.GetHit(ammoData.Damage))
                        {
                            // if flag was dropped (true for GetHit), set status of flag
                            if (team.GetColor == TeamColor.RED)
                                _redFlag.Status = FlagStatus.DROPPED;
                            else
                                _blueFlag.Status = FlagStatus.DROPPED;
                        }

                        // increment takedowns
                        if (pieceToHit.Status == PieceStatus.OUT)
                            attackPiece.Takedowns++;

                        //DataRecorder.AddHitToTurnData(attackPiece.ID, pieceToHit.ID);
                        attackPiece.CoolDownTimer = attackPiece.CoolDownTime;

                        // check the ranged damage
                        if (ammoData.SplashDamage != 0)
                        {
                            for (int j = 0; j < targetTeam.Pieces.Count; j++)
                            {
                                Piece pieceToCheck = targetTeam.Pieces[j];
                                if (pieceToCheck.Status == PieceStatus.NORMAL && pieceToCheck != pieceToHit)
                                {
                                    float distance = (pieceToHit.Position - pieceToCheck.Position).magnitude;
                                    if (distance <= ammoData.SplashRadius)
                                    {
                                        bool hasFlag = pieceToCheck.GetHit(ammoData.SplashDamage);
                                        if (pieceToCheck.Status == PieceStatus.OUT)
                                        {
                                            if (hasFlag)
                                            {
                                                if (team.GetColor == TeamColor.RED)
                                                    _redFlag.Status = FlagStatus.DROPPED;
                                                else
                                                    _blueFlag.Status = FlagStatus.DROPPED;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                else
                {
                    attackPiece.CoolDownTimer -= deltaTime;
                    if (attackPiece.CoolDownTimer <= 0.0f)
                        attackPiece.CoolDownTimer = 0.0f;
                    //Debug.Log("now timer = " + attackPlayer.CoolDownTimer);
                }
            }
        }
    }

    void ThrowBalloon(TeamColor color, Vector3 source, Vector3 target, AmmoType ammoType)
    {
        Balloon balloon = (Balloon)Instantiate(BalloonPrefab, source, Quaternion.identity);
        balloon.StartThrow(source, target, ammoType, color);
        _balloons.Add(balloon);

        if (!_replay)
        {
            DataRecorder.Instance.AddThrowToTurnData(source, target, ammoType, color);
        }
    }

    void RemoveDoneBalloons()
    {
        if (_balloons != null)
        {
            for (int i = _balloons.Count - 1; i >= 0; i--)
            {
                if (_balloons[i] != null && _balloons[i].gameObject != null && _balloons[i].Done)
                {
                    Destroy(_balloons[i].gameObject);
                    Balloon balloon = _balloons[i];
                    _balloons.RemoveAt(i);
                    balloon = null;
                }
            }
        }
    }

    bool CheckGameOver()
    {
        _redTeam.CheckGameOver();
        _blueTeam.CheckGameOver();

        DataRecorder.Instance.EndTurnData();

#if QUICK_WIN
#else
        if ((_redTeam.Status == TeamStatus.WON || _blueTeam.Status == TeamStatus.WON) || (_redTeam.Status == TeamStatus.DONE && _blueTeam.Status == TeamStatus.DONE))
#endif
        {
            return true;
        }
        return false;
    }

    void DisplayGameResults()
    {
        StartCoroutine(PostOutcomeToServer());
    }

    IEnumerator PostOutcomeToServer()
    {
        yield return StartCoroutine(OnlineManager.Instance.StartPostOutcomeToServer(_redTeam, _blueTeam, _gameTime.Seconds));
        ActivateResultsView();
    }

    void ActivateResultsView()
    {
        if (OnlineManager.Instance.GameData.winner == "red")
        {
            _redTeam.Status = TeamStatus.WON;
        }
        else if (OnlineManager.Instance.GameData.winner == "blue")
        {
            _blueTeam.Status = TeamStatus.WON;
        }

        int redAttackMVP = -1;
        int blueAttackMVP = -1;
        int redDefenseMVP = -1;
        int blueDefenseMVP = -1;
        if (OnlineManager.Instance.GameData.team_summaries[0].team == "red")
        {
            _redTeam.Downs = OnlineManager.Instance.GameData.team_summaries[0].takedowns;
            _redTeam.FlagCaptures = OnlineManager.Instance.GameData.team_summaries[0].pickups;
            _blueTeam.Downs = OnlineManager.Instance.GameData.team_summaries[1].takedowns;
            _blueTeam.FlagCaptures = OnlineManager.Instance.GameData.team_summaries[1].pickups;
            if (OnlineManager.Instance.GameData.team_summaries[0].attack_mvps != null && OnlineManager.Instance.GameData.team_summaries[0].attack_mvps.Count > 0)
                redAttackMVP = OnlineManager.Instance.GameData.team_summaries[0].attack_mvps[0];
            if (OnlineManager.Instance.GameData.team_summaries[0].defend_mvps != null && OnlineManager.Instance.GameData.team_summaries[0].defend_mvps.Count > 0)
                redDefenseMVP = OnlineManager.Instance.GameData.team_summaries[0].defend_mvps[0];
            if (OnlineManager.Instance.GameData.team_summaries[1].attack_mvps != null && OnlineManager.Instance.GameData.team_summaries[1].attack_mvps.Count > 0)
                blueAttackMVP = OnlineManager.Instance.GameData.team_summaries[1].attack_mvps[0];
            if (OnlineManager.Instance.GameData.team_summaries[1].defend_mvps != null && OnlineManager.Instance.GameData.team_summaries[1].defend_mvps.Count > 0)
                blueDefenseMVP = OnlineManager.Instance.GameData.team_summaries[1].defend_mvps[0];
        }
        else
        {
            _blueTeam.Downs = OnlineManager.Instance.GameData.team_summaries[0].takedowns;
            _blueTeam.FlagCaptures = OnlineManager.Instance.GameData.team_summaries[0].pickups;
            _redTeam.Downs = OnlineManager.Instance.GameData.team_summaries[1].takedowns;
            _redTeam.FlagCaptures = OnlineManager.Instance.GameData.team_summaries[1].pickups;
            if (OnlineManager.Instance.GameData.team_summaries[1].attack_mvps != null && OnlineManager.Instance.GameData.team_summaries[1].attack_mvps.Count > 0)
                redAttackMVP = OnlineManager.Instance.GameData.team_summaries[1].attack_mvps[0];
            if (OnlineManager.Instance.GameData.team_summaries[1].defend_mvps != null && OnlineManager.Instance.GameData.team_summaries[1].defend_mvps.Count > 0)
                redDefenseMVP = OnlineManager.Instance.GameData.team_summaries[1].defend_mvps[0];
            if (OnlineManager.Instance.GameData.team_summaries[0].attack_mvps != null && OnlineManager.Instance.GameData.team_summaries[0].attack_mvps.Count > 0)
                blueAttackMVP = OnlineManager.Instance.GameData.team_summaries[0].attack_mvps[0];
            if (OnlineManager.Instance.GameData.team_summaries[0].defend_mvps != null && OnlineManager.Instance.GameData.team_summaries[0].defend_mvps.Count > 0)
                blueDefenseMVP = OnlineManager.Instance.GameData.team_summaries[0].defend_mvps[0];
        }
        //Debug.Log("redAttackMVP = " + redAttackMVP + " blueAttackMVP = " + blueAttackMVP + " redDefenseMVP = " + redDefenseMVP + " blueDefenseMVP = " + blueDefenseMVP);
        // find MVP names
        Piece piece = null;
        int i;
        // set MVPs
        for (i = 0; i < _redTeam.Pieces.Count; i++)
        {
            piece = _redTeam.Pieces[i];
            if (piece.ID == redAttackMVP)
            {
                _redTeam.AttackMVP = piece;
            }
            else if (piece.ID == redDefenseMVP)
            {
                _redTeam.DefendMVP = piece;
            }
        }
        for (i = 0; i < _blueTeam.Pieces.Count; i++)
        {
            piece = _blueTeam.Pieces[i];
            if (piece.ID == blueAttackMVP)
            {
                _blueTeam.AttackMVP = piece;
            }
            else if (piece.ID == blueDefenseMVP)
            {
                _blueTeam.DefendMVP = piece;
            }
        }

        ResultsView.Init(_redTeam, _blueTeam, _gameTime);
        UIViewController.ActivateUIView("ResultsView");
    }

    void RecordMoves()
    {
        _redTeam.RecordPieceMoves();
        _blueTeam.RecordPieceMoves();
    }
    #endregion

    #region UI Methods
    public void ClickBackButton()
    {
        if (Client)
        {
            SceneManager.LoadScene("Client");
        }
        else
        {
            UIViewController.DeactivateUIView("ResultsView");
            UIViewController.ActivateUIView("MainView");

            SetUpButtons();
        }
    }

    void SetUpButtons()
    {
        if (SceneManager.GetActiveScene().name == "Moderator")
        {
            PlayButton.Disable();

            if (Client)
            {
                LoadingAlert.Present();
                PlayButton.Deactivate();
                LockButton.Deactivate();
                _countdown = true;
                _countdownTimer = COUNTDOWN_TIME;
                StartCoroutine(ReplayGame());
            }
            else
            {
                UIViewController.ActivateUIView("MainView");
                //OnlineManager.Instance.SetServer(false, true, false);
                StartCoroutine(GetGameData());
            }
        }
    }

    IEnumerator GetGameData()
    {
        yield return StartCoroutine(OnlineManager.Instance.StartGetGame());
        PathManager.Instance.Initialize();
        LoadButton.Deactivate();

        if (OnlineManager.Instance.GameData.locked)
        {
            EnablePlayButton();
        }
        else
        {
            EnableLockButton();
        }
    }

    public void ClickLockGameButton()
    {
        LockButton.Deactivate();
        StartCoroutine(LockGame());
    }

    IEnumerator LockGame()
    {
        yield return StartCoroutine(OnlineManager.Instance.StartLockGame());

        EnablePlayButton();
    }

    void EnablePlayButton()
    {
        PlayButton.Activate();
        PlayButton.Enable();
        LockButton.Disable();
    }

    void EnableLockButton()
    {
        LockButton.Activate();
        LockButton.Enable();
        PlayButton.Disable();
    }

    public void ClickPlayButton()
    {
        PlayButton.Deactivate();
        StartCoroutine(PlayGame());
    }

    public void ClickReplayGame()
    {
        //OnlineManager.Instance.SetServer(true, false, false);
        PathManager.Instance.Initialize();

        StartCoroutine(ReplayGame());
    }
    #endregion

    #region Replay Methods
    IEnumerator ReplayGame()
    {
        //Debug.Log("replaygame");

        yield return StartCoroutine(OnlineManager.Instance.StartReplayGame());

        PathManager.Instance.Initialize();

        //_loadedGameData = true;

        SetUpGameFromData();

        LoadingAlert.FinishLoading();
        UIViewController.ActivateUIView("CountdownView");
        _replay = true;
        enabled = true;
    }

    void ReplayTurn(TurnData turnData)
    {
        Piece piece;
        int i;
        // red moves
        for (i = 0; i < turnData.RM.Count; i++)
        {
            piece = _redTeam.LookupPiece(turnData.RM[i].ID);
            if (piece != null)
            {
                piece.SetReplayPosition(new Vector2(turnData.RM[i].X, turnData.RM[i].Y), turnData.RM[i].T, turnData.RM[i].S);
                if (turnData.RM[i].F)
                    _blueFlag.SetPosition(new Vector2(turnData.RM[i].X, turnData.RM[i].Y));
            }
        }
        // blue moves
        for (i = 0; i < turnData.BM.Count; i++)
        {
            piece = _blueTeam.LookupPiece(turnData.BM[i].ID);
            if (piece != null)
            {
                piece.SetReplayPosition(new Vector2(turnData.BM[i].X, turnData.BM[i].Y), turnData.BM[i].T, turnData.BM[i].S);
                if (turnData.BM[i].F)
                    _redFlag.SetPosition(new Vector2(turnData.BM[i].X, turnData.BM[i].Y));
            }
        }
        // throws
        for (i = 0; i < turnData.T.Count; i++)
        {
            Throw data = turnData.T[i];
            ThrowBalloon((TeamColor)data.C, new Vector3(data.SX, data.SY, 0.0f), new Vector3(data.TX, data.TY, 0.0f), (AmmoType)data.T);
        }
    }
    #endregion
}