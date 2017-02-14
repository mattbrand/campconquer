using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using System.Collections;
using gametheory.UI;
using CampConquer;

public class LoginAlert : UIAlert 
{
    #region Public Vars
    public ExtendedInputField Username;
    public ExtendedInputField Password;

    public ExtendedToggle LocalToggle;
    public ExtendedToggle StagingToggle;

    public ExtendedText ErrorMessage;
    #endregion

    #region Private Vars
    static LoginAlert _instance = null;
    EventSystem _eventSystem;
    string _username;
    string _password;
    bool _local;
    bool _staging;
    bool _production;
    #endregion

    #region Unity Methods
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Tab))
        {
            if (Username.InputField.isFocused)
                Password.InputField.OnPointerClick(new PointerEventData(_eventSystem));
            else
                Username.InputField.OnPointerClick(new PointerEventData(_eventSystem));
        }

        if (Input.GetKeyDown(KeyCode.Return))
        {
            if (_username != "" && _password != "")
                ClickSignIn();
        }
    }
    #endregion

    #region Overridden Methods
    protected override void OnInit()
    {
        base.OnInit();

        _local = true;
        _staging = false;
        _production = false;
        _username = "";
        _password = "";
        _eventSystem = EventSystem.current;
    }

    protected override void OnActivate()
    {
        base.OnActivate();

        Username.InputField.OnPointerClick(new PointerEventData(_eventSystem));
    }
    #endregion

    #region Methods
    public static void Present()
    {
        GetInstance();
        UIAlertController.Instance.PresentAlert(_instance);
    }

    static void GetInstance()
    {
        if (_instance == null)
        {
            _instance = Load("Alerts/LoginAlert", UIAlertController.Instance.CanvasRect) as LoginAlert;
        }
    }

    public void ClickSignIn()
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.BUTTON_CLICK);

        LoadingAlert.Present();

        OnlineManager.Local = LocalToggle.Toggle.isOn;
        OnlineManager.Staging = StagingToggle.Toggle.isOn;
        StartCoroutine(SignIn());

        /*
        if (_username != "" && _password != "")
        {
            OnlineManager.Local = LocalToggle.Toggle.isOn;
            OnlineManager.Staging = StagingToggle.Toggle.isOn;
            StartCoroutine(SignIn());
        }
        else
        {
            LoadingAlert.FinishLoading();
            ErrorMessage.Activate();
        }
        */
    }

    IEnumerator SignIn()
    {
        OnlineManager.Instance.SetServer(LocalToggle.Toggle.isOn, StagingToggle.Toggle.isOn, _production);
        //Debug.Log("1");
#if UNITY_EDITOR
        yield return StartCoroutine(OnlineManager.Instance.StartLogin(_username, _password));
#else
        //yield return StartCoroutine(OnlineManager.Instance.StartLoginFromWeb()); 
#endif
        //Debug.Log("OnlineManager.Token = " + OnlineManager.Token);
        if (OnlineManager.Token != null && OnlineManager.Token != "")
        {
            //Debug.Log("token = " + OnlineManager.Token);
            //Debug.Log("2");
#if UNITY_EDITOR
            yield return StartCoroutine(OnlineManager.Instance.StartGetPlayer(OnlineManager._playerID));
#else
            yield return StartCoroutine(OnlineManager.Instance.StartGetPlayerFromWeb());
#endif

            //Debug.Log(OnlineManager.Instance.PlayerReponseData);

            //Debug.Log(OnlineManager.Instance.PlayerReponseData.player);

            if (OnlineManager.Instance.PlayerReponseData.player.gamemaster)
            {
                GameManager.Client = false;
                SceneManager.LoadScene("Moderator");
            }

            //Debug.Log("test");

            //Debug.Log(OnlineManager.Instance.PlayerReponseData.status);

            //Debug.Log("3");

            if (!OnlineManager.Instance.GetRequestFailure)
            {
                if (OnlineManager.Instance.PlayerID == null || OnlineManager.Instance.PlayerReponseData.status != "ok")
                {
                    //Debug.Log("4");
                    LoadingAlert.FinishLoading();
                    HTTPAlert.Present("Login Error", OnlineManager.Instance.Error, null, null, true);
                }
                else
                {
                    //Debug.Log("5");
                    yield return StartCoroutine(OnlineManager.Instance.StartGetGame());
                    yield return StartCoroutine(OnlineManager.Instance.StartGetGear());
                    //Debug.Log("going to build lists - body type = " + Avatar.Instance.BodyType);
                    Database.Instance.BuildAllData();
                    Database.Instance.BuildGearList();
                    PathManager.Instance.Initialize();

                    if (!Avatar.Instance.Embodied)
                    {
                        UIViewController.ActivateUIView(AvatarCreationView.Load());
                        UIViewController.ActivateUIView(AvatarStatsView.Load());
                    }

                    LoadingAlert.FinishLoading();
                    Deactivate();
                }
            }
        }
    }

    public void OnToggleLocal()
    {
        StagingToggle.Toggle.isOn = !LocalToggle.Toggle.isOn;
    }

    public void OnToggleStaging()
    {
        LocalToggle.Toggle.isOn = !StagingToggle.Toggle.isOn;
    }

    public void EndEditUsername(InputField username)
    {
        _username = username.text;
    }

    public void EndEditPassword(InputField password)
    {
        _password = password.text;
    }
    #endregion
}