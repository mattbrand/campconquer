using UnityEngine;
using UnityEngine.UI;
using gametheory.UI;
using System;
using System.Collections.Generic;

public class NoButtonAlert : UIAlert
{
    #region Public Vars
    public Text TitleText;
    public Text MessageText;

    public static bool IsOpen;
    #endregion

    #region Private Vars
    static NoButtonAlert _instance = null;
    #endregion

    #region Overriden Methods
    protected override void OnInit()
    {
        base.OnInit();

        IsOpen = false;
    }
    protected override void OnDeactivate()
    {
        base.OnDeactivate();
        _instance = null;
    }
    #endregion

    #region Methods
    public static void Present(string title, string message)
    {
        GetInstance();
        _instance.TitleText.text = title;
        _instance.MessageText.text = message;
        UIAlertController.Instance.PresentAlert(_instance);
        IsOpen = true;
    }

    static void GetInstance()
    {
        if (_instance == null)
        {
            _instance = Load("Alerts/NoButtonAlert", UIAlertController.Instance.CanvasRect) as NoButtonAlert;
        }
    }
    #endregion
}
