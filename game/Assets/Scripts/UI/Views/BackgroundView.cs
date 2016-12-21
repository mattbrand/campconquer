using gametheory.UI;

public class BackgroundView : UIView 
{
    #region Methods
    public static BackgroundView Load()
    {
        BackgroundView view = UIView.Load("Views/BackgroundView", OverriddenViewController.Instance.transform) as BackgroundView;
        view.name = "BackgroundView";
        return view;
    }
    #endregion
}