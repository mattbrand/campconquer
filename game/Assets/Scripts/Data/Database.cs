using UnityEngine;
using UnityEngine.SceneManagement;
using System;
using System.Collections;
using System.Collections.Generic;
using gametheory.Utilities;

public class Database : MonoBehaviour
{
    #region Constants
    const string GEAR_PATH = "Database - Gear";
    const string AVATAR_PATH = "Database - Avatar";
    const string DEFAULT_BODY_TYPE = "FEMALE";
    const string DEFAULT_FEMALE_FACE = "face_01_f";
    const string DEFAULT_GN1_FACE = "face_01_gn1";
    const string DEFAULT_GN2_FACE = "face_01_gn2";
    const string DEFAULT_MALE_FACE = "face_01_m";
    const string DEFAULT_FEMALE_HAIR = "";
    const string DEFAULT_GN1_HAIR = "";
    const string DEFAULT_GN2_HAIR = "";
    const string DEFAULT_MALE_HAIR = "";
    #endregion

    #region Public Vars
    public static Database Instance;
    #endregion

    #region Private Vars
    List<StoreItem> _gearList;
    List<StoreItem> _currentGearList;
    List<AvatarItem> _avatarList;  // full avatar assets list
    Dictionary<string, List<AvatarItem>> _avatarDict;  // asset dictionary by category
    List<AvatarItem> _currentFaceList;
    List<AvatarItem> _currentHairList;
    List<string> _hairColors;
    List<string> _skinColors;
    #endregion

