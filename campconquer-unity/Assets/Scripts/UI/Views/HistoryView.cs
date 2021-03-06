﻿using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using System;
using System.Collections;
using gametheory.UI;

public class HistoryView : UIView
{
    #region Enums
    enum HistoryViewState { NONE = 0, FILL, REDUCE };
    #endregion

    #region Constants
    const int STEPS_MAX = 10000;
    const int STEP_FILL_RATE = 250;
    const int MIN_STEPS = 10;
    const int COINS_MAX = 1000;
    const int COINS_SEMI_FULL = 500;
    const int COINS_SEMI_EMPTY = 1;
    const float MINUTES_MAX = 60.0f;
    const string LAST_VIEWED_BATTLE_KEY = "LastViewedBattle";
    #endregion

    #region Public Vars
    public ExtendedImage BannerImage;
    public ExtendedImage LeaderboardTitleImage;
    public ExtendedImage LeadTitleImage;
    public ExtendedImage ActivityFill;
    public ExtendedImage Chest;

    public ExtendedButton CoinsClaimButton;
    public ExtendedButton ActivityClaimButton;
    public ExtendedButton BattleButton;

    public ExtendedText StepsWalked;
    public ExtendedText Coins;
    public ExtendedText ActivityeMin;
    public ExtendedText RedWins;
    public ExtendedText BlueWins;
    public ExtendedText AMVP;
    public ExtendedText DMVP;
    public ExtendedText LastSynced;
    //public ExtendedText ClaimGemButtonText;
    //public ExtendedText ClaimCoinsButtonText;
    public ExtendedText GemCountText;

    public Sprite BlueLeadTitle;
    public Sprite TieTitle;
    public Sprite ChestEmpty;
    public Sprite ChestSemiEmpty;
    public Sprite ChestSemiFull;
    public Sprite ChestFull;

    //public Text CoinsClaimText;
    //public Text GemClaimText;

    public CoinsGemsView CoinsGemsView;
    #endregion

    #region Private Vars
    HistoryViewState _state;
    int _stepsShown;
    int _activityMinShown;
    #endregion

    #region Unity Methods
    void Update()
    {
        bool canDisableSteps = true;
        bool canDisableMins = true;
        switch (_state)
        {
            case HistoryViewState.FILL:
                // fill steps
                if (_stepsShown < Avatar.Instance.Steps)
                {
                    _stepsShown += STEP_FILL_RATE;

                    if (_stepsShown >= Avatar.Instance.Steps)
                    {
                        _stepsShown = Avatar.Instance.Steps;
                    }
                    else
                    {
                        canDisableSteps = false;
                        //Debug.Log("can disable for steps");
                    }

                    SetCoinsText();
                    SetChestSprite();
                }
                // fill activity meter
                //Debug.Log(_activityMinShown);
                //Debug.Log(_activityMinShown + " / " + Avatar.Instance.ActiveMins + " max = " + MINUTES_MAX);
                if (_activityMinShown < Avatar.Instance.ActiveMins && _activityMinShown < MINUTES_MAX)
                {
                    _activityMinShown++;
                    //Debug.Log(_activityMinShown + " / " + Avatar.Instance.ActiveMins);
                    if (_activityMinShown >= Avatar.Instance.ActiveMins)
                    {
                        _activityMinShown = Avatar.Instance.ActiveMins;
                    }
                    else
                        canDisableMins = false;

                    SetActivityFill();
                    SetActivityText();
                    //Debug.Log("canDisableMins = " + canDisableMins);
                }

                // check if update is done
                if (canDisableSteps && canDisableMins)
                {
                    //Debug.Log("disabling!");
                    if (_stepsShown > MIN_STEPS)
                    {
                        CoinsClaimButton.Enable();
                        //CoinsClaimText.color = Color.white;
                    }
                    _state = HistoryViewState.NONE;
                    SoundManager.Instance.StopCoinTallySound();
                    enabled = false;
                }
                break;
            case HistoryViewState.REDUCE:
                // reduce steps
                if (_stepsShown > Avatar.Instance.Steps)
                {
                    _stepsShown -= STEP_FILL_RATE;

                    if (_stepsShown <= Avatar.Instance.Steps)
                    {
                        _stepsShown = Avatar.Instance.Steps;
                        _state = HistoryViewState.NONE;
                    }
                    else
                        canDisableSteps = false;

                    SetStepsWalkedText();
                    SetCoinsText();
                    SetChestSprite();
                }

                // check if update is done
                if (canDisableSteps)
                {
                    _state = HistoryViewState.NONE;
                    enabled = false;
                }
                break;
        }
    }
    #endregion

