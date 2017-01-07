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
    Camera _camera;
    Canvas _canvas;
    RectTransform _movingAmmoRect;
    bool _movingAmmo;
    #endregion

    #region Unity Methods
    void Start()
    {
        _camera = GameObject.Find("Main Camera").GetComponent<Camera>();
        _canvas = GameObject.Find("Canvas").GetComponent<Canvas>();
    }

    void Update()
    {
        if (_movingAmmo)
        {
            MovingAmmo.transform.position = Input.mousePosition;
            /*
            Vector2 pos;
            RectTransformUtility.ScreenPointToLocalPointInRectangle(_canvas.transform as RectTransform, Input.mousePosition, _canvas.worldCamera, out pos);
            MovingAmmo.transform.position = _canvas.transform.TransformPoint(pos);
            //_movingAmmoRect.position = _camera.ScreenToViewportPoint(Input.mousePosition);
            */
        }
    }
    #endregion

    #region Methods
    public void ActivateMovingAmmo()
    {
        MovingAmmo.SetActive(true);
        //_movingAmmoRect = MovingAmmo.GetComponent<RectTransform>();
        _movingAmmo = true;
    }

    public void DeactivateMovingAmmo()
    {
        MovingAmmo.SetActive(false);
        _movingAmmo = false;
    }
    #endregion
}