    #region Unity Methods
    void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            enabled = false;
            if (SceneManager.GetActiveScene().name == "Moderator")
            {
                BuildAvatarLists();
                BuildSkinAndHairColors();
            }
        }
        else
        {
            Destroy(gameObject);
        }
    }

    void OnDestroy()
    {
        Instance = null;
    }
    #endregion

    #region Data Methods
    public void BuildAllData()
    {
        BuildAvatarLists();
        BuildCurrentFaceList();
        BuildCurrentHairList();
        BuildSkinAndHairColors();
    }

    public void BuildAvatarLists()
    {
        _avatarList = CSVImporter.GenerateList<AvatarItem>(AssetBundleSync.Instance.GetFile(AVATAR_PATH));

        _avatarDict = new Dictionary<string, List<AvatarItem>>();
        for (int i = 0; i < _avatarList.Count; i++)
        {
            if (_avatarDict.ContainsKey(_avatarList[i].Type))
            {
                _avatarDict[_avatarList[i].Type].Add(_avatarList[i]);
            }
            else
            {
                _avatarDict[_avatarList[i].Type] = new List<AvatarItem>();
                _avatarDict[_avatarList[i].Type].Add(_avatarList[i]);
            }
        }
    }

    public void BuildSkinAndHairColors()
    {
        // build hair colors
        _hairColors = new List<string>();
        List<AvatarItem> hairItems = _avatarDict["HAIR_COLOR"];
        for (int i = 0; i < hairItems.Count; i++)
        {
            _hairColors.Add(hairItems[i].Color);
        }

        // build skin colors
        _skinColors = new List<string>();
        List<AvatarItem> skinItems = _avatarDict["SKIN_COLOR"];
        for (int i = 0; i < skinItems.Count; i++)
        {
            _skinColors.Add(skinItems[i].Color);
        }
    }

    public void BuildGearList()
    {
        _gearList = new List<StoreItem>();
        //Debug.Log(OnlineManager.Instance.GearResponseData.gears.Count);
        for (int i = 0; i < OnlineManager.Instance.GearResponseData.gears.Count; i++)
        {
            GearData gearData = OnlineManager.Instance.GearResponseData.gears[i];
            StoreItem storeItem = new StoreItem();
            storeItem.Name = gearData.name;
            storeItem.Type = gearData.gear_type.ToUpper();
            if (gearData.body_type != null)
                storeItem.BodyType = gearData.body_type.ToUpper();
            else
                storeItem.BodyType = "";
            storeItem.DisplayName = gearData.display_name;
            storeItem.Description = gearData.description;
            storeItem.AssetName = gearData.asset_name;
            storeItem.IconName = gearData.icon_name;
            storeItem.Coins = gearData.coins;
            storeItem.Gems = gearData.gems;
            storeItem.Level = gearData.level;
            storeItem.HealthBonus = gearData.health_bonus;
            storeItem.SpeedBonus = gearData.speed_bonus;
            storeItem.RangeBonus = gearData.range_bonus;
            storeItem.Hair = gearData.hair;
            if (gearData.owned_by_default)
                storeItem.OwnedByDefault = 1;
            else
                storeItem.OwnedByDefault = 0;
            if (gearData.equipped_by_default)
                storeItem.EquippedByDefault = 1;
            else
                storeItem.EquippedByDefault = 0;
            storeItem.ColorDecal = gearData.color_decal;
            _gearList.Add(storeItem);
        }

        BuildCurrentGearList();
    }

    public void BuildCurrentGearList()
    {
        // build current gear list
        if (Avatar.Instance)
        {
            _currentGearList = new List<StoreItem>();
            for (int i = 0; i < _gearList.Count; i++)
            {
                StoreItem item = _gearList[i];
                if (item.Type == GearType.SHOES.ToString() || item.BodyType == Avatar.Instance.BodyType.ToString())
                {
                    _currentGearList.Add(item);
                }
            }
        }
    }

    public void BuildCurrentFaceList()
    {
        _currentFaceList = new List<AvatarItem>();

        List<AvatarItem> subList = _avatarDict["FACE"];
        for (int i = 0; i < subList.Count; i++)
        {
            if (Avatar.Instance != null)
            {
                //Debug.Log("building from body type " + Avatar.Instance.BodyType.ToString());
                if (subList[i].BodyType == Avatar.Instance.BodyType.ToString())
                    _currentFaceList.Add(subList[i]);
            }
            else
            {
                //Debug.Log("building from default body type");
                if (subList[i].BodyType == DEFAULT_BODY_TYPE)
                    _currentFaceList.Add(subList[i]);
            }
        }
    }

    public void BuildCurrentHairList()
    {
        _currentHairList = new List<AvatarItem>();

        List<AvatarItem> subList = _avatarDict["HAIR"];
        for (int i = 0; i < subList.Count; i++)
        {
            if (Avatar.Instance != null)
            {
                if (subList[i].BodyType == Avatar.Instance.BodyType.ToString())
                    _currentHairList.Add(subList[i]);
            }
            else
            {
                if (subList[i].BodyType == DEFAULT_BODY_TYPE)
                    _currentHairList.Add(subList[i]);
            }
        }
        //Debug.Log(_currentHairList.Count);
    }

    public string GetBodyAssetForBodyType(AvatarBodyType bodyType)
    {
        string bodyTypeStr = bodyType.ToString();
        List<AvatarItem> subList = _avatarDict["BODY"];
        for (int i = 0; i < subList.Count; i++)
        {
            if (subList[i].BodyType == bodyTypeStr)
            {
                return subList[i].ObjectId;
            }
        }
        return "";
    }

    public string GetShirtAssetForBodyType(AvatarBodyType bodyType)
    {
        string bodyTypeStr = bodyType.ToString();
        List<AvatarItem> subList = _avatarDict["BODY"];
        for (int i = 0; i < subList.Count; i++)
        {
            if (subList[i].BodyType == bodyTypeStr)
            {
                return subList[i].ShirtAsset;
            }
        }
        return "";
    }

    public string GetShortsAssetForBodyType(AvatarBodyType bodyType)
    {
        string bodyTypeStr = bodyType.ToString();
        List<AvatarItem> subList = _avatarDict["BODY"];
        for (int i = 0; i < subList.Count; i++)
        {
            if (subList[i].BodyType == bodyTypeStr)
            {
                return subList[i].ShortsAsset;
            }
        }
        return "";
    }

    public string GetFaceColorForSkinColor(string skinColor)
    {
        List<AvatarItem> subList = _avatarDict["SKIN_COLOR"];
        for (int i = 0; i < subList.Count; i++)
        {
            if (subList[i].Color == skinColor)
            {
                return subList[i].FaceColor;
            }
        }
        return "";
    }

    public StoreItem GetGearItem(string key)
    {
        StoreItem item;
        for (int i = 0; i < _gearList.Count; i++)
        {
            if (_gearList[i].Name == key)
                return _gearList[i];
        }
        return null;
    }
    #endregion

    #region Accessors
    public List<StoreItem> GearList
    {
        get { return _gearList; }
    }

    public List<StoreItem> CurrentGearList
    {
        get { return _currentGearList; }
    }

    public List<AvatarItem> AvatarList
    {
        get { return _avatarList; }
    }

    public List<AvatarItem> GetAvatarItemList(AvatarItemType itemType)
    {
        return _avatarDict[itemType.ToString()];
    }

    public List<AvatarItem> GetCurrentFaceList()
    {
        return _currentFaceList;
    }

    public List<AvatarItem> GetCurrentHairList()
    {
        return _currentHairList;
    }

    public List<string> HairColors
    {
        get { return _hairColors; }
    }

    public List<string> SkinColors
    {
        get { return _skinColors; }
    }
    #endregion
}