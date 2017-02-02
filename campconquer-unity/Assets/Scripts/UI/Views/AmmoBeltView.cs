using UnityEngine;
using UnityEngine.UI;
using System.Collections;
using gametheory.UI;

public class AmmoBeltView : UIView 
{
    #region Public Vars
    public GridLayoutGroup Belt;
    public AmmoDisplay[] AmmoList;
    public ExtendedImage LockedImage;
    public ExtendedImage EquipLockedImage;
    public ExtendedText LockedText;
    public static AmmoBeltView Instance;
    #endregion

    #region Overridden Methods
    protected override void OnInit()
    {
        base.OnInit();

        if (Instance == null)
        {
            Instance = this;
        }
        else
        {
            Destroy(gameObject);
        }
    }

    protected override void OnActivate()
    {
        base.OnActivate();

        StartCoroutine(CheckGameStatus());
    }
    #endregion

    #region UI Methods
    public static AmmoBeltView Load()
    {
        AmmoBeltView view = UIView.Load("Views/AmmoBeltView", OverriddenViewController.Instance.transform) as AmmoBeltView;
        view.name = "AmmoBeltView";
        return view;
    }

    IEnumerator CheckGameStatus()
    {
        yield return StartCoroutine(OnlineManager.Instance.StartGetGame());

        PresetAmmo();

        if (OnlineManager.Instance.GameStatus == OnlineGameStatus.PREPARING)
        {
            UnlockScreen();
        }
        else
        {
            LockScreen();
        }
    }

    void LockScreen()
    {
        LockedImage.Activate();
        EquipLockedImage.Activate();
        LockedText.Activate();
    }

    void UnlockScreen()
    {
        LockedImage.Deactivate();
        EquipLockedImage.Deactivate();
        LockedText.Deactivate();
    }

    void PresetAmmo()
    {
        int i = 0;
        for (i = 0; i < AmmoList.Length; i++)
        {
            AmmoList[i].Clear();
        }

        for (i = 0; i < Avatar.Instance.Ammo.AmmoList.Count; i++)
        {
            SetAmmo(i, Avatar.Instance.Ammo.AmmoList[i]);
        }
    }

    public void SetAmmo(int index, AmmoType type)
    {
        AmmoList[index].Initialize(type);
    }

    public int FindNextOpenIndex()
    {
        for (int i = 0; i < AmmoList.Length; i++)
        {
            if (!AmmoList[i].Set)
                return i;
        }
        return -1;
    }

    public void Refresh()
    {
        StartCoroutine(CheckGameStatus());
    }
    #endregion
}