    #region Overloaded Methods
    protected override void OnActivate()
    {
        base.OnActivate();

        CoinsGemsView.SetBinding();

        SetStepsWalkedText();
        _stepsShown = 0;
        _activityMinShown = 0;
        _state = HistoryViewState.FILL;
        enabled = true;

        CoinsClaimButton.Disable();
        ActivityClaimButton.Disable();

        SetChestSprite();
        SetCoinsText();

        string syncedDateTime = OnlineManager.Instance.PlayerReponseData.player.activities_synced_at;
        //Debug.Log(OnlineManager.Instance.PlayerReponseData.player.activities_synced_at);
        //Debug.Log(syncedDateTime);
        if (syncedDateTime == null || syncedDateTime == "")
            LastSynced.Text = "NA";
        else
            LastSynced.Text = Convert.ToDateTime(syncedDateTime).ToString();

        StartCoroutine(LoadingFinishedJSON());

        if (!PlayerPrefs.HasKey("HistoryViewTutorial") || PlayerPrefs.GetInt("HistoryViewTutorial") != 1)
        {
            ClickTutorial();
            PlayerPrefs.SetInt("HistoryViewTutorial", 1);
        }
    }

    protected override void OnDeactivate()
    {
        base.OnDeactivate();
    }
    #endregion

    #region Methods
    public static HistoryView Load()
    {
        HistoryView view = UIView.Load("Views/HistoryView", OverriddenViewController.Instance.transform) as HistoryView;
        view.name = "HistoryView";
        return view;
    }
    #endregion

