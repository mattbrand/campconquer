using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class AmmoBelt : MonoBehaviour 
{
    #region Public Vars
    public GameObject MovingAmmo;
    public Image MovingAmmoImage; 
    public AmmoDisplay[] AmmoDisplayArray;
    #endregion

    #region Private Vars
    AmmoDisplay _movingAmmoDisplay;
    AmmoDisplay _clickedAmmo;
    AmmoType[] _ammoTypeArray;
    bool _movingAmmo;
    #endregion

    #region Unity Methods
    void Update()
    {
        if (_movingAmmo)
        {
            MovingAmmo.transform.position = Input.mousePosition;
        }
    }
    #endregion

    #region Methods
    public void ActivateMovingAmmo(AmmoDisplay ammoDisplay)
    {
        MovingAmmoImage.sprite = ammoDisplay.AmmoImage.CurrentSprite;
        MovingAmmo.SetActive(true);
        _movingAmmo = true;
        _movingAmmoDisplay = ammoDisplay;

        _ammoTypeArray = new AmmoType[10];
        for (int i = 0; i < AmmoDisplayArray.Length; i++)
            _ammoTypeArray[i] = AmmoDisplayArray[i].Type;

        _clickedAmmo = ammoDisplay;
    }

    public void DeactivateMovingAmmo()
    {
        MovingAmmo.SetActive(false);
        //_movingAmmo = false;
        _movingAmmoDisplay = null;
    }

    public void EnterAmmo(AmmoDisplay ammoDisplay)
    {
        if (_movingAmmo)
        {
            //_lastAmmoDisplayEntered.Initialize(ammoDisplay.Type);
            //_lastAmmoDisplayEntered.ShowImage();
            AmmoType ammoType = ammoDisplay.Type;
            ammoDisplay.Initialize(_clickedAmmo.Type);
            _clickedAmmo.Initialize(ammoType);
            _movingAmmo = false;
        }
    }
    #endregion

    #region Accessors
    public AmmoDisplay MovingAmmoDisplay
    {
        get { return _movingAmmoDisplay; }
        set { _movingAmmoDisplay = value; }
    }
    #endregion
}