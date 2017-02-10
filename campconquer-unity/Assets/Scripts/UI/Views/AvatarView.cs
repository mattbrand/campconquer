using UnityEngine;
using UnityEngine.UI;
using System;
using System.Collections;
using gametheory.UI;

#region Enums
public enum AvatarViewState { MAIN = 0, STORE, AMMO };
#endregion

public class AvatarView : UIView 
{
    #region Constants
    const int STATS_MAX = 20;
    #endregion

    #region Public Vars
    public StoreView StoreView;
    public Image[] HealthImages;
    public Image[] RangeImages;
    public Image[] SpeedImages;
    public ExtendedButton[] NavButtons;
    public Animator[] NavButtonAnimators;
    public Image AvatarImage;
    public Image FaceImage;
    public Image HairImage;
    public Image ShirtImage;
    public Image ShortsImage;
    public ExtendedImage HatImage;
    public ExtendedImage ShirtDecalImage;
    public ExtendedImage ShoesImage;
    public ExtendedImage AccessoriesImage;
    public GameObject StoreRefreshButtonObj;
    public static AvatarView Instance;
    #endregion

    #region Private Vars
    AvatarViewState _state;
    StoreItem _displayedItem;
    #endregion

    #region Overridden Methods
    protected override void OnInit()
    {
        base.OnInit();

        if (Instance == null)
        {
            Instance = this;
            StoreRefreshButton.RefreshStoreData += Refresh;
        }
        else
        {
            Destroy(gameObject);
        }
    }

    protected override void OnActivate()
    {
        base.OnActivate();

        // test stats
        //Avatar.Instance.SetAvatarStats(5, 5, 5);

        InitStats();

        AvatarImage.sprite = AssetLookUp.Instance.GetAvatarBody(Database.Instance.GetBodyAssetForBodyType(Avatar.Instance.BodyType));
        Database.Instance.BuildCurrentFaceList();
        Database.Instance.BuildCurrentHairList();
        Database.Instance.BuildCurrentGearList();
        AvatarImage.color = Colors.HexToColor(Avatar.Instance.SkinColor);
        if (Avatar.Instance.FaceAsset != null && Avatar.Instance.FaceAsset != "")
            FaceImage.sprite = AssetLookUp.Instance.GetAvatarFace(Avatar.Instance.FaceAsset);
        else
            FaceImage.sprite = AssetLookUp.Instance.GetAvatarFace(Database.Instance.GetCurrentFaceList()[0].ObjectId);
        FaceImage.color = Colors.HexToColor(Database.Instance.GetFaceColorForSkinColor(Avatar.Instance.SkinColor));
        HairImage.sprite = AssetLookUp.Instance.GetAvatarHair(Avatar.Instance.HairAsset);
        //Debug.Log("1 set hair sprite to " + HairImage.sprite);
        HairImage.color = Colors.HexToColor(Avatar.Instance.HairColor);
        ShirtImage.sprite = AssetLookUp.Instance.GetAvatarClothes(Database.Instance.GetShirtAssetForBodyType(Avatar.Instance.BodyType));
        if (Avatar.Instance.Color == TeamColor.RED)
            ShirtImage.color = Colors.RedShirtColor;
        else
            ShirtImage.color = Colors.BlueShirtColor;
        ShortsImage.sprite = AssetLookUp.Instance.GetAvatarClothes(Database.Instance.GetShortsAssetForBodyType(Avatar.Instance.BodyType));

        DisplayEquippedGear();

        _state = AvatarViewState.MAIN;
        UIViewController.ActivateUIView(CoinsGemsView.Load());
        UIViewController.ActivateUIView(AmmoBeltView.Load());

        if (!PlayerPrefs.HasKey("AvatarViewTutorial") || PlayerPrefs.GetInt("AvatarViewTutorial") != 1)
        {
            ClickTutorial();
            PlayerPrefs.SetInt("AvatarViewTutorial", 1);
        }
    }

