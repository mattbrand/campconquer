using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using System.Collections;
using gametheory.UI;
using CampConquer;

public class FullLoginAlert : UIAlert 
{
    #region Public Vars
    public ExtendedInputField Username;
    public ExtendedInputField Password;

    public ExtendedText ErrorMessage;
    #endregion

    #region Private Vars
    static FullLoginAlert _instance = null;
    EventSystem _eventSystem;
    string _username;
    string _password;
    #endregion

    #region Unity Methods
    void Update()
    {
        if (OnlineManager.Token != null && OnlineManager.Token != "")
        {
            Deactivate();
            LoginAlert.Present();
        }

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
            _instance = Load("Alerts/FullLoginAlert", UIAlertController.Instance.CanvasRect) as FullLoginAlert;
        }
    }

    public void ClickSignIn()
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.BUTTON_CLICK);
        LoadingAlert.Present();
        StartCoroutine(SignIn());
    }

    IEnumerator SignIn()
    {
        OnlineManager.Instance.SetServer();

        yield return StartCoroutine(OnlineManager.Instance.StartLogin(_username, _password));

        //Debug.Log(OnlineManager.Token);

        if (OnlineManager.Token != null && OnlineManager.Token != "")
        {
            yield return StartCoroutine(OnlineManager.Instance.StartGetPlayer(OnlineManager._playerID));
            
            if (OnlineManager.Instance.PlayerReponseData.player.gamemaster)
            {
                GameManager.Client = false;
                SceneManager.LoadScene("Moderator");
            }

            if (!OnlineManager.Instance.GetRequestFailure)
            {
                if (OnlineManager.Instance.PlayerID == null || OnlineManager.Instance.PlayerReponseData.status != "ok")
                {
                    LoadingAlert.FinishLoading();
                    HTTPAlert.Present("Login Error", OnlineManager.Instance.Error, null, null, true);
                }
                else
                {
                    yield return StartCoroutine(OnlineManager.Instance.StartGetGame());
                    yield return StartCoroutine(OnlineManager.Instance.StartGetGear());
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