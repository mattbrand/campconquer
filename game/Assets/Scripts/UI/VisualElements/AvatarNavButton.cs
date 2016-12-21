using UnityEngine.UI;
using gametheory.UI;

public class AvatarNavButton : ListElement 
{
    #region Public Vars
    public Button Button;
    public Image Image;
    #endregion

    #region Overridden Methods
    public override void PresentVisuals(bool display)
    {
        base.PresentVisuals(display);

        if (Button != null)
        {
            Button.enabled = display;
            Button.targetGraphic.enabled = display;
        }
    }

    protected override void Enabled()
    {
        base.Enabled();

        Button.interactable = true;
    }

    protected override void Disabled()
    {
        base.Disabled();

        Button.interactable = false;
    }
    #endregion

    #region UI Methods
    public void SetImage()
    {
        //Image.sprite = 
    }
    #endregion
}