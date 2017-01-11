using UnityEngine;
using gametheory.UI;

public class GearEquipView : UIView 
{
    #region Public Vars
    public GearDisplay[] GearList;
    #endregion

    #region Overridden Methods
    protected override void OnActivate()
    {
        base.OnActivate();

        int gearCount = 0;
        int i;
        // set up gear
        for (i = 0; i < Avatar.Instance.EquippedIDs.Count; i++)
        {
            StoreItem gear = Database.Instance.GetGearItem(Avatar.Instance.EquippedIDs[i]);
            if (gear.BodyType == Avatar.Instance.BodyType.ToString())
            {
                GearList[gearCount].GearImage.Image.sprite = AssetLookUp.Instance.GetGearIcon(gear.IconName);
                GearList[gearCount].GearImage.Activate();
                gearCount++;
            }
        }

        for (i = gearCount; i < GearList.Length; i++)
        {
            GearList[i].BGImage.Image.color = new Color(1.0f, 1.0f, 1.0f, 0.5f);
        }
    }
    #endregion

    #region Methods
    public static GearEquipView Load()
    {
        GearEquipView view = UIView.Load("Views/GearEquipView", OverriddenViewController.Instance.transform) as GearEquipView;
        view.name = "GearEquipView";
        return view;
    }
    #endregion
}