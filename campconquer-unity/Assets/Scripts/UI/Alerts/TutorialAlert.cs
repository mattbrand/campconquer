using UnityEngine;
using gametheory.UI;

#region Enums
public enum TutorialAlertType { BATTLE = 0, STORE, REWARDS };
#endregion

public class TutorialAlert : UIAlert 
{
    #region Public Vars
    public ExtendedImage Image;
    public ExtendedText Text;

    public string[] BattleTextStrings;
    public string[] StoreTextStrings;
    public string[] RewardsTextStrings;
    #endregion

    #region Private Vars
    TutorialAlertType _type;
    int _screenIndex;
    static TutorialAlert _instance = null;
    #endregion

    #region Overridden Methods
    protected override void OnInit()
    {
        base.OnInit();
    }

    protected override void OnActivate()
    {
        base.OnActivate();
    }

    protected override void OnDeactivate()
    {
        base.OnDeactivate();
        _instance = null;
    }
    #endregion

    #region Methods
    public static void Present(TutorialAlertType type)
    {
        GetInstance();
        _instance._type = type;
        _instance._screenIndex = 0;
        _instance.SetScreenImage();
        _instance.SetScreenText();
        UIAlertController.Instance.PresentAlert(_instance);
    }

    public void Click()
    {
        _screenIndex++;

        if (_screenIndex >= 3)
        {
            Deactivate();
        }
        else
        {
            SetScreenImage();
            SetScreenText();
        }
    }

    void SetScreenImage()
    {
        switch (_type)
        {
            case TutorialAlertType.BATTLE:
                Image.CurrentSprite = AssetLookUp.Instance.TutorialBattleImages[_screenIndex];
                break;
            case TutorialAlertType.STORE:
                Image.CurrentSprite = AssetLookUp.Instance.TutorialStoreImages[_screenIndex];
                break;
            case TutorialAlertType.REWARDS:
                Image.CurrentSprite = AssetLookUp.Instance.TutorialRewardsImages[_screenIndex];
                break;
        }
    }

    void SetScreenText()
    {
        switch (_type)
        {
            case TutorialAlertType.BATTLE:
                Text.Text = BattleTextStrings[_screenIndex];
                break;
            case TutorialAlertType.STORE:
                Text.Text = StoreTextStrings[_screenIndex];
                break;
            case TutorialAlertType.REWARDS:
                Text.Text = RewardsTextStrings[_screenIndex];
                break;
        }
        Text.Text = Text.Text.Replace("<br>", "\n\n");
    }

    static void GetInstance()
    {
        if (_instance == null)
        {
            _instance = Load("Alerts/TutorialAlert", UIAlertController.Instance.CanvasRect) as TutorialAlert;
        }
    }
    #endregion
}