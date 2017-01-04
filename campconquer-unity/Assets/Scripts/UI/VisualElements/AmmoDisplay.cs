﻿using UnityEngine;
using UnityEngine.UI;
using gametheory.UI;

public class AmmoDisplay : VisualElement 
{
    #region Events
    public static System.Action<AmmoDisplay> ClickAmmo;
    #endregion

    #region Public Vars
    public Sprite RedBalloonSprite;
    public Sprite BlueBalloonSprite;
    public Sprite RedArrowSprite;
    public Sprite BlueArrowSprite;
    public Sprite RedBombSprite;
    public Sprite BlueBombSprite;
    public ExtendedImage AmmoImage;
    public Image Highlight;
    #endregion

    #region Private Vars
    AmmoType _type;
    bool _selected;
    bool _set = false;
    #endregion

	#region Unity Methods
	void Start()
    {
        enabled = false;
	}
    #endregion

    #region Methods
    public void Initialize(AmmoType type)
    {
        switch (type)
        {
            case AmmoType.BALLOON:
                if (Avatar.Instance.Color == TeamColor.BLUE)
                    AmmoImage.Image.sprite = AssetLookUp.Instance.BlueBalloons[0];
                break;
            case AmmoType.ARROW:
                if (Avatar.Instance.Color == TeamColor.BLUE)
                    AmmoImage.Image.sprite = AssetLookUp.Instance.BlueBalloons[1];
                else
                    AmmoImage.Image.sprite = AssetLookUp.Instance.RedBalloons[1];
                break;
            case AmmoType.BOMB:
                if (Avatar.Instance.Color == TeamColor.BLUE)
                    AmmoImage.Image.sprite = AssetLookUp.Instance.BlueBalloons[2];
                else
                    AmmoImage.Image.sprite = AssetLookUp.Instance.RedBalloons[2];
                break;
        }
        _selected = false;
        _type = type;
        _set = true;
        //Debug.Log("initialize ammo with type " + type);
        AmmoImage.Activate();
    }

    public void Click()
    {
        if (ClickAmmo != null)
            ClickAmmo(this);
    }

    public void Select()
    {
        _selected = true;
        Highlight.enabled = true;
    }

    public void Unselect()
    {
        _selected = false;
        Highlight.enabled = false;
    }

    public void Delete()
    {
        Destroy(this.gameObject);
    }

    public void Clear()
    {
        AmmoImage.Deactivate();
    }
    #endregion

    #region Accessors
    public bool Selected
    {
        get { return _selected; }
        set { _selected = value; }
    }

    public AmmoType Type
    {
        get { return _type; }
        set { _type = value; }
    }

    public bool Set
    {
        get { return _set; }
    }
    #endregion
}