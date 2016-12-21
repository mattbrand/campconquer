using UnityEngine.UI;
using gametheory.UI;
using System;

public class HTTPAlert : UIAlert 
{
    #region Public Vars
    public Text TitleText;
    public Text MessageText;
    #endregion

    #region Private Vars
    static HTTPAlert _instance = null;
    #endregion

    #region Overriden Methods
    protected override void OnDeactivate()
    {
        base.OnDeactivate();
        _instance = null;
    }
    #endregion

    #region Methods
    public static void Present(string title, string message, Action confirmCallback = null, Action cancelCallback = null, bool showClose = false, string confirmText = "")
    {
        GetInstance();

        _instance.TitleText.text = title;
        _instance.MessageText.text = message;

        UIAlertController.Instance.PresentAlert(_instance);
    }


    static void GetInstance()
    {
        if (_instance == null)
        {
            _instance = Load("Alerts/HTTPAlert", UIAlertController.Instance.CanvasRect) as HTTPAlert;
        }
    }

    public void Close()
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.BUTTON_CLICK);

        Deactivate();
    }
    #endregion
}