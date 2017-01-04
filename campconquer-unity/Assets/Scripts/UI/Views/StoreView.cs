using UnityEngine;
using UnityEngine.UI;
using System;
using System.Collections;
using System.Collections.Generic;
using gametheory.UI;

public class StoreView : UIView 
{
	#region Events
    public static event Action<StoreItem> gearEquipped;
	#endregion

	#region Constants
    const string GEAR_PATH = "Database - Gear";
    const string BUY = "Buy";
    const string PURCHASED = "Owned";
    const string EQUIP = "Equip";
    const string UNEQUIP = "Unequip";
    const string SORRY = "Sorry";
    const string INSUFFICIENT_COINS = "You do not have enough coins to purchase this item.";
    const string INSUFFICIENT_GEMS = "You do not have enough gems to purchase this item.";
	#endregion

	#region Public Vars
	public Text ItemTitle;
	public Text ItemDescription;

    public ExtendedText CoinsCostText;
    public ExtendedText GemCostText;
    public ExtendedText OwnedText;
    public ExtendedText LockedText;

	public ExtendedButton BuyButton;
    public ExtendedButton HeadButton;
    public ExtendedButton ShirtButton;
    public ExtendedButton ShoesButton;
    public ExtendedButton AccessoryButton;

    public ExtendedImage CoinsImage;
    public ExtendedImage GemImage;
    public ExtendedImage LockedImage;

    public UIList StoreList;

	public StoreListItem ItemPrefab;
	#endregion

	#region Private Vars
	StoreListItem _currentItem;

    GearType _filter;
    #endregion

	#region Overridden Methods
    protected override void OnInit()
    {
        base.OnInit();

        StoreListItem.selected += ItemSelected;
    }

	protected override void OnActivate()
	{
		base.OnActivate();

        StartCoroutine(CheckGameStatus());
	}

	protected override void OnDeactivate()
	{
		base.OnDeactivate();

		StoreList.ClearElements();
	}

    protected override void OnCleanUp()
    {
        base.OnCleanUp();

        StoreListItem.selected -= ItemSelected;
    }
	#endregion

	#region UI Methods
    public static StoreView Load()
    {
        StoreView view = UIView.Load("Views/StoreView", OverriddenViewController.Instance.transform) as StoreView;
        view.name = "StoreView";
        return view;
    }

    IEnumerator CheckGameStatus()
    {
        yield return StartCoroutine(OnlineManager.Instance.StartGetGame());

        //Debug.Log(OnlineManager.Instance.GameStatus);

        if (OnlineManager.Instance.GameStatus == OnlineGameStatus.PREPARING)
        {
            _filter = GearType.NONE;
            UnlockScreen();
            PresentStore();
        }
        else
        {
            LockScreen();
        }
    }

    void LockScreen()
    {
        LockedImage.Activate();
        LockedText.Activate();
    }

    void UnlockScreen()
    {
        LockedImage.Deactivate();
        LockedText.Deactivate();
    }

	public void Action()
	{
        StoreItem storeItem = _currentItem.Object as StoreItem;

		if (storeItem.Purchased)
        {
            if (!storeItem.Equipped)
            {
                StartCoroutine(StartEquip(storeItem));
            }
            else
            {
                StartCoroutine(StartUnequip(storeItem));
            }
        }
        else
        {
            bool canSpendCoins = Avatar.Instance.CanSpendCoins(storeItem.Coins);
            bool canSpendGems = Avatar.Instance.CanSpendGems(storeItem.Gems);

            if (canSpendCoins && canSpendGems)
            {
                YesNoAlert.Present("Gear", "Are you sure you want to purchase this?", BuyGear, null);
            }
            else
            {
                if (!canSpendCoins)
                    DefaultAlert.Present(SORRY, INSUFFICIENT_COINS);
                else
                    DefaultAlert.Present(SORRY, INSUFFICIENT_GEMS);
            }
        }   
	}
    #endregion

    #region Methods
	void PresentStore()
	{
		SetupData();

        ItemTitle.text = "";
        ItemDescription.text = "";
        CoinsCostText.Text = "";

		StoreItem storeItem = null;
        for(int i = 0; i < Database.Instance.CurrentGearList.Count; i++)
		{
            StoreListItem item = (StoreListItem)GameObject.Instantiate(ItemPrefab, Vector3.zero, Quaternion.identity);
            item.Setup(Database.Instance.CurrentGearList[i]);
            StoreList.AddListElement(item);
		}
	}