    protected override void OnCleanUp()
    {
        base.OnCleanUp();

        StoreRefreshButton.RefreshStoreData -= Refresh;

        Instance = null;
    }
    #endregion

    #region UI Methods
    public static AvatarView Load()
    {
        AvatarView view = UIView.Load("Views/AvatarView", OverriddenViewController.Instance.transform) as AvatarView;
        view.name = "AvatarView";
        return view;
    }

    public void DisplayEquippedGear()
    {
        //Debug.Log("displayEquippedGear - " + Avatar.Instance.EquippedIDs.Count);
        // set up gear assets
        for (int i = 0; i < Avatar.Instance.EquippedIDs.Count; i++)
        {
            StoreItem gear = Database.Instance.GetGearItem(Avatar.Instance.EquippedIDs[i]);
            //Debug.Log(gear.AssetName + " " + gear.BodyType);
            if (gear.BodyType == "" || gear.BodyType == Avatar.Instance.BodyType.ToString())
            {
                //Debug.Log(Avatar.Instance.EquippedIDs[i]);
                DisplayGear(Database.Instance.GetGearItem(Avatar.Instance.EquippedIDs[i]));
            }
        }
    }

    public void InitStats()
    {
        //Debug.Log("init stats - " + Avatar.Instance.Health + " total = " + Avatar.Instance.GetTotalHealth());

        SetGearBonus();

        int i;
        for (i = 0; i < Avatar.Instance.GetTotalHealth(); i++)
        {
            //Debug.Log("health " + i);
            HealthImages[i].color = Colors.ActiveColor;
        }
        for (i = 0; i < Avatar.Instance.GetTotalSpeed(); i++)
        {
            SpeedImages[i].color = Colors.ActiveColor;
        }
        for (i = 0; i < Avatar.Instance.GetTotalRange(); i++)
        {
            RangeImages[i].color = Colors.ActiveColor;
        }
    }