    #region UI Methods
    public void ClickBack()
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.BUTTON_CLICK);

        UIViewController.DeactivateUIView("HistoryView");
        UIViewController.DeactivateUIView("BackgroundView");
        UIViewController.ActivateUIView("ClientMainView");
    }

    void SetActivityFill()
    {
        ActivityFill.Image.fillAmount = (float)_activityMinShown / MINUTES_MAX;
    }

    void SetCoinsText()
    {
        Coins.Text = (_stepsShown / 10).ToString() + " Coins";
    }

    void SetActivityText()
    {
        ActivityeMin.Text = ((int)MINUTES_MAX - (int)_activityMinShown).ToString() + " minutes left";
    }

    void SetStepsWalkedText()
    {
        StepsWalked.Text = Avatar.Instance.Steps.ToString() + " / " + STEPS_MAX.ToString();
    }

    public void ClickClaimCoins()
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.BUTTON_CLICK);

        CoinsClaimButton.Disable();
        StartCoroutine(ClaimCoins());
    }

    public void ClickClaimExercise()
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.BUTTON_CLICK);

        ActivityClaimButton.Disable();
        StartCoroutine(ClaimExercise());
    }

    void SetChestSprite()
    {
        int coins = _stepsShown / 10;
        if (coins >= COINS_MAX)
        {
            Chest.Image.sprite = ChestFull;
        }
        else if (coins >= COINS_SEMI_FULL)
        {
            Chest.Image.sprite = ChestSemiFull;
        }
        else if (coins >= COINS_SEMI_EMPTY)
        {
            Chest.Image.sprite = ChestSemiEmpty;
        }
        else
        {
            Chest.Image.sprite = ChestEmpty;
        }
    }

    public void ClickBattleButton()
    {
        GameManager.Client = true;
        //Debug.Log("local = " + OnlineManager.Local + " staging = " + OnlineManager.Staging);
        GameManager.ClientColor = Avatar.Instance.Color;
        SceneManager.LoadScene("Moderator");
    }

    public void ClickTutorial()
    {
        TutorialAlert.Present(TutorialAlertType.REWARDS);
    }

    public void ClickRefresh()
    {
        LoadingAlert.Present();

        StartCoroutine(LoadingFinishedJSON());
    }
    #endregion

    #region Coroutines
    IEnumerator LoadingFinishedJSON()
    {
        // show loader and get the season
        LoadingAlert.Present();
        yield return StartCoroutine(OnlineManager.Instance.StartGetSeason());
        yield return StartCoroutine(OnlineManager.Instance.StartGetPreviousGame());

        // remove loader
        LoadingAlert.FinishLoading();

        // set team data
        int blueWins = 0;
        int redWins = 0;
        for (int i = 0; i < OnlineManager.Instance.SeasonSyncData.team_summaries.Count; i++)
        {
            TeamSummaryData teamData = OnlineManager.Instance.SeasonSyncData.team_summaries[i];
            if (teamData.team_name == "blue")
            {
                blueWins = teamData.captures;
            }
            else
            {
                redWins = teamData.captures;
            }
        }
        RedWins.Text = redWins.ToString();
        BlueWins.Text = blueWins.ToString();

        // red in the lead
        if (redWins > blueWins)
        {
            BannerImage.Image.color = Colors.RedBannerColor;
        }
        // blue in the lead
        else if (blueWins > redWins)
        {
            LeadTitleImage.Image.sprite = BlueLeadTitle;
            BannerImage.Image.color = Colors.BlueBannerColor;
        }
        // tie
        else if (blueWins == redWins)
        {
            LeadTitleImage.Image.sprite = TieTitle;
            BannerImage.Image.color = Colors.PurpleBannerColor;
        }
        BannerImage.Activate();
        LeadTitleImage.Activate();
        //LeaderboardTitleImage.Activate();

        // set player data
        for (int i = 0; i < OnlineManager.Instance.SeasonSyncData.player_summaries.Count; i++)
        {
            PlayerSummaryData playerData = OnlineManager.Instance.SeasonSyncData.player_summaries[i];
            if (OnlineManager.Instance.PlayerID == playerData.player_id.ToString())
            {
                AMVP.Text = playerData.attack_mvp.ToString();
                DMVP.Text = playerData.defend_mvp.ToString();

            }
        }
        if (AMVP.Text == "")
            AMVP.Text = "0";
        if (DMVP.Text == "")
            DMVP.Text = "0";

        GemCountText.Text = "x " + Avatar.Instance.GemsAvailable;
        if (Avatar.Instance.GemsAvailable > 0)
        {
            if (Avatar.Instance.GemsAvailable > 1)
                ActivityClaimButton.ButtonIconImage.sprite = AssetLookUp.Instance.ClaimGemsButton;

            ActivityClaimButton.Enable();
        }

        // play fill sound effect
        if (_stepsShown < Avatar.Instance.Steps || _activityMinShown < Avatar.Instance.ActiveMins)
        {
            SoundManager.Instance.PlaySoundEffect(SoundType.COINS_TALLY);
        }

        // activate battle button if there is a battle to watch
        if (OnlineManager.Instance.PreviousGameData != null && OnlineManager.Instance.PreviousGameData.id != "")
        {
            BattleButton.Activate();
        }
    }

    IEnumerator ClaimCoins()
    {
        yield return StartCoroutine(OnlineManager.Instance.StartRedeemSteps());

        _state = HistoryViewState.REDUCE;
        enabled = true;
        DefaultAlert.Present("Hooray!", "You got " + OnlineManager.Instance.CoinsClaimed + " coins!");
    }

    IEnumerator ClaimExercise()
    {
        int beforeGems = Avatar.Instance.Gems;

        yield return StartCoroutine(OnlineManager.Instance.StartRedeemActiveMinutes());

        int gemsClaimed = Avatar.Instance.Gems - beforeGems;

        ActivityClaimButton.ButtonIconImage.sprite = AssetLookUp.Instance.ClaimedButton;

        string message = "You got ";
        if (gemsClaimed == 1)
            message += "a gem!";
        else
            message += gemsClaimed.ToString() + " gems!";
        DefaultAlert.Present("Hooray!", message);
    }
    #endregion
}
