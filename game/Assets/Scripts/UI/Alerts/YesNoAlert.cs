using UnityEngine;
using UnityEngine.UI;
using gametheory.UI;
using System;
using System.Collections.Generic;

public class YesNoAlert : UIAlert
{
    #region Events
    static event System.Action yes;
    static event System.Action no;
    #endregion

    #region Public Vars
    public Text TitleText;
    public Text MessageText;

    public static bool IsOpen;
    #endregion

    #region Private Vars
    static Queue<YesNoAlertContent> _alertQueue;
    static YesNoAlert _instance = null;
    #endregion

    #region Overriden Methods
    protected override void OnInit()
    {
        base.OnInit();

        IsOpen = false;

        _alertQueue = new Queue<YesNoAlertContent>();
    }
    protected override void OnDeactivate()
    {
        base.OnDeactivate();
        _instance = null;
    }
    #endregion

    #region UI Methods
    public void Yes()
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.BUTTON_CLICK);

        if (IsQueueEmpty())
        {
            Deactivate();
            IsOpen = false;
        }

        if (yes != null)
            yes();

        yes = null;
        no = null;
    }
    public void No()
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.BUTTON_CLICK);

        if (IsQueueEmpty())
        {
            Deactivate();
            IsOpen = false;
        }

        if (no != null)
            no();

        yes = null;
        no = null;
    }
    #endregion

    #region Methods
    public static void Present(string title, string message, Action yesCallback = null, Action noCallback = null)
    {
        GetInstance();

        if (_alertQueue.Count == 0)
        {
            yes = yesCallback;
            no = noCallback;

            _instance.TitleText.text = title;
            _instance.MessageText.text = message;

            UIAlertController.Instance.PresentAlert(_instance);


            IsOpen = true;
        }

        _alertQueue.Enqueue(new YesNoAlertContent(title, message, yesCallback, noCallback));
    }

    public void OpenNext()
    {
        YesNoAlertContent content = _alertQueue.Peek();

        yes = content.Yes;
        no = content.No;

        TitleText.text = content.Title;
        MessageText.text = content.Message;

        transform.SetAsLastSibling();

        CanvasGroup.interactable = true;
        CanvasGroup.blocksRaycasts = true;
    }

    bool IsQueueEmpty()
    {
        _alertQueue.Dequeue();

        if (_alertQueue.Count > 0)
        {
            OpenNext();
            return false;
        }
        else
            return true;
    }

    static void GetInstance()
    {
        if (_instance == null)
        {
            _instance = Load("Alerts/YesNoAlert", UIAlertController.Instance.CanvasRect) as YesNoAlert;
        }
    }
    #endregion
}

public class YesNoAlertContent
{
    #region Public Vars
    public string Title;
    public string Message;
    public System.Action Yes;
    public System.Action No;
    #endregion

    #region Constructors
    public YesNoAlertContent(string title, string message, Action yes, Action no)
    {
        Title = title;
        Message = message;
        Yes = yes;
        No = no;
    }
    #endregion
}
