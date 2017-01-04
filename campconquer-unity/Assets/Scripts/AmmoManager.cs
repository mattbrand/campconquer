using UnityEngine;
using System.Collections.Generic;
using gametheory.Utilities;

public enum AmmoType { BALLOON = 0, ARROW, BOMB };

public class AmmoManager : MonoBehaviour
{
    #region Constants
    const string AMMO_FILE_PATH = "Database - Ammo";
    #endregion

    #region Public Vars
    public static AmmoManager Instance;
    #endregion

    #region Private Vars
    List<AmmoData> _ammoDataList;
    #endregion

    #region Unity Methods
    void Start()
    {
        if (Instance == null)
        {
            Instance = this;

            enabled = false;
            LoadAmmoData();
        }
        else
        {
            Destroy(gameObject);
        }
    }
    #endregion

    #region Methods
    void LoadAmmoData()
    {
        _ammoDataList = CSVImporter.GenerateList<AmmoData>(AssetBundleSync.Instance.GetFile(AMMO_FILE_PATH));

        /*
        for (int i = 0; i < _ammoList.Count; i++)
        {
            Debug.Log(_ammoList[i].Type + " " + _ammoList[i].Cost);
        }
        */
    }

    public AmmoData GetAmmoData(int index)
    {
        return _ammoDataList[index];
    }
    #endregion

    #region Accessors
    public List<AmmoData> AmmoDataList
    {
        get { return _ammoDataList; }
    }
    #endregion
}

public class AmmoBandelier
{
    #region Constants
    const int MAX_AMMO = 10;
    #endregion

    #region Private Vars
    List<AmmoType> _ammoList;
    #endregion

    #region Methods
    public AmmoBandelier()
    {
        _ammoList = new List<AmmoType>();
    }

    public AmmoType GetNextAmmo()
    {
        AmmoType type = _ammoList[0];
        _ammoList.RemoveAt(0);
        return type;
    }

    public void AddAmmo(AmmoType type)
    {
        if (_ammoList.Count < MAX_AMMO)
            _ammoList.Add(type);
    }

    public int AmmoCount()
    {
        return _ammoList.Count;
    }

    public AmmoType GetNextAmmoType()
    {
        return _ammoList[0];
    }

    public void PopulateAmmoList(List<AmmoType> ammoList)
    {
        _ammoList = new List<AmmoType>();
        for (int i = 0; i < ammoList.Count; i++)
        {
            _ammoList.Add(ammoList[i]);
        }
    }
    #endregion

    #region Accessors
    public List<AmmoType> AmmoList
    {
        get { return _ammoList; }
        set { _ammoList = value; }
    }
    #endregion
}

public class AmmoData 
{
    #region Public Vars
    [EnumConverter(typeof(AmmoType))]
    public AmmoType Type;

    public int Cost;

    public int RangeBonus;

    public int Damage;

    public int SplashDamage;

    public float SplashRadius;
    #endregion
}