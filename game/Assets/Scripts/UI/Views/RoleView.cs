using UnityEngine;
using UnityEngine.SceneManagement;
using System;
using System.Collections;
using gametheory.UI;
using CampConquer;

public class RoleView : UIView 
{
    #region Enums
    enum RoleViewState { ROLE = 0, PATH, POSITION, PATH_SELECTED, POSITION_SELECTED };
    #endregion

    #region Public Vars
    public ExtendedText TimeText;
    public ExtendedButton OffenseButton;
    public ExtendedButton DefenseButton;
    public ExtendedButton SelectButton;
    public ExtendedButton RefreshButton;
    public ExtendedButton BackButton;
    public ExtendedButton BattleButton;
    public ExtendedImage PrepareSplashImage;
    public ExtendedImage PreparedSplashImage;
    public ExtendedImage TimerPanelImage;
    public ExtendedImage BattleCompleteImage;
    public Sprite RedBattleInProgressSprite;
    public Sprite BlueBattleInProgressSprite;
    public Sprite BluePreparedSprite;
    public Sprite BluePrepareSprite;
    public Sprite BlueBattleCompleteSprite;

    public static bool UseCollidersForPaths;
    #endregion

    #region Private Vars
    DateTime _nextBattleDateTime;
    RoleViewState _state;
    #endregion

    #region Unity Methods
    void Update()
    {
        SetTimeText();
    }
    #endregion

    #region Overridden Methods
    protected override void OnInit()
    {
        base.OnInit();

        PathView.activateSelectButton += ActivateSelectButton;
        PositionView.activateSelectButton += ActivateSelectButton;

        //BattleButton.Activate();
    }

    protected override void OnActivate()
    {
        base.OnActivate();

        StartCoroutine(CheckBattleStatus());
    }

    protected override void OnCleanUp()
    {
        base.OnCleanUp();

        PathView.activateSelectButton -= ActivateSelectButton;
        PositionView.activateSelectButton -= ActivateSelectButton;
    }
    #endregion

    #region Methods
    public void LoadBattleScene()
    {
        GameManager.Client = true;
        GameManager.ClientColor = Avatar.Instance.Color;
        //GameManager.PlayerWatchingID = OnlineManager.Instance.PlayerID;
        SceneManager.LoadScene("Moderator");
    }

    void SetTimeText()
    {
        TimeSpan timeToNextBattle = _nextBattleDateTime - DateTime.Now;
        if (timeToNextBattle < TimeSpan.Zero)
        {
            timeToNextBattle = DateTime.Now - _nextBattleDateTime;
            TimeText.Text = "-" + FormatTimeStr(timeToNextBattle);
        }
        else
            TimeText.Text = FormatTimeStr(timeToNextBattle);
    }

    string FormatTimeStr(TimeSpan timeToNextBattle)
    {
        return timeToNextBattle.Hours.ToString("0") + ":" + timeToNextBattle.Minutes.ToString("00") + ":" + timeToNextBattle.Seconds.ToString("00");
    }
    #endregion

    #region UI Methods
    public static RoleView Load()
    {
        RoleView view = UIView.Load("Views/RoleView", OverriddenViewController.Instance.transform) as RoleView;
        view.name = "RoleView";
        return view;
    }

