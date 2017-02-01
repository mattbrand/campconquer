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
    const string TIP_1 = "Choose a position to set up your player for the battle.";
    const string TIP_2 = "Make sure you have purchased water balloons from the store before the next battle starts. Without balloons you won't be able to fight!";
    const float TIMER_HIGH_Y = 144.0f;
    #endregion

    #region Public Vars
    public RectTransform TimeContainer;
    public ExtendedText TimeText;
    public ExtendedText TimeHeaderText;
    public ExtendedText TipText;
    public ExtendedButton SelectButton;
    public ExtendedButton RefreshButton;
    public ExtendedButton BackButton;
    public ExtendedButton PrepareButton;
    public ExtendedImage PrepareSplashImage;
    public ExtendedImage PreparedSplashImage;
    public ExtendedImage BattleCompleteImage;
    public ExtendedImage TipBGImage;
    public ExtendedImage TipHeaderImage;
    public ExtendedImage TimeBG;
    public Sprite SelectButtonSprite;
    public Sprite ChangePositionButtonSprite;
    public RoleViewState State;
    public static RoleView Instance;
    #endregion

    #region Private Vars
    DateTime _nextBattleDateTime;
    float _originalTimerY;
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

            _originalTimerY = TimeContainer.anchoredPosition.y;
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

        if (PositionView.Instance != null)
            PositionView.Instance.RemovePositions();
        if (PathView.Instance != null)
            PathView.Instance.RemovePaths();
        UIViewController.DeactivateUIView(ATTACK_SETUP_VIEW);
        UIViewController.DeactivateUIView(DEFENSE_SETUP_VIEW);
        UIViewController.DeactivateUIView(ROLE_VIEW);
        ClientGameManager.Instance.gameObject.SetActive(false);
        UIViewController.ActivateUIView("ClientMainView");

        /*
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
                PrepareSplashImage.Activate();
                State = RoleViewState.ROLE;
                SelectButton.Deactivate();
                break;
            case RoleViewState.POSITION:
                if (PositionView.Instance != null)
                    PositionView.Instance.RemovePositions();
				UIViewController.DeactivateUIView(DEFENSE_SETUP_VIEW);
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
        */
    }

    public void ClickSelect()
    {
        //Debug.Log("ClickSelect");

        SoundManager.Instance.PlaySoundEffect(SoundType.BUTTON_CLICK);

        switch (State)
        {
		    case RoleViewState.PATH:
            case RoleViewState.POSITION:
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
                DeactivateTip();
                ActivateTimer();
                MoveTimerUp();
                SelectButton.ButtonIconImage.sprite = ChangePositionButtonSprite;
                StartCoroutine(PostInfo());
                break;
            case RoleViewState.PATH_SELECTED:
            case RoleViewState.POSITION_SELECTED:
                PreparedSplashImage.Deactivate();
                PreparedSplashImage.Deactivate();
                PathItem.CanClick = true;
			    PositionItem.CanClick = true;
                State = RoleViewState.ROLE;
                ActivateTip(0);
                SelectButton.Deactivate();
                DeactivateTimer();
                break;
        }
    }

    public void ClickPrepare()
    {
        PrepareSplashImage.Deactivate();
        PrepareButton.Deactivate();
        DeactivateTimer();
        ActivateTip(0);

        UIViewController.ActivateUIView(PathView.Load());
        UIViewController.ActivateUIView(PositionView.Load());
    }

    public void ActivateTip(int tipNumber)
    {
        TipBGImage.Activate();
        TipHeaderImage.Activate();
        TipText.Activate();

        if (tipNumber == 0)
            TipText.Text = TIP_1;
        else
            TipText.Text = TIP_2;
    }

    void DeactivateTip()
    {
        TipBGImage.Deactivate();
        TipHeaderImage.Deactivate();
        TipText.Deactivate();
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

    public void ActivateSelectButton()
    {
        SelectButton.ButtonIconImage.sprite = SelectButtonSprite;
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

    void ActivateTimer()
    {
        TimeBG.Activate();
        TimeText.Activate();
        TimeHeaderText.Activate();
    }

    void DeactivateTimer()
    {
        TimeBG.Deactivate();
        TimeText.Deactivate();
        TimeHeaderText.Deactivate();
    }

    void MoveTimerUp()
    {
        //Debug.Log(TimeContainer.rect);
        TimeContainer.anchoredPosition = new Vector2(TimeContainer.anchoredPosition.x, TIMER_HIGH_Y);
    }

    void MoveTimerToOriginalPlace()
    {
        TimeContainer.anchoredPosition = new Vector2(TimeContainer.anchoredPosition.x, _originalTimerY);
    }

    public void ClickTutorial()
    {
        TutorialAlert.Present(TutorialAlertType.BATTLE);
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

        PathManager.Instance.Initialize();

        if (OnlineManager.Instance.GameStatus == OnlineGameStatus.PREPARING)
        {
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
                PreparedSplashImage.Activate();
                SelectButton.ButtonIconImage.sprite = ChangePositionButtonSprite;
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

                ActivateTimer();
                MoveTimerUp();
            }
            else
            {
				SelectButton.Deactivate();

                PrepareSplashImage.Activate();
                PrepareButton.Activate();

                ActivateTimer();
            }

            // calculate time
            _nextBattleDateTime = DateTime.Parse(OnlineManager.Instance.GameData.scheduled_start);
            //Debug.Log(_nextBattleDateTime);
            SetTimeText();
            //Debug.Log(timeToNextBattle);

            RefreshButton.Activate();
            enabled = true;
        }
        else
        {
            SelectButton.Deactivate();
            PrepareSplashImage.Deactivate();
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