    public void ClickShop()
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.BUTTON_CLICK);

        AvatarView.Instance.State = AvatarViewState.STORE;
        UIViewController.ActivateUIView(StoreView.Load());
        UIViewController.DeactivateUIView("GearEquipView");
        UIViewController.DeactivateUIView("AmmoEquipView");
        UIViewController.DeactivateUIView("AmmoBeltView");
        NavButtons[0].Disable();
        NavButtons[0].transform.localScale = new Vector3(1.2f, 1.2f, 1.2f);
        NavButtons[1].Enable();
        NavButtons[1].transform.localScale = Vector3.one;
        CoinsGemsView.Instance.MoveToFront();
        StoreRefreshButtonObj.transform.SetAsLastSibling();

        _state = AvatarViewState.STORE;
    }

    public void ClickAmmoEquip()
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.BUTTON_CLICK);

        AvatarView.Instance.State = AvatarViewState.AMMO;
        UIViewController.ActivateUIView(AmmoEquipView.Load());
        UIViewController.ActivateUIView(AmmoBeltView.Load());
        UIViewController.DeactivateUIView("GearEquipView");
        UIViewController.DeactivateUIView("StoreView");
        NavButtons[0].Enable();
        NavButtons[0].transform.localScale = Vector3.one;
        NavButtons[1].Disable();
        NavButtons[1].transform.localScale = new Vector3(1.2f, 1.2f, 1.2f);
        CoinsGemsView.Instance.MoveToFront();
        StoreRefreshButtonObj.transform.SetAsLastSibling();

        if (_displayedItem != null)
            RemoveGear(_displayedItem);

        _state = AvatarViewState.AMMO;
    }

    public void ClickBackButton()
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.BUTTON_CLICK);

        UIViewController.DeactivateUIView("AvatarView");
        UIViewController.DeactivateUIView("GearEquipView");
        UIViewController.DeactivateUIView("AmmoEquipView");
        UIViewController.DeactivateUIView("StoreView");
        UIViewController.DeactivateUIView("AmmoBeltView");
        UIViewController.DeactivateUIView("CoinsGemsView");
        UIViewController.DeactivateUIView("BackgroundView");
        UIViewController.ActivateUIView("ClientMainView");
    }

    public void ResetStats()
    {
        //Debug.Log("ResetStats " + Avatar.Instance.Health + " total = " + Avatar.Instance.GetTotalHealth());

        int i;
        for (i = 0; i < Avatar.Instance.GetTotalHealth(); i++)
        {
            HealthImages[i].color = Colors.ActiveColor;
        }
        if (Avatar.Instance.GetTotalHealth() < HealthImages.Length)
        { 
            for (i = Avatar.Instance.GetTotalHealth(); i < HealthImages.Length; i++)
            {
                HealthImages[i].color = Colors.InactiveColor;
            }
        }
        for (i = 0; i < Avatar.Instance.GetTotalSpeed(); i++)
        {
            SpeedImages[i].color = Colors.ActiveColor;
        }
        if (Avatar.Instance.GetTotalSpeed() < SpeedImages.Length)
        {
            for (i = Avatar.Instance.GetTotalSpeed(); i < SpeedImages.Length; i++)
            {
                SpeedImages[i].color = Colors.InactiveColor;
            }
        }
        for (i = 0; i < Avatar.Instance.GetTotalRange(); i++)
        {
            RangeImages[i].color = Colors.ActiveColor;
        }
        if (Avatar.Instance.GetTotalRange() < RangeImages.Length)
        {
            for (i = Avatar.Instance.GetTotalRange(); i < RangeImages.Length; i++)
            {
                RangeImages[i].color = Colors.InactiveColor;
            }
        }
    }

    public void AdjustStats(int health, int speed, int range, string itemType)
    {
        ResetStats();

        int i = 0;
        if (health > 0 && Avatar.Instance.GetTotalHealth() < HealthImages.Length)
        {
            for (i = Avatar.Instance.GetTotalHealth(); i < Avatar.Instance.GetTotalHealth() + health; i++)
            {
                if (i < STATS_MAX)
                    HealthImages[i].color = Colors.PreviewColor;
            }
        }
        if (speed > 0 && Avatar.Instance.GetTotalSpeed() < SpeedImages.Length)
        {
            for (i = Avatar.Instance.GetTotalSpeed(); i < Avatar.Instance.GetTotalSpeed() + speed; i++)
            {
                if (i < STATS_MAX)
                    SpeedImages[i].color = Colors.PreviewColor;
            }
        }
        if (range > 0 && Avatar.Instance.GetTotalRange() < RangeImages.Length)
        {
            for (i = Avatar.Instance.GetTotalRange(); i < Avatar.Instance.GetTotalRange() + range; i++)
            {
                if (i < STATS_MAX)
                    RangeImages[i].color = Colors.PreviewColor;
            }
        }
    }

    public void SetGearBonus()
    {
        int healthBonus = 0;
        int speedBonus = 0;
        int rangeBonus = 0;

        StoreItem item = null;
        for (int i = 0; i < Database.Instance.GearList.Count; i++)
        {
            item = Database.Instance.GearList[i];

            if (Avatar.Instance.EquippedIDs.Contains(item.Name))
            {
                //Debug.Log("equipped item " + item.Name + " bonus = " + item.HealthBonus);
                healthBonus += item.HealthBonus;
                speedBonus += item.SpeedBonus;
                rangeBonus += item.RangeBonus;
            }
        }

        Avatar.Instance.HealthBonus = healthBonus;
        Avatar.Instance.SpeedBonus = speedBonus;
        Avatar.Instance.RangeBonus = rangeBonus;
    }

    public void SetGearBonusWithoutItemsOfType(string itemType)
    {
        int healthBonus = 0;
        int speedBonus = 0;
        int rangeBonus = 0;

        StoreItem item = null;
        for (int i = 0; i < Database.Instance.GearList.Count; i++)
        {
            item = Database.Instance.GearList[i];

            if (Avatar.Instance.EquippedIDs.Contains(item.Name) && item.Type != itemType)
            {
                healthBonus += item.HealthBonus;
                speedBonus += item.SpeedBonus;
                rangeBonus += item.RangeBonus;
            }
        }

        Avatar.Instance.HealthBonus = healthBonus;
        Avatar.Instance.SpeedBonus = speedBonus;
        Avatar.Instance.RangeBonus = rangeBonus;
    }

    public void DisplayGear(StoreItem item)
    {
        GearType itemType = (GearType)Enum.Parse(typeof(GearType), item.Type, true);
        bool hat = false;
        switch (itemType)
        {
            case GearType.HEAD:
                HatImage.Image.sprite = AssetLookUp.Instance.GetGear(item.AssetName);
                //Debug.Log("displaying gear " + item.AssetName + " hair = " + item.Hair);
                HatImage.Activate();
                if (item.Hair != null && item.Hair != "")
                {
                    HairImage.sprite = AssetLookUp.Instance.GetAvatarHair(item.Hair);
                    //Debug.Log("2 set hair to " + HairImage.sprite);
                }
                else
                {
                    HairImage.sprite = AssetLookUp.Instance.GetAvatarHair(Avatar.Instance.HairAsset);
                }
                hat = true;
                break;
            case GearType.SHIRT:
                //Debug.Log(item.AssetName);
                ShirtDecalImage.Image.sprite = AssetLookUp.Instance.GetGear(item.AssetName);
                //Debug.Log("color = " + item.ColorDecal);
                if (item.ColorDecal)
                {
                    if (Avatar.Instance.Color == TeamColor.RED)
                        ShirtDecalImage.Image.color = Colors.RedShirtColor;
                    else
                        ShirtDecalImage.Image.color = Colors.BlueShirtColor;
                }
                else
                    ShirtDecalImage.Image.color = Color.white;
                ShirtDecalImage.Activate();
                break;
            case GearType.SHOES:
                ShoesImage.Image.sprite = AssetLookUp.Instance.GetGear(item.AssetName);
                ShoesImage.Activate();
                break;
            case GearType.ACCESSORY:
                AccessoriesImage.Image.sprite = AssetLookUp.Instance.GetGear(item.AssetName);
                AccessoriesImage.Activate();
                break;
                
        }
        if (!item.Equipped)
            _displayedItem = item;
    }

    public void RemoveGear(StoreItem item)
    {
        GearType itemType = (GearType)Enum.Parse(typeof(GearType), item.Type, true);
        //Debug.Log(item.AssetName);
        switch (itemType)
        {
            case GearType.HEAD:
                HatImage.Image.sprite = null;
                HatImage.Deactivate();
                HairImage.sprite = AssetLookUp.Instance.GetAvatarHair(Avatar.Instance.HairAsset);
                break;
            case GearType.SHIRT:
                ShirtDecalImage.Image.sprite = null;
                ShirtDecalImage.Deactivate();
                break;
            case GearType.SHOES:
                ShoesImage.Image.sprite = null;
                break;
            case GearType.ACCESSORY:
                AccessoriesImage.Image.sprite = null;
                AccessoriesImage.Deactivate();
                break;
        }

        if (item == _displayedItem)
            _displayedItem = null;

        DisplayEquippedGear();
    }

    public void ClickTutorial()
    {
        TutorialAlert.Present(TutorialAlertType.STORE);
    }

    void Refresh()
    {
        LoadingAlert.Present();

        StartCoroutine(StartRefresh());
    }
    #endregion

    #region Coroutines
    IEnumerator StartRefresh()
    {
        yield return StartCoroutine(OnlineManager.Instance.StartGetPlayer(OnlineManager.Instance.PlayerID));

        if (_state == AvatarViewState.AMMO)
            AmmoBeltView.Instance.Refresh();

        // remove loader
        LoadingAlert.FinishLoading();
    }
    #endregion

    #region Accessors
    public AvatarViewState State
    {
        get { return _state; }
        set { _state = value; }
    }
    #endregion
}