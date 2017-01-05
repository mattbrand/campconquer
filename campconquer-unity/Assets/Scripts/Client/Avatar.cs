//#define CLEAR_DATA

using UnityEngine;
using System.Collections.Generic;
using Newtonsoft.Json;
using CampConquer;
using gametheory;

#region Enums
public enum AvatarBodyType { FEMALE = 0, GENDER_NEUTRAL_1, GENDER_NEUTRAL_2, MALE };
#endregion

public class Avatar : MonoBehaviour, IBindingContext
{
    #region Events
    public event System.Action<object, string> propertyChanged;
    #endregion

    #region Constants
    const string DATA_KEY = "data";
    const string PURCHASED_KEY = "itemsPurchased";
    const string EQUIPPED_KEY = "itemsEquipped";
    const string PLAYER_ID_KEY = "playerId";
    const int MAX_STEPS = 10000;
    const int MAX_COINS = 1000;
    #endregion

    #region Public Vars
    public static Avatar Instance;
    #endregion

    #region Private Vars
    UserData _data;
    AmmoBandelier _ammoBandelier;
    TeamColor _color;
    PieceType _type;
    PieceRole _role;
    Path _path;
    Vector2 _position;
    string _lastSync;
    #endregion

    #region Unity Methods
    void Awake()
    {
#if CLEAR_DATA
        PlayerPrefs.DeleteAll();
#endif

        if (Instance == null)
        {
            Instance = this;

            //LoadData();
            _data = new UserData();

            // default for null ref exc because of no hairs
            HairAsset = "";
            HairColor = "";

            _ammoBandelier = new AmmoBandelier();
            EquippedIDs = new List<string>();
            PurchasedIDs = new List<string>();
        }
        else
        {
            Destroy(gameObject);
        }
    }
    #endregion

    #region Initialization Methods
    public void SetAvatarStats(int health, int speed, int range)
    {
        _data.Health = health;
        _data.Speed = speed;
        _data.Range = range;
    }
    #endregion

    #region Store Methods
    public void AddEquippedItem(string id)
    {
        if (!EquippedIDs.Contains(id))
            EquippedIDs.Add(id);
    }

    public void RemoveEquippedItem(string id)
    {
        if (EquippedIDs.Contains(id))
            EquippedIDs.Remove(id);
    }

    public void AddPurchasedItem(string id)
    {
        if (!PurchasedIDs.Contains(id))
            PurchasedIDs.Add(id);
    }

    public bool CanSpendCoins(int coins)
    {
        return (_data.Coins >= coins);
    }

    public bool CanSpendGems(int gems)
    {
        return (_data.Gems >= gems);
    }

    public void Spend(int coins, int gems)
    {
        Coins -= coins;
        if (Coins < 0)
            Coins = 0;

        Gems -= gems;
        if (Gems < 0)
            Gems = 0;
    }

    public void AddAmmo(AmmoType ammoType)
    {
        _ammoBandelier.AddAmmo(ammoType);
        _data.AmmoList.Add(ammoType);
    }

    public int GetTotalHealth()
    {
        return _data.Health + _data.HealthBonus;
    }

    public int GetTotalSpeed()
    {
        return _data.Speed + _data.SpeedBonus;
    }

    public int GetTotalRange()
    {
        return _data.Range + _data.RangeBonus;
    }
    #endregion

    #region Accessors
    public PieceType Type
    {
        get { return _type; }
        set { _type = value; }
    }

    public PieceRole Role
    {
        get { return _role; }
        set { _role = value; }
    }

    public TeamColor Color
    {
        get { return _color; }
        set { _color = value; }
    }

    public AmmoBandelier Ammo
    {
        get { return _ammoBandelier; }
        set { _ammoBandelier = value; }
    }

    public int Health
    {
        get { return _data.Health; }
        set { _data.Health = value; }
    }

    public int Speed
    {
        get { return _data.Speed; }
        set { _data.Speed = value; }
    }

    public int Range
    {
        get { return _data.Range; }
        set { _data.Range = value; }
    }

