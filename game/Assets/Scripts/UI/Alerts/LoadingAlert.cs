using UnityEngine.UI;
using gametheory.UI;

public class LoadingAlert : UIAlert 
{
    #region Private Vars
    static LoadingAlert _instance = null;
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
            _instance = Load("Alerts/LoadingAlert", UIAlertController.Instance.CanvasRect) as LoadingAlert;
        }
    }

    public static void FinishLoading()
    {
        _instance.Deactivate();
    }
    #endregion
}