	void SetupData()
	{
        List<string> purchased = Avatar.Instance.PurchasedIDs;

		//setup the lists
		StoreItem item = null;
		int index =0;
        for (index = 0; index < Database.Instance.CurrentGearList.Count; index++)
        {
            item = Database.Instance.CurrentGearList[index];

            if (purchased.Contains(item.Name))
                item.Purchased = true;

            if (Avatar.Instance.EquippedIDs.Contains(item.Name))
				item.Equipped = true;
        }

        AvatarView.Instance.SetGearBonus();
        AvatarView.Instance.ResetStats();
	}

	void SetEquipped(StoreItem storeItem)
	{
		Type itemType = storeItem.GetType();
        if(itemType == typeof(StoreItem))
		{
            StoreItem item = storeItem as StoreItem;
			EquipGear(item);
			SetupBuyButton(storeItem);
		}
	}

    void EquipGear(StoreItem item)
    {
        item.Equipped = true;
        for (int i = 0; i < Database.Instance.CurrentGearList.Count; i++)
        {
            StoreItem gearItem = Database.Instance.CurrentGearList[i];
            if (item != gearItem && gearItem.Type == item.Type)
            {
                gearItem.Equipped = false;
                Avatar.Instance.RemoveEquippedItem(gearItem.Name);
            }
        }
        Avatar.Instance.AddEquippedItem(item.Name);
    }

    void SetUnequipped(StoreItem storeItem)
    {
        Type itemType = storeItem.GetType();
        if (itemType == typeof(StoreItem))
        {
            StoreItem item = storeItem as StoreItem;
            UnequipGear(item);
            SetupBuyButton(storeItem);
            _currentItem.Unselect();
            AvatarView.Instance.RemoveGear(_currentItem.Object as StoreItem);
            _currentItem = null;
            SetupBuyButton(null);
        }
    }

	void UnequipGear(StoreItem storeItem)
	{
        storeItem.Equipped = false;
        Avatar.Instance.RemoveEquippedItem(storeItem.Name);

        switch (storeItem.Type)
        {
            case "SHIRT":
                for (int i = 0; i < Avatar.Instance.PurchasedIDs.Count; i++)
                {
                    StoreItem item = Database.Instance.GetGearItem(Avatar.Instance.PurchasedIDs[i]);
                    if (item.Type == GearType.SHIRT.ToString() && item.BodyType == Avatar.Instance.BodyType.ToString() && item.OwnedByDefault == 1)
                    {
                        Avatar.Instance.AddEquippedItem(Avatar.Instance.PurchasedIDs[i]);
                        item.Equipped = true;
                    }
                }
                break;
            case "SHOES":
                for (int i = 0; i < Avatar.Instance.PurchasedIDs.Count; i++)
                {
                    StoreItem item = Database.Instance.GetGearItem(Avatar.Instance.PurchasedIDs[i]);
                    if (item.Type == GearType.SHOES.ToString() && item.OwnedByDefault == 1)
                    {
                        Avatar.Instance.AddEquippedItem(Avatar.Instance.PurchasedIDs[i]);
                        item.Equipped = true;
                    }
                }
                break;
        }

        if (storeItem.Type == GearType.SHIRT.ToString())
        {
            for (int i = 0; i < Avatar.Instance.PurchasedIDs.Count; i++)
            {
                StoreItem item = Database.Instance.GetGearItem(Avatar.Instance.PurchasedIDs[i]);
                if (item.Type == GearType.SHIRT.ToString() && item.BodyType == Avatar.Instance.BodyType.ToString() && item.OwnedByDefault == 1)
                {
                    Avatar.Instance.AddEquippedItem(Avatar.Instance.PurchasedIDs[i]);
                    item.Equipped = true;
                }
            }
        }
    }

