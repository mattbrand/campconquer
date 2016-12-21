using gametheory.UI;

public class CoinsGemsView : UIView 
{
    #region Public Vars
    public ExtendedText Coins;
    public ExtendedText Gems;
    public static CoinsGemsView Instance;
    #endregion

    #region Overridden Methods
    protected override void OnActivate()
    {
        base.OnActivate();

        SetBinding();
    }

    protected override void OnCleanUp()
    {
        base.OnCleanUp();

        Instance = null;
        Destroy(this.gameObject);
    }
    #endregion

    #region Methods
    public static CoinsGemsView Load()
    {
        CoinsGemsView view = UIView.Load("Views/CoinsGemsView", OverriddenViewController.Instance.transform) as CoinsGemsView;
        view.name = "CoinsGemsView";

        if (Instance == null)
        {
            Instance = view;
        }
        else
        {
            Destroy(view.gameObject);
        }

        return view;
    }

    public void MoveToFront()
    {
        gameObject.transform.SetAsLastSibling();
    }

    public void SetBinding()
    {
        Coins.SetContext(Avatar.Instance);
        Coins.SetTextBinding("Coins");

        Gems.SetContext(Avatar.Instance);
        Gems.SetTextBinding("Gems");
    }
    #endregion
}