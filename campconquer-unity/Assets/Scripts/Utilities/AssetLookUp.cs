using UnityEngine;

using System.Collections.Generic;

public class AssetLookUp : MonoBehaviour
{
    #region Public Vars
    public Sprite Locked;
    public Sprite StoreNormal;
    public Sprite StorePurchased;
    public Sprite StoreSelected;
    public Sprite BuyButton;
    public Sprite EquipButton;
    public Sprite UnequipButton;
    public Sprite ClaimedButton;
    public Sprite ClaimGemsButton;

    public Sprite[] AvatarNavIcons;
    public Sprite[] AmmoIcons;
    public Sprite[] GearIcons;

    public Sprite[] AvatarIcons;
    public Sprite[] AvatarBodies;
    public Sprite[] AvatarClothes;
    public Sprite[] AvatarFaces;
    public Sprite[] AvatarShoes;
    public Sprite[] AvatarHair;

    public Sprite[] Gear;

    public Sprite[] RedBalloons;
    public Sprite[] BlueBalloons;

    public Sprite[] TutorialBattleImages;
    public Sprite[] TutorialStoreImages;
    public Sprite[] TutorialRewardsImages;

    public static AssetLookUp Instance = null;
    #endregion

    #region Unity Methods
    public void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
            Destroy(gameObject);
    }
    #endregion

    #region Methods
    Sprite GetAsset(Sprite[] array, string assetName)
    {
        Sprite sprite = null;
        for (int index = 0; index < array.Length; index++)
        {
            sprite = array[index];
            if (sprite.name == assetName)
            {
                return sprite;
            }
        }
        return null;
    }

    public Sprite GetAvatarIcon(string name)
    {
        return GetAsset(AvatarIcons, name);
    }

    public Sprite GetAvatarNavIcon(string name)
    {
        return GetAsset(AvatarNavIcons, name);
    }

    public Sprite GetAvatarBody(string name)
    {
        return GetAsset(AvatarBodies, name);
    }

    public Sprite GetAvatarClothes(string name)
    {
        return GetAsset(AvatarClothes, name);
    }

    public Sprite GetAvatarFace(string name)
    {
        return GetAsset(AvatarFaces, name);
    }

    public Sprite GetAvatarHair(string name)
    {
        return GetAsset(AvatarHair, name);
    }

    public Sprite GetAvatarShoes(string name)
    {
        return GetAsset(AvatarShoes, name);
    }

    public Sprite GetGearIcon(string name)
    {
        return GetAsset(GearIcons, name);
    }

    public Sprite GetGear(string name)
    {
        return GetAsset(Gear, name);
    }
	#endregion
}