using UnityEngine;
using UnityEngine.UI;
using System;
using gametheory.UI;

public class AvatarCreationView : UIView 
{
    #region Enums
    enum AvatarCreationViewState { STATS = 0, GEAR}; 
    #endregion

    #region Public Vars
    public Image AvatarImage;
    public Image ShirtImage;
    public Image ShortsImage;
    public Image ShoesImage;
    public Image FaceImage;
    public Image HairImage;
    public ExtendedButton NextButton;
    //public ExtendedButton PreviousButton;
    #endregion

    #region Private Vars
    AvatarCreationViewState _state;
    #endregion

    #region Overridden Methods
    protected override void OnInit()
    {
        base.OnInit();

        _state = AvatarCreationViewState.STATS;
        AvatarStatsView.setNextButton += SetNextButton;
        AvatarChoiceView.displayAvatarChoice += DisplayAvatarChoice;
    }

    protected override void OnActivate()
    {
        base.OnActivate();

        Avatar.Instance.BodyType = AvatarBodyType.FEMALE;
        //Debug.Log("set body type to female");
        Database.Instance.BuildCurrentFaceList();
        Database.Instance.BuildCurrentHairList();
        Avatar.Instance.SkinColor = Database.Instance.SkinColors[0];
        AvatarImage.color = Colors.HexToColor(Database.Instance.SkinColors[0]);
        Avatar.Instance.FaceAsset = Database.Instance.GetCurrentFaceList()[0].ObjectId;
        Avatar.Instance.HairAsset = Database.Instance.GetCurrentHairList()[0].ObjectId;
        Avatar.Instance.HairColor = Database.Instance.HairColors[0];
        HairImage.color = Colors.HexToColor(Database.Instance.HairColors[0]);

        // set shirt color to team color
        if (Avatar.Instance.Color == TeamColor.RED)
            ShirtImage.color = Colors.RedShirtColor;
        else
            ShirtImage.color = Colors.BlueShirtColor;
        //Debug.Log("face = " + Avatar.Instance.FaceAsset + " hair = " + Avatar.Instance.HairAsset);
    }

    protected override void OnCleanUp()
    {
        base.OnCleanUp();

        AvatarStatsView.setNextButton -= SetNextButton;
        AvatarChoiceView.displayAvatarChoice -= DisplayAvatarChoice;
    }
    #endregion

    #region UI Methods
    public static AvatarCreationView Load()
    {
        AvatarCreationView view = UIView.Load("Views/AvatarCreationView", OverriddenViewController.Instance.transform) as AvatarCreationView;
        view.name = "AvatarCreationView";
        return view;
    }

    void SetNextButton(bool show)
    {
        if (show)
            NextButton.Activate();
        else
            NextButton.Deactivate();
    }

    public void ClickNextButton()
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.BUTTON_CLICK);

        if (_state == AvatarCreationViewState.STATS)
        {
            UIViewController.DeactivateUIView("AvatarStatsView");
            UIViewController.ActivateUIView(AvatarChoiceView.Load());
            NextButton.Deactivate();
            _state = AvatarCreationViewState.GEAR;
        }
    }

    void DisplayAvatarChoice(AvatarItem item)
    {
        AvatarItemType type = (AvatarItemType)Enum.Parse(typeof(AvatarItemType), item.Type);
        switch (type)
        {
            case AvatarItemType.BODY:
                AvatarImage.sprite = AssetLookUp.Instance.GetAvatarBody(item.ObjectId);
                Avatar.Instance.BodyType = (AvatarBodyType)Enum.Parse(typeof(AvatarBodyType), item.BodyType, true);
                //Debug.Log("set body type to " + Avatar.Instance.BodyType);
                //Debug.Log("set body type to " + Avatar.Instance.BodyType);
                ShirtImage.sprite = AssetLookUp.Instance.GetAvatarClothes(Database.Instance.GetShirtAssetForBodyType(Avatar.Instance.BodyType));
                ShortsImage.sprite = AssetLookUp.Instance.GetAvatarClothes(Database.Instance.GetShortsAssetForBodyType(Avatar.Instance.BodyType));
                Database.Instance.BuildCurrentFaceList();
                Database.Instance.BuildCurrentHairList();
                Database.Instance.BuildCurrentGearList();
                //Debug.Log("getting hair " + Database.Instance.GetCurrentHairList()[0].ObjectId);
                FaceImage.sprite = AssetLookUp.Instance.GetAvatarFace(Database.Instance.GetCurrentFaceList()[0].ObjectId);
                Avatar.Instance.FaceAsset = Database.Instance.GetCurrentFaceList()[0].ObjectId;
                HairImage.sprite = AssetLookUp.Instance.GetAvatarHair(Database.Instance.GetCurrentHairList()[0].ObjectId);
                Avatar.Instance.HairAsset = Database.Instance.GetCurrentHairList()[0].ObjectId;
                break;
            case AvatarItemType.FACE:
                FaceImage.sprite = AssetLookUp.Instance.GetAvatarFace(item.ObjectId);
                Avatar.Instance.FaceAsset = item.ObjectId;
                break;
            case AvatarItemType.SKIN_COLOR:
                AvatarImage.color = Colors.HexToColor(item.Color);
                Avatar.Instance.SkinColor = item.Color;
                FaceImage.color = Colors.HexToColor(item.FaceColor);
                break;
            case AvatarItemType.HAIR:
                HairImage.sprite = AssetLookUp.Instance.GetAvatarHair(item.ObjectId);
                Avatar.Instance.HairAsset = item.ObjectId;
                break;
            case AvatarItemType.HAIR_COLOR:
                HairImage.color = Colors.HexToColor(item.Color);
                Avatar.Instance.HairColor = item.Color;
                break;
        }
    }
    #endregion
}