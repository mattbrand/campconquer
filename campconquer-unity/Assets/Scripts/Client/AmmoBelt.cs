using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class AmmoBelt : MonoBehaviour 
{
    #region Constants
    const float BOX_SIZE = 20.0f;
    #endregion

    #region Public Vars
    public GameObject MovingAmmo;
    public GameObject TempAmmo;
    public Image MovingAmmoImage;
    public Image TempAmmoImage;
    public AmmoDisplay[] AmmoDisplayArray;
    #endregion

    #region Private Vars
    AmmoDisplay _movingAmmoDisplay;
    AmmoType[] _ammoTypeArray;
    bool _movingAmmo;
    bool _tempAmmoActive;
    #endregion

    #region Unity Methods
    void Start()
    {
        _tempAmmoActive = false;
        _movingAmmo = false;
    }

    void Update()
    {
        //Debug.Log(_movingAmmo + " " + Input.GetMouseButtonUp(0));
        if (_movingAmmo)
        {
            AmmoDisplay ammoOverlap = null;
            for (int i = 0; i < AmmoDisplayArray.Length; i++)
            {
                if (CheckWithinBounds(Input.mousePosition, AmmoDisplayArray[i]))
                    ammoOverlap = AmmoDisplayArray[i];
                else
                {
                    if (AmmoDisplayArray[i] != _movingAmmoDisplay)
                        AmmoDisplayArray[i].ShowImage();
                }
            }

            if (!Input.GetMouseButton(0))
            {
                if (ammoOverlap != null && ammoOverlap.Set)
                {
                    //Debug.Log("switch " + ammoOverlap.name + " with " + _movingAmmoDisplay.name);
                    SwitchAmmo(ammoOverlap);
                    if (_tempAmmoActive)
                        DeactivateTempAmmo();
                }
                else
                {
                    //Debug.Log("revert");
                    RevertAmmo();
                    if (_tempAmmoActive)
                        DeactivateTempAmmo();
                }
            }
            else
            {
                if (ammoOverlap != null && ammoOverlap.Set)
                {
                    MovingAmmo.transform.position = ammoOverlap.transform.position;
                    ammoOverlap.HideImage();
                    //Debug.Log("activating temp ammo with " + _movingAmmoDisplay.name);
                    if (_movingAmmoDisplay != ammoOverlap)
                        ActivateTempAmmo(ammoOverlap, _movingAmmoDisplay.transform.position);
                }
                else
                {
                    MovingAmmo.transform.position = Input.mousePosition;
                    if (_tempAmmoActive)
                        DeactivateTempAmmo();
                }
            }
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
    }

    public void DeactivateMovingAmmo()
    {
        MovingAmmo.SetActive(false);
        //_movingAmmoDisplay = null;
    }

    public void SwitchAmmo(AmmoDisplay ammoDisplay)
    {
        if (_movingAmmo)
        {
            //Debug.Log("switch ammoDisplay = " + ammoDisplay.Type + " with movingAmmoDisplay = " + _movingAmmoDisplay.Type);
            //_lastAmmoDisplayEntered.ShowImage();
            DeactivateMovingAmmo();
            AmmoType ammoType = ammoDisplay.Type;
            ammoDisplay.Initialize(_movingAmmoDisplay.Type);
            _movingAmmoDisplay.Initialize(ammoType);
            _movingAmmo = false;
            _movingAmmoDisplay = null;

            for (int i = 0; i < AmmoDisplayArray.Length; i++)
            {
                if (AmmoDisplayArray[i].Set)
                    Avatar.Instance.Ammo.AmmoList[i] = AmmoDisplayArray[i].Type;
            }

            LoadingAlert.Present();
            StartCoroutine(SendAmmoArrangeToServer());
        }
    }

    public void RevertAmmo()
    {
        if (_movingAmmo)
        {
            DeactivateMovingAmmo();
            _movingAmmoDisplay.ShowImage();
            _movingAmmo = false;
            _movingAmmoDisplay = null;
        }
    }

    bool CheckWithinBounds(Vector2 position, AmmoDisplay ammoDisplay)
    {
        if (position.x >= ammoDisplay.transform.position.x - BOX_SIZE && position.x <= ammoDisplay.transform.position.x + BOX_SIZE &&
            position.y >= ammoDisplay.transform.position.y - BOX_SIZE && position.y <= ammoDisplay.transform.position.y + BOX_SIZE)
            return true;
        return false;
    }

    void ActivateTempAmmo(AmmoDisplay ammoDisplay, Vector2 position)
    {
        TempAmmo.SetActive(true);
        TempAmmo.transform.position = position;
        TempAmmoImage.sprite = ammoDisplay.AmmoImage.CurrentSprite;
        _tempAmmoActive = true;
    }

    void DeactivateTempAmmo()
    {
        TempAmmo.SetActive(false);
        _tempAmmoActive = false;
    }
    #endregion

    #region Coroutines
    IEnumerator SendAmmoArrangeToServer()
    {
        yield return StartCoroutine(OnlineManager.Instance.StartArrangeAmmo());
        LoadingAlert.FinishLoading();
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