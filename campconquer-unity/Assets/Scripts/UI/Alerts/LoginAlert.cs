using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using System.Collections;
using gametheory.UI;
using CampConquer;

public class LoginAlert : UIAlert 
{
    #region Private Vars
    static LoginAlert _instance = null;
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
        StartCoroutine(SignIn());
    }

    IEnumerator SignIn()
    {
        OnlineManager.Instance.SetServer();

        if (OnlineManager.Token != null && OnlineManager.Token != "")
        {
            yield return StartCoroutine(OnlineManager.Instance.StartGetPlayerFromWeb());
            
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
    #endregion
}