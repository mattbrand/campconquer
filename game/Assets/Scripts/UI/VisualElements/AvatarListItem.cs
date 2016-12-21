using UnityEngine;
using UnityEngine.UI;
using gametheory.UI;

public class AvatarListItem : ListElement 
{
    #region Public Vars
    public Sprite EquippedBG;
    public Sprite UnequippedBG;
    public Image BGImage;
    public Image ItemIcon;
    public Image ColorSwatch;
    #endregion

    #region Overridden MEthods
    public override void PresentVisuals(bool display)
    {
        base.PresentVisuals(display);

        AvatarItem item = _obj as AvatarItem;

        if (item != null)
        {
            // set up icon
            if (item.IconName != "")
                ItemIcon.sprite = AssetLookUp.Instance.GetAvatarIcon(item.IconName);

            // set up color swatch
            if (item.Color != "" && ItemIcon != null)
            {
                ItemIcon.enabled = false;
                ColorSwatch.color = Colors.HexToColor(item.Color);
            }
            else if (ColorSwatch != null)
            {
                ColorSwatch.enabled = false;
            }
        }      
    }
    #endregion

    #region UI Methods
    public void Equip()
    {
        BGImage.sprite = EquippedBG;
    }

    public void Unequip()
    {
        BGImage.sprite = UnequippedBG;
    }
    #endregion

    #region Accessors
    public AvatarItem GetItem
    {
        get { return _obj as AvatarItem; }
        set { _obj = value as AvatarItem; }
    }
    #endregion
}