using UnityEngine;
using UnityEngine.SceneManagement;
using System;
using System.Collections;
using gametheory.UI;
using CampConquer;

public class RoleView : UIView 
{
    #region Enums
    public enum RoleViewState { ROLE = 0, PATH, POSITION, PATH_SELECTED, POSITION_SELECTED };
    #endregion

	#region Constants
	const string DEFENSE_SETUP_VIEW = "PositionView";
	const string ATTACK_SETUP_VIEW = "PathView";
	const string ROLE_VIEW = "RoleView";
	#endregion

    #region Public Vars
    public ExtendedText TimeText;
    public ExtendedButton OffenseButton;
    public ExtendedButton DefenseButton;
    public ExtendedButton SelectButton;
    public ExtendedButton RefreshButton;
    public ExtendedButton BackButton;
    public ExtendedImage PrepareSplashImage;
    public ExtendedImage PreparedSplashImage;
    public ExtendedImage TimerPanelImage;
    public ExtendedImage BattleCompleteImage;
    public Sprite RedBattleInProgressSprite;
    public Sprite BlueBattleInProgressSprite;
    public Sprite BluePreparedSprite;
    public Sprite BluePrepareSprite;
    public Sprite BlueBattleCompleteSprite;
    public RoleViewState State;
    public static RoleView Instance;
    #endregion

    #region Private Vars
    DateTime _nextBattleDateTime;
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