	void SetupBuyButton(StoreItem storeItem)
	{
        if (storeItem == null)
        {
            BuyButton.Deactivate();
            CoinsCostText.Deactivate();
            CoinsImage.Deactivate();
            GemCostText.Deactivate();
            GemImage.Deactivate();
            OwnedText.Deactivate();
        }
		else if(!storeItem.Purchased)
		{
            CoinsCostText.Text = storeItem.Coins.ToString();
            CoinsCostText.Activate();
            CoinsImage.Activate();
            GemCostText.Text = storeItem.Gems.ToString();
            GemCostText.Activate();
            GemImage.Activate();
            OwnedText.Deactivate();
			BuyButton.Text = BUY;
            BuyButton.Activate();
		}
		else
		{
            CoinsCostText.Deactivate();
            CoinsImage.Deactivate();
            GemCostText.Deactivate();
            GemImage.Deactivate();
            OwnedText.Activate();

            if (storeItem.Equipped)
            {
                if (storeItem.EquippedByDefault == 1)
                    BuyButton.Deactivate();
                else
                {
                    Type type = storeItem.GetType();
                    BuyButton.Text = UNEQUIP;
                    BuyButton.Activate();
				}
			}
            else
            {
				BuyButton.Text = EQUIP;
                BuyButton.Activate();
            }
		}
	}

    void BuyGear()
    {
        StartCoroutine(PostBuyGear());
    }
    #endregion

    #region Coroutines
    IEnumerator PostBuyGear()
    {
        yield return OnlineManager.Instance.StartGetGame();

        if (OnlineManager.Instance.GameStatus == OnlineGameStatus.PREPARING)
        {
            StoreItem storeItem = _currentItem.Object as StoreItem;

            yield return StartCoroutine(OnlineManager.Instance.StartBuyGear(storeItem.Name));

            if (OnlineManager.Instance.ResponseData.Success)
            {
                Avatar.Instance.Spend(storeItem.Coins, storeItem.Gems);
                Avatar.Instance.AddPurchasedItem(storeItem.Name);
                storeItem.Purchased = true;

                yield return StartCoroutine(StartEquip(storeItem));
            }
        }
        else
        {
            LockedImage.Activate();
            LockedText.Activate();
        }
    }

    IEnumerator StartEquip(StoreItem storeItem)
    {
        yield return OnlineManager.Instance.StartGetGame();

        if (OnlineManager.Instance.GameStatus == OnlineGameStatus.PREPARING)
        {
            yield return OnlineManager.Instance.StartEquipGear(storeItem.Name);

            if (OnlineManager.Instance.ResponseData.Success)
            {
                SetEquipped(storeItem);
                AvatarView.Instance.SetGearBonus();
                AvatarView.Instance.ResetStats();
                if (!storeItem.Equipped)
                    AvatarView.Instance.AdjustStats(storeItem.HealthBonus, storeItem.SpeedBonus, storeItem.RangeBonus, storeItem.Type);
            }
        }
        else
        {
            LockedImage.Activate();
            LockedText.Activate();
        }
    }

    IEnumerator StartUnequip(StoreItem storeItem)
    {
        yield return OnlineManager.Instance.StartGetGame();

        if (OnlineManager.Instance.GameStatus == OnlineGameStatus.PREPARING)
        {
            yield return OnlineManager.Instance.StartUnequipGear(storeItem.Name);

            if (OnlineManager.Instance.ResponseData.Success)
            {
                SetUnequipped(storeItem);
                AvatarView.Instance.SetGearBonus();
                AvatarView.Instance.ResetStats();
                //if (!storeItem.Equipped)
                //    AvatarView.Instance.AdjustStats(storeItem.HealthBonus, storeItem.SpeedBonus, storeItem.RangeBonus, storeItem.Type);
            }
        }
        else
        {
            LockedImage.Activate();
            LockedText.Activate();
        }
    }
    #endregion

    #region Filter Methods
    public void FilterHeadItems()
    {
        if (_filter == GearType.HEAD)
        {
            ShowAllItems();
            HeadButton.Button.image.color = Color.white;
        }
        else
        {
            ShowTypeItems(GearType.HEAD);
            LightenAllButtons();
            HeadButton.Button.image.color = new Color(0.7f, 0.7f, 0.7f, 1.0f);
            CheckCurrentItemForFilter();
        }
    }

    public void FilterShirtItems()
    {
        if (_filter == GearType.SHIRT)
        {
            ShowAllItems();
            ShirtButton.Button.image.color = Color.white;
        }
        else
        {
            ShowTypeItems(GearType.SHIRT);
            LightenAllButtons();
            ShirtButton.Button.image.color = new Color(0.7f, 0.7f, 0.7f, 1.0f);
            CheckCurrentItemForFilter();
        }
    }

    public void FilterShoesItems()
    {
        if (_filter == GearType.SHOES)
        {
            ShowAllItems();
            ShoesButton.Button.image.color = Color.white;
        }
        else
        {
            ShowTypeItems(GearType.SHOES);
            LightenAllButtons();
            ShoesButton.Button.image.color = new Color(0.7f, 0.7f, 0.7f, 1.0f);
            CheckCurrentItemForFilter();
        }
    }

    public void FilterAccessoryItems()
    {
        if (_filter == GearType.ACCESSORY)
        {
            ShowAllItems();
            AccessoryButton.Button.image.color = Color.white;
        }
        else
        {
            ShowTypeItems(GearType.ACCESSORY);
            LightenAllButtons();
            AccessoryButton.Button.image.color = new Color(0.7f, 0.7f, 0.7f, 1.0f);
            CheckCurrentItemForFilter();
        }
    }

    void ShowAllItems()
    {
        for (int i = 0; i < Database.Instance.CurrentGearList.Count; i++)
        {
            StoreList.ListItems[i].gameObject.SetActive(true);
        }
        _filter = GearType.NONE;
    }

    void LightenAllButtons()
    {
        HeadButton.Button.image.color = Color.white;
        ShirtButton.Button.image.color = Color.white;
        ShoesButton.Button.image.color = Color.white;
        AccessoryButton.Button.image.color = Color.white;
    }

    void ShowTypeItems(GearType gearType)
    {
        //Debug.Log("show item types " + gearType);
        for (int i = 0; i < Database.Instance.CurrentGearList.Count; i++)
        {
            if (Database.Instance.CurrentGearList[i].Type != gearType.ToString())
            {
                StoreList.ListItems[i].gameObject.SetActive(false);
            }
            else
            {
                StoreList.ListItems[i].gameObject.SetActive(true);
            }
        }
        _filter = gearType;
    }

    void CheckCurrentItemForFilter()
    {
        if (_currentItem != null)
        {
            StoreItem gearItem = _currentItem.Object as StoreItem;
            if (gearItem.Type != _filter.ToString())
            {
                if (_currentItem != null)
                {
                    AvatarView.Instance.RemoveGear(_currentItem.Object as StoreItem);
                    _currentItem.Unselect();
                    _currentItem.SetBackground();
                    _currentItem = null;
                }
                ItemTitle.text = "";
                ItemDescription.text = "";
                CoinsCostText.Text = "";
                CoinsImage.Deactivate();
                GemCostText.Text = "";
                GemImage.Deactivate();
                BuyButton.Deactivate();
            }
        }
    }
    #endregion

	#region Event Listeners
	void ItemSelected(StoreListItem obj)
	{
        //Debug.Log("ItemSelected 1 - currentItem = ");
        SoundManager.Instance.PlaySoundEffect(SoundType.SOFT_CLICK);

        //Debug.Log("ItemSelected 2");

        if (_currentItem)
        {
            AvatarView.Instance.RemoveGear(_currentItem.Object as StoreItem);
            _currentItem.Unselect();
        }

		_currentItem = obj;
		StoreItem storeItem = _currentItem.Object as StoreItem;

        //Debug.Log("ItemSelected 3 " + storeItem.AssetName);

		ItemTitle.text = storeItem.DisplayName;
		ItemDescription.text = storeItem.Description;

        SetupBuyButton(storeItem);

        if (!storeItem.Equipped)
            AvatarView.Instance.SetGearBonusWithoutItemsOfType(storeItem.Type);
        else
            AvatarView.Instance.SetGearBonus();
        //AvatarView.Instance.SetGearBonus();
        //Debug.Log(Avatar.Instance.Health + " + " + Avatar.Instance.HealthBonus);
        AvatarView.Instance.ResetStats();

        AvatarView.Instance.DisplayGear(_currentItem.Object as StoreItem);

        if (!storeItem.Equipped)
        {
            //Debug.Log(storeItem.Name + " " + storeItem.AssetName + " " + storeItem.HealthBonus);
            AvatarView.Instance.AdjustStats(storeItem.HealthBonus, storeItem.SpeedBonus, storeItem.RangeBonus, storeItem.Type);
        }
	}
	#endregion

	#region Properties
	public static StoreView Alert
	{
		get { return UIView.Load("Alerts/StoreView") as StoreView; }
	}
	#endregion
}