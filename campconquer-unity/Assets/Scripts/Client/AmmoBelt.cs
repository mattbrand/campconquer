using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AmmoBelt : MonoBehaviour 
{
    #region Public Vars
    public GameObject MovingAmmo;
    public AmmoDisplay[] AmmoDisplayArray;
    #endregion

    #region Private Vars
    AmmoDisplay _movingAmmoDisplay;
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
        MovingAmmo.SetActive(true);
        _movingAmmo = true;
        _movingAmmoDisplay = ammoDisplay;
    }

    public void DeactivateMovingAmmo()
    {
        MovingAmmo.SetActive(false);
        _movingAmmo = false;
        _movingAmmoDisplay = null;
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