        if (Instance == null)
        {
            Instance = this;
        }
        else
        {
            Destroy(gameObject);
        }
    }

    protected override void OnActivate()
    {
        base.OnActivate();

        StartCoroutine(CheckBattleStatus());
    }

    protected override void OnCleanUp()
    {
        base.OnCleanUp();
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
		RoleView view = UIView.Load("Views/"+ROLE_VIEW, OverriddenViewController.Instance.transform) as RoleView;
		view.name = ROLE_VIEW;
        return view;
    }

    public void ClickRole(int roleIndex)
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.BUTTON_CLICK);

        Avatar.Instance.Role = (PieceRole)roleIndex;
        if ((PieceRole)roleIndex == PieceRole.OFFENSE)
        {
            UIViewController.ActivateUIView(PathView.Load());
            State = RoleViewState.PATH;
        }
        else
        {
            UIViewController.ActivateUIView(PositionView.Load());
            State = RoleViewState.POSITION;
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

        switch (State)
        {
            case RoleViewState.ROLE:
                if (PositionView.Instance != null)
                    PositionView.Instance.RemovePositions();
                if (PathView.Instance != null)
                    PathView.Instance.RemovePaths();
				UIViewController.DeactivateUIView(ATTACK_SETUP_VIEW);
				UIViewController.DeactivateUIView(DEFENSE_SETUP_VIEW);
				UIViewController.DeactivateUIView(ROLE_VIEW);
                ClientGameManager.Instance.gameObject.SetActive(false);
                UIViewController.ActivateUIView("ClientMainView");
                break;
            case RoleViewState.PATH:
                if (PathView.Instance != null)
                    PathView.Instance.RemovePaths();
				UIViewController.DeactivateUIView(ATTACK_SETUP_VIEW);
                OffenseButton.Activate();
                DefenseButton.Activate();
                PrepareSplashImage.Activate();
                State = RoleViewState.ROLE;
                SelectButton.Deactivate();
                break;
            case RoleViewState.POSITION:
                if (PositionView.Instance != null)
                    PositionView.Instance.RemovePositions();
				UIViewController.DeactivateUIView(DEFENSE_SETUP_VIEW);
                OffenseButton.Activate();
                DefenseButton.Activate();
                PrepareSplashImage.Activate();
                State = RoleViewState.ROLE;
                SelectButton.Deactivate();
                break;
            case RoleViewState.PATH_SELECTED:
            case RoleViewState.POSITION_SELECTED:
                if (PositionView.Instance != null)
                    PositionView.Instance.RemovePositions();
                if (PathView.Instance != null)
                    PathView.Instance.RemovePaths();
				UIViewController.DeactivateUIView(ATTACK_SETUP_VIEW);
				UIViewController.DeactivateUIView(DEFENSE_SETUP_VIEW);
				UIViewController.DeactivateUIView(ROLE_VIEW);
                ClientGameManager.Instance.gameObject.SetActive(false);
                UIViewController.ActivateUIView("ClientMainView");
                break;
        }
    }

    public void ClickSelect()
    {
        //Debug.Log("ClickSelect");

        SoundManager.Instance.PlaySoundEffect(SoundType.BUTTON_CLICK);

        switch (State)
        {
		    case RoleViewState.PATH:
            case RoleViewState.POSITION:
                if (PathView.Instance != null)
                    PathView.Instance.CanClick = false;
                YesNoAlert.Present("Ready?", "This will enter your choices and get you ready for battle!", SelectYes, SelectNo);
                break;
            case RoleViewState.PATH_SELECTED:
            case RoleViewState.POSITION_SELECTED:
			    //SelectButton.Text = CONFIRM_TEXT;
			    PreparedSplashImage.Deactivate();
                PathItem.CanClick = true;
			    PositionItem.CanClick = true;
                State = RoleViewState.ROLE;
                break;
        }
    }

    void SelectYes()
    {
        //Debug.Log(State);

        if (State == RoleViewState.PATH)
        {
            if (PathView.Instance != null)
                PathView.Instance.SelectPath();
            State = RoleViewState.PATH_SELECTED;
            Avatar.Instance.Role = PieceRole.OFFENSE;
        }
        else
        {
            if (PositionView.Instance != null)
                PositionView.Instance.SelectPosition();
            State = RoleViewState.POSITION_SELECTED;
            Avatar.Instance.Role = PieceRole.DEFENSE;
        }

        PreparedSplashImage.Activate();

		DisablePathAndPositionSelection();

        StartCoroutine(PostInfo());
    }

    void SelectNo()
    {
    }

    void ActivateSelectButton()
    {
        if (State == RoleViewState.PATH)
            SelectButton.Text = "CONFIRM PATH";
        else
            SelectButton.Text = "CONFIRM POSITION";
        SelectButton.Activate();
    }

    public void UnselectPositions()
    {
        PositionView.Instance.UnselectPositions();
    }

    public void UnselectPaths()
    {
        PathView.Instance.UnselectPaths();
    }

	void DisablePathAndPositionSelection()
	{
        // disable Path
        PathItem.CanClick = false;
		// disable Positions
		PositionItem.CanClick = false;
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
            OffenseButton.Deactivate();
            DefenseButton.Deactivate();

            State = RoleViewState.ROLE;
            bool selectionAlreadyMade = false;
            //Debug.Log(Avatar.Instance.Role + " " + Avatar.Instance.Path + " " + Avatar.Instance.Path.Points + " " + Avatar.Instance.Path.Points.Count);
            if (Avatar.Instance.Role == PieceRole.OFFENSE && Avatar.Instance.Path != null && Avatar.Instance.Path.Points != null && Avatar.Instance.Path.Points.Count > 1)
            {
                State = RoleViewState.PATH_SELECTED;
                selectionAlreadyMade = true;
            }
            else if (Avatar.Instance.Role == PieceRole.DEFENSE && Avatar.Instance.Path != null && Avatar.Instance.Path.Points != null && Avatar.Instance.Path.Points.Count == 1)
            {
                State = RoleViewState.POSITION_SELECTED;
                selectionAlreadyMade = true;
            }
            //Debug.Log(selectionAlreadyMade);
            if (selectionAlreadyMade)
            {
                PrepareSplashImage.Deactivate();
                PreparedSplashImage.Activate();
                SelectButton.Activate();

                UIViewController.ActivateUIView(PathView.Load());
                UIViewController.ActivateUIView(PositionView.Load());

                if (State == RoleViewState.PATH_SELECTED)
                {
                    UnselectPositions();
                    PathView.Instance.ActivateExistingPath();
                }
                else
                {
                    UnselectPaths();
                    PositionView.Instance.ActivateExistingPosition();
                }

				DisablePathAndPositionSelection();
            }
            else
            {
				SelectButton.Deactivate();
				UIViewController.ActivateUIView(PathView.Load());
				UIViewController.ActivateUIView(PositionView.Load());
            }

            // calculate time
            _nextBattleDateTime = DateTime.Parse(OnlineManager.Instance.GameData.scheduled_start);
            //Debug.Log(_nextBattleDateTime);
            SetTimeText();
            //Debug.Log(timeToNextBattle);

            TimerPanelImage.Activate();
            TimeText.Activate();
            RefreshButton.Activate();
            enabled = true;
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