    public void ClickRole(int roleIndex)
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.BUTTON_CLICK);

        Avatar.Instance.Role = (PieceRole)roleIndex;
        if ((PieceRole)roleIndex == PieceRole.OFFENSE)
        {
            UseCollidersForPaths = true;
            UIViewController.ActivateUIView(PathView.Load());
            _state = RoleViewState.PATH;
        }
        else
        {
            UIViewController.ActivateUIView(PositionView.Load());
            _state = RoleViewState.POSITION;
        }
        OffenseButton.Deactivate();
        DefenseButton.Deactivate();
        PrepareSplashImage.Deactivate();
    }

    public void ClickRefresh()
    {
        LoadingAlert.Present();

        StartCoroutine(RefreshBattleStatus());
    }

    public void ClickBack()
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.BUTTON_CLICK);

        //Debug.Log("ClickBack - status = " + _status);

        switch (_state)
        {
            case RoleViewState.ROLE:
                if (PositionView.Instance != null)
                    PositionView.Instance.RemovePositions();
                if (PathView.Instance != null)
                    PathView.Instance.RemovePaths();
                UIViewController.DeactivateUIView("PathView");
                UIViewController.DeactivateUIView("PositionView");
                UIViewController.DeactivateUIView("RoleView");
                ClientGameManager.Instance.gameObject.SetActive(false);
                UIViewController.ActivateUIView("ClientMainView");
                break;
            case RoleViewState.PATH:
                //Debug.Log(PathView.Instance);
                if (PathView.Instance != null)
                    PathView.Instance.RemovePaths();
                UIViewController.DeactivateUIView("PathView");
                OffenseButton.Activate();
                DefenseButton.Activate();
                PrepareSplashImage.Activate();
                _state = RoleViewState.ROLE;
                SelectButton.Deactivate();
                break;
            case RoleViewState.POSITION:
                if (PositionView.Instance != null)
                    PositionView.Instance.RemovePositions();
                UIViewController.DeactivateUIView("PositionView");
                OffenseButton.Activate();
                DefenseButton.Activate();
                PrepareSplashImage.Activate();
                _state = RoleViewState.ROLE;
                SelectButton.Deactivate();
                break;
            case RoleViewState.PATH_SELECTED:
            case RoleViewState.POSITION_SELECTED:
                if (PositionView.Instance != null)
                    PositionView.Instance.RemovePositions();
                if (PathView.Instance != null)
                    PathView.Instance.RemovePaths();
                UIViewController.DeactivateUIView("PathView");
                UIViewController.DeactivateUIView("PositionView");
                UIViewController.DeactivateUIView("RoleView");
                ClientGameManager.Instance.gameObject.SetActive(false);
                UIViewController.ActivateUIView("ClientMainView");
                break;
        }
    }

    public void ClickSelect()
    {
        //Debug.Log("ClickSelect");

        SoundManager.Instance.PlaySoundEffect(SoundType.BUTTON_CLICK);

        switch (_state)
        {
            case RoleViewState.PATH:
            case RoleViewState.POSITION:
                if (PathView.Instance != null)
                    PathView.Instance.CanClick = false;
                YesNoAlert.Present("Ready?", "This will enter your choices and get you ready for battle!", SelectYes, SelectNo);
                break;
            case RoleViewState.PATH_SELECTED:
            case RoleViewState.POSITION_SELECTED:
                OffenseButton.Activate();
                DefenseButton.Activate();
                if (PositionView.Instance != null)
                    PositionView.Instance.RemovePositions();
                if (PathView.Instance != null)
                    PathView.Instance.RemovePaths();
                //Debug.Log("deactivating pathview");
                UIViewController.DeactivateUIView("PathView");
                UIViewController.DeactivateUIView("PositionView");
                PrepareSplashImage.Activate();
                PreparedSplashImage.Deactivate();
                SelectButton.Deactivate();
                _state = RoleViewState.ROLE;
                break;
        }
    }

    void SelectYes()
    {
        if (_state == RoleViewState.PATH)
        {
            if (PathView.Instance != null)
                PathView.Instance.SelectPath();
            _state = RoleViewState.PATH_SELECTED;
            PathView.Instance.TurnOffCollidersForAllPaths();
        }
        else
        {
            if (PositionView.Instance != null)
                PositionView.Instance.SelectPosition();
            _state = RoleViewState.POSITION_SELECTED;
        }
        SelectButton.Text = "CHANGE SELECTION";
        PreparedSplashImage.Activate();
        //Debug.Log(_status);
        /*
        if (_status == RoleViewStatus.PATH_SELECTED)
        {
            for (int i = 0; i < Avatar.Instance.Path.Points.Count; i++)
            {
                Debug.Log(Avatar.Instance.Path.Points[i].x + ", " + Avatar.Instance.Path.Points[i].y);
            }
        }
        */
        StartCoroutine(PostInfo());
    }

    void SelectNo()
    {
        if (PathView.Instance != null)
            PathView.Instance.CanClick = true;
    }

    void ActivateSelectButton()
    {
        if (_state == RoleViewState.PATH)
            SelectButton.Text = "CONFIRM PATH";
        else
            SelectButton.Text = "CONFIRM POSITION";
        SelectButton.Activate();
    }
    #endregion

    #region Coroutines
    IEnumerator PostInfo()
    {
        yield return StartCoroutine(OnlineManager.Instance.StartPieceInfoPostCoroutine());
    }

    IEnumerator CheckBattleStatus()
    {
        yield return StartCoroutine(OnlineManager.Instance.StartGetGame());

        if (OnlineManager.Instance.GameStatus == OnlineGameStatus.PREPARING)
        {
            _state = RoleViewState.ROLE;
            bool selectionAlreadyMade = false;
            if (Avatar.Instance.Role == PieceRole.OFFENSE && Avatar.Instance.Path != null && Avatar.Instance.Path.Points != null && Avatar.Instance.Path.Points.Count > 1)
            {
                _state = RoleViewState.PATH_SELECTED;
                SelectButton.Text = "CHANGE SELECTION";
                selectionAlreadyMade = true;
            }
            else if (Avatar.Instance.Role == PieceRole.DEFENSE && Avatar.Instance.Path != null && Avatar.Instance.Path.Points != null && Avatar.Instance.Path.Points.Count == 1)
            {
                _state = RoleViewState.POSITION_SELECTED;
                SelectButton.Text = "CHANGE SELECTION";
                selectionAlreadyMade = true;
            }
            //Debug.Log(selectionAlreadyMade);
            if (selectionAlreadyMade)
            {
                PrepareSplashImage.Deactivate();
                PreparedSplashImage.Activate();
                SelectButton.Activate();
                OffenseButton.Deactivate();
                DefenseButton.Deactivate();

                if (Avatar.Instance.Role == PieceRole.OFFENSE)
                {
                    UseCollidersForPaths = false;
                    UIViewController.ActivateUIView(PathView.Load());
                    PathView.Instance.ActivateExistingPath();
                }
                else
                {
                    UIViewController.ActivateUIView(PositionView.Load());
                    PositionView.Instance.ActivateExistingPosition();
                }
            }
            else
            {
                PrepareSplashImage.Activate();
                OffenseButton.Activate();
                DefenseButton.Activate();
            }

            // calculate time
            //Debug.Log(OnlineManager.Instance.GameData.scheduled_start);
            _nextBattleDateTime = DateTime.Parse(OnlineManager.Instance.GameData.scheduled_start);
            //Debug.Log(_nextBattleDateTime);
            SetTimeText();
            //Debug.Log(timeToNextBattle);

            TimerPanelImage.Activate();
            TimeText.Activate();
            RefreshButton.Activate();
            enabled = true;

            string lastBattleId = PlayerPrefs.GetString("LAST_GAME_VIEWED", "");
            BattleButton.Activate();
            //if (lastBattleId != null && lastBattleId != 
            //PlayerPrefs.SetString("LAST_GAME_VIEWED", OnlineManager.Instance.PreviousGameData.id);
        }
        else
        {
            OffenseButton.Deactivate();
            DefenseButton.Deactivate();
            SelectButton.Deactivate();
            PrepareSplashImage.Deactivate();
            if (Avatar.Instance.Color == TeamColor.RED)
                PreparedSplashImage.Image.sprite = RedBattleInProgressSprite;
            else
                PreparedSplashImage.Image.sprite = BlueBattleInProgressSprite;
            PreparedSplashImage.Activate();
        }
        BackButton.Activate();
    }

    IEnumerator RefreshBattleStatus()
    {
        yield return StartCoroutine(OnlineManager.Instance.StartGetGame());

        PathManager.Instance.Initialize();

        if (PathView.Instance != null)
            PathView.Instance.Refresh();
        if (PositionView.Instance != null)
            PositionView.Instance.Refresh();

        LoadingAlert.FinishLoading();
    }
    #endregion
}