    public int HealthBonus
    {
        get { return _data.HealthBonus; }
        set { _data.HealthBonus = value; }
    }

    public int SpeedBonus
    {
        get { return _data.SpeedBonus; }
        set { _data.SpeedBonus = value; }
    }

    public int RangeBonus
    {
        get { return _data.RangeBonus; }
        set { _data.RangeBonus = value; }
    }

    public Vector2 Position
    {
        get { return _position; }
        set { _position = value; }
    }

    public Path Path
    {
        get { return _path; }
        set { _path = value; }
    }

    public string Name
    {
        get { return _data.Name; }
        set { _data.Name = value; }
    }

    public int Coins
    {
        get { return _data.Coins; }
        set
        {
            if (_data.Coins != value)
            {
                _data.Coins = value;
                if (propertyChanged != null)
                    propertyChanged(this, "Coins");
            }
        }
    }

    public int Gems
    {
        get { return _data.Gems; }
        set
        {
            if (_data.Gems != value)
            {
                _data.Gems = value;
                if (propertyChanged != null)
                    propertyChanged(this, "Gems");
            }
        }
    }

    public int Steps
    {
        get { return _data.Steps; }
        set 
        {
            if (value > MAX_STEPS)
                _data.Steps = MAX_STEPS;
            else
                _data.Steps = value; 
        }
    }

    public int GemsAvailable
    {
        get { return _data.GemsAvailable; }
        set { _data.GemsAvailable = value; }
    }

    public int ActiveMins
    {
        get { return _data.ActiveMins; }
        set { _data.ActiveMins = value; }
    }

    /*
    public bool ActiveMet
    {
        get { return _data.ActiveMet; }
        set { _data.ActiveMet = value; }
    }

    public bool ActiveClaimed
    {
        get { return _data.ActiveClaimed; }
        set { _data.ActiveClaimed = value; }
    }
    */

    public AvatarBodyType BodyType
    {
        get { return _data.BodyType; }
        set { _data.BodyType = value; }
    }

    public string SkinColor
    {
        get { return _data.SkinColor; }
        set { _data.SkinColor = value; }
    }

    public string FaceAsset
    {
        get { return _data.FaceAsset; }
        set { _data.FaceAsset = value; }
    }

    public string HairAsset
    {
        get { return _data.HairAsset; }
        set { _data.HairAsset = value; }
    }

    public string HairColor
    {
        get { return _data.HairColor; }
        set { _data.HairColor = value; }
    }

    public string GearHairAsset
    {
        get { return _data.GearHairAsset; }
        set { _data.GearHairAsset = value; }
    }

    public List<string> EquippedIDs
    {
        get { return _data.EquippedIDs; }
        set { _data.EquippedIDs = value; }
    }

    public List<string> PurchasedIDs
    {
        get { return _data.PurchasedIDs; }
        set { _data.PurchasedIDs = value; }
    }

    public bool Embodied
    {
        get { return _data.Embodied; }
        set { _data.Embodied = value; }
    }
    #endregion
}

public class UserData
{
    #region Constants
    const int START_COINS = 80;
    const int START_GEMS = 0;
    #endregion

    #region Public Vars
    public List<string> EquippedIDs;
    public List<string> PurchasedIDs;
    public int Health;
    public int Speed;
    public int Range;
    public int HealthBonus;
    public int SpeedBonus;
    public int RangeBonus;
    public int Coins;
    public int Gems;
    public int GemsAvailable;
    public bool Embodied;
    public int ActiveMins;
    public int Steps;
    //public bool ActiveMet;
    //public bool ActiveClaimed;
    public string Name = "";
    public string SkinColor;
    public string FaceAsset;
    public string HairAsset;
    public string HairColor;
    public string GearHairAsset;
    public AvatarBodyType BodyType;

    public List<AmmoType> AmmoList;
    #endregion

    #region Constructor
    public UserData() 
    {
        AmmoList = new List<AmmoType>();
    }
    #endregion

    #region Methods
    public void Initialize()
    {
        Coins = START_COINS;
        Gems = START_GEMS;
    }
    #endregion
}