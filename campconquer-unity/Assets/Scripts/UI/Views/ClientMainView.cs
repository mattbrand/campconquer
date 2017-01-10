using System.Collections;
using gametheory.UI;
using CampConquer;

public class ClientMainView : UIView 
{
    #region Constants
    const string VERSION = "1.1";
    #endregion

    #region Public Vars
    public ExtendedInputField UserIdInput;

    public ExtendedText VersionText;

    public MenuButton BattleButton;
    public MenuButton StoreButton;
    public MenuButton StatsButton;
    public MenuButton SettingsButton;
    #endregion

    #region Private Vars
    bool _loggedIn;
    bool _music;
    #endregion

    #region Overridden Methods
    protected override void OnActivate()
    {
        base.OnActivate();

        if (!_loggedIn && !GameManager.Client)
        {
            _loggedIn = true;
            LoginAlert.Present();
        }
        else if (GameManager.Client)
        {
            LoadingAlert.Present();
            OnlineManager.Instance.SetServer(OnlineManager.Local, OnlineManager.Staging, OnlineManager.Production);
            StartCoroutine(LogBackIn());
        }

        BattleButton.Reset();
        StoreButton.Reset();
        StatsButton.Reset();
        SettingsButton.Reset();

        if (!_music)
        {
            _music = true;
            SoundManager.Instance.StartMenuMusic();
        }

        VersionText.Text = "Version " + VERSION;
    }
    #endregion

    #region UI Methods
    public void ClickStatsButton()
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.BUTTON_CLICK);
        UIViewController.DeactivateUIView("ClientMainView");
        UIViewController.ActivateUIView(BackgroundView.Load());
        UIViewController.ActivateUIView(HistoryView.Load());
    }

    public void ClickStoreButton()
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.BUTTON_CLICK);
        UIViewController.DeactivateUIView("ClientMainView");
        UIViewController.ActivateUIView(BackgroundView.Load());
        UIViewController.ActivateUIView(AvatarView.Load());
        AvatarView.Instance.SetState(AvatarViewState.MAIN);
        UIViewController.ActivateUIView(GearEquipView.Load());
        UIViewController.ActivateUIView(AmmoBeltView.Load());
        UIViewController.ActivateUIView(CoinsGemsView.Load());
    }

    public void ClickBattleButton()
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.BUTTON_CLICK);
        UIViewController.DeactivateUIView("ClientMainView");
        UIViewController.ActivateUIView(RoleView.Load());
        ClientGameManager.Instance.gameObject.SetActive(true);
    }

    public void ClickSettingsButton()
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.BUTTON_CLICK);
        UIViewController.ActivateUIView(SettingsView.Load());
    }
    #endregion

    #region Methods
    IEnumerator LogBackIn()
    {
        yield return OnlineManager.Instance.StartGetPlayer(OnlineManager._playerID);
        yield return StartCoroutine(OnlineManager.Instance.StartGetGear());
        yield return StartCoroutine(OnlineManager.Instance.StartGetGame());
        Database.Instance.BuildAllData();
        Database.Instance.BuildGearList();
        PathManager.Instance.Initialize();

        LoadingAlert.FinishLoading();
    }
    #endregion
}