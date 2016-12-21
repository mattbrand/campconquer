using System.Collections;
using gametheory.UI;

public class AmmoEquipView : UIView 
{
    #region Constants
    const int BALLOON_COST = 25;
    const int ARROW_COST = 50;
    const int BOMB_COST = 100;
    #endregion

    #region Public Vars
    public ExtendedImage BalloonImage;
    public ExtendedImage ArrowImage;
    public ExtendedImage BombImage;
    #endregion

    #region Private Vars
    int _index;
    #endregion

    #region Overridden Methods
    protected override void OnActivate()
    {
        base.OnActivate();

        if (Avatar.Instance.Color == TeamColor.BLUE)
        {
            BalloonImage.Image.sprite = AssetLookUp.Instance.BlueBalloons[0];
            ArrowImage.Image.sprite = AssetLookUp.Instance.BlueBalloons[1];
            BombImage.Image.sprite = AssetLookUp.Instance.BlueBalloons[2];
        }
    }

    protected override void OnDeactivate()
    {
        base.OnDeactivate();
    } 
    #endregion

    #region UI Methods
    public static AmmoEquipView Load()
    {
        AmmoEquipView view = UIView.Load("Views/AmmoEquipView", OverriddenViewController.Instance.transform) as AmmoEquipView;
        view.name = "AmmoEquipView";
        return view;
    }

    public void ClickBalloon()
    {
        bool canSpend = Avatar.Instance.CanSpendCoins(BALLOON_COST);
        int index = AmmoBeltView.Instance.FindNextOpenIndex();
        if (canSpend && index > -1)
        {
            _index = index;
            YesNoAlert.Present("Balloon", "Are you sure you want to purchase this?", BuyBalloon, null);
        }
        else
        {
            if (!canSpend)
                DefaultAlert.Present("Sorry", "You don't have enough coins", null, null, false, "OK");
            else
                DefaultAlert.Present("Sorry", "Your ammo bandelier is full", null, null, false, "OK");
        }
    }

    void BuyBalloon()
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.BALLOON_PURCHASE);

        LoadingAlert.Present();
        StartCoroutine(SendAmmoBuyToServer(AmmoType.BALLOON, BALLOON_COST));
    }

    IEnumerator SendAmmoBuyToServer(AmmoType ammoType, int cost)
    {
        yield return StartCoroutine(OnlineManager.Instance.StartBuyAmmo(ammoType.ToString().ToLower()));

        if (OnlineManager.Instance.ResponseData.Success)
        {
            Avatar.Instance.Spend(cost, 0);
            Avatar.Instance.AddAmmo(ammoType);
            AmmoBeltView.Instance.SetAmmo(_index, ammoType);
        }
        LoadingAlert.FinishLoading();
    }

    public void ClickArrow()
    {
        bool canSpend = Avatar.Instance.CanSpendCoins(ARROW_COST);
        int index = AmmoBeltView.Instance.FindNextOpenIndex();
        if (canSpend && index > -1)
        {
            _index = index;
            YesNoAlert.Present("Balloon Arrow", "Are you sure you want to purchase this?", BuyArrow, null);
        }
        else
        {
            if (!canSpend)
                DefaultAlert.Present("Sorry", "You don't have enough coins", null, null, false, "OK");
            else
                DefaultAlert.Present("Sorry", "Your ammo bandelier is full", null, null, false, "OK");
        }
    }

    void BuyArrow()
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.ARROW_PURCHASE);

        LoadingAlert.Present();
        StartCoroutine(SendAmmoBuyToServer(AmmoType.ARROW, ARROW_COST));
    }

    public void ClickBomb()
    {
        bool canSpend = Avatar.Instance.CanSpendCoins(BOMB_COST);
        int index = AmmoBeltView.Instance.FindNextOpenIndex();
        if (canSpend && index > -1)
        {
            _index = index;
            YesNoAlert.Present("Big Balloon", "Are you sure you want to purchase this?", BuyBomb, null);
        }
        else
        {
            if (!canSpend)
                DefaultAlert.Present("Sorry", "You don't have enough coins", null, null, false, "OK");
            else
                DefaultAlert.Present("Sorry", "Your ammo bandelier is full", null, null, false, "OK");
        }
    }

    void BuyBomb()
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.BOMB_PURCHASE);

        LoadingAlert.Present();
        StartCoroutine(SendAmmoBuyToServer(AmmoType.BOMB, BOMB_COST));
    }

    /*
    public void ClickedAmmo(AmmoDisplay ammo)
    {
        bool presentRemoveButton = false;
        if (!ammo.Selected)
            presentRemoveButton = true;
        
        for (int i = 0; i < AmmoList.Length; i++)
        {
            AmmoList[i].Unselect();
        }
        RemoveButton.Remove();

        if (presentRemoveButton)
        {
            ammo.Select();
            _currentAmmo = ammo;
            RemoveButton.Present();
        }
    }
    */

    /*
    public void RemoveAmmo()
    {
        if (_currentAmmo != null)
        {
            switch (_currentAmmo.Type)
            {
                case AmmoType.BALLOON:
                    _gold += BALLOON_COST;
                    break;
                case AmmoType.ARROW:
                    _gold += ARROW_COST;
                    break;
                case AmmoType.BOMB:
                    _gold += BOMB_COST;
                    break;
            }
            Gold.Text = _gold.ToString();

            // remove from AmmoList
        }
    }
    */
    #endregion
}