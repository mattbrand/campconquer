using gametheory.UI;

public class ColorView : UIView 
{
    #region Overridden Methods
    #endregion

    #region UI Methods
    public static ColorView Load()
    {
        ColorView view = UIView.Load("Views/ColorView", OverriddenViewController.Instance.transform) as ColorView;
        view.name = "ColorView";
        return view;
    }

    public void ClickColor(int colorIndex)
    {
        Avatar.Instance.Color = (TeamColor)colorIndex;
        UIViewController.ActivateUIView(JobView.Load());
        UIViewController.DeactivateUIView("ColorView"); 
    }
    #endregion
}