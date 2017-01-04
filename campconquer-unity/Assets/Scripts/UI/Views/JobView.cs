using gametheory.UI;

public class JobView : UIView 
{
    #region Overridden Methods
    #endregion

    #region UI Methods
    public static JobView Load()
    {
        JobView view = UIView.Load("Views/JobView", OverriddenViewController.Instance.transform) as JobView;
        view.name = "JobView";
        return view;
    }

    public void ClickJob(int jobIndex)
    {
        Avatar.Instance.Type = (PieceType)jobIndex;
        UIViewController.ActivateUIView(StatsView.Load());
        UIViewController.DeactivateUIView("JobView");
    }

    public void ClickBack()
    {
        UIViewController.DeactivateUIView("JobView");
        UIViewController.ActivateUIView(ColorView.Load());
    }
    #endregion
}