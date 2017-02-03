using UnityEngine;
using UnityEngine.UI;
using System.Collections;
using System.Collections.Generic;
using gametheory.UI;

public class AvatarChoiceView : UIView 
{
    #region Events
    public static System.Action<AvatarItem> displayAvatarChoice;
    #endregion

    #region Constants
    const int BUTTON_COUNT = 5;
    const float SMALL_BUTTON_SIZE = 0.75f;
    const float SELECTED_COLOR = 0.7f;
    const float UNSELECTED_ALPHA = 0.4f;
    const string BODY_ICON_NAME = "Icon_Body_00";
    const string FACE_ICON_NAME = "faceIcon";
    const string HAIR_ICON_NAME = "hairIcon";
    const string HAIR_COLOR_ICON_NAME = "hairColorIcon";
    const string SKIN_COLOR_ICON_NAME = "skinColorIcon";
    #endregion

    #region Public Vars
    public HorizontalLayoutGroup NavButtonLayout;
    public AvatarNavButton NavButtonPrefab;
    public AvatarListItem ChoiceButtonPrefab;
    public UIList NavButtonList;
    public UIList ChoiceButtonList;
    public ExtendedButton NextButton;
    public ExtendedButton PreviousButton;
    #endregion

    #region Private Vars
    int _page;
    #endregion

    #region Overridden Methods
    protected override void OnInit()
    {
        base.OnInit();

        for (int i = 0; i < BUTTON_COUNT; i++)
        {
            AvatarNavButton avatarNavButton = Instantiate(NavButtonPrefab, Vector3.zero, Quaternion.identity) as AvatarNavButton;
            NavButtonList.AddListElement(avatarNavButton);

            switch (i)
            {
                case (int)AvatarItemType.BODY:
                    avatarNavButton.Disable();
                    //avatarNavButton.Button.image.color = new Color(SELECTED_COLOR, SELECTED_COLOR, SELECTED_COLOR);
                    avatarNavButton.Image.sprite = AssetLookUp.Instance.GetAvatarNavIcon(BODY_ICON_NAME);
                    break;
                case (int)AvatarItemType.FACE:
                    avatarNavButton.BGImage.color = new Color(1.0f, 1.0f, 1.0f, UNSELECTED_ALPHA);
                    avatarNavButton.Image.sprite = AssetLookUp.Instance.GetAvatarNavIcon(FACE_ICON_NAME);
                    break;
                case (int)AvatarItemType.HAIR:
                    avatarNavButton.BGImage.color = new Color(1.0f, 1.0f, 1.0f, UNSELECTED_ALPHA);
                    avatarNavButton.Image.sprite = AssetLookUp.Instance.GetAvatarNavIcon(HAIR_ICON_NAME);
                    break;
                case (int)AvatarItemType.HAIR_COLOR:
                    avatarNavButton.BGImage.color = new Color(1.0f, 1.0f, 1.0f, UNSELECTED_ALPHA);
                    avatarNavButton.Image.sprite = AssetLookUp.Instance.GetAvatarNavIcon(HAIR_COLOR_ICON_NAME);
                    break;
                case (int)AvatarItemType.SKIN_COLOR:
                    avatarNavButton.BGImage.color = new Color(1.0f, 1.0f, 1.0f, UNSELECTED_ALPHA);
                    avatarNavButton.Image.sprite = AssetLookUp.Instance.GetAvatarNavIcon(SKIN_COLOR_ICON_NAME);
                    break;
            }
            avatarNavButton.Setup(i);
        }

        _page = 0;

        NavButtonList.itemSelected += NavItemSelected;
        ChoiceButtonList.itemSelected += ChoiceItemSelected;
    }

    protected override void OnCleanUp()
    {
        base.OnCleanUp();

        NavButtonList.itemSelected -= NavItemSelected;
        ChoiceButtonList.itemSelected -= ChoiceItemSelected;
    }

    protected override void OnActivate()
    {
        base.OnActivate();

        PopulateChoiceButtons();
    }
    #endregion

    #region UI Methods
    public static AvatarChoiceView Load()
    {
        AvatarChoiceView view = UIView.Load("Views/AvatarChoiceView", OverriddenViewController.Instance.transform) as AvatarChoiceView;
        view.name = "AvatarChoiceView";
        return view;
    }

    void NavItemSelected(VisualElement element, object obj)
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.BUTTON_CLICK);

        _page = (int)obj;

        SetUpNavButtons();
    }

    void SetUpNavButtons()
    {
        for (int i = 0; i < BUTTON_COUNT; i++)
        {
            AvatarNavButton avatarNavButton = NavButtonList.ListItems[i] as AvatarNavButton;

            if (i != _page)
            {
                avatarNavButton.BGImage.color = new Color(1.0f, 1.0f, 1.0f, UNSELECTED_ALPHA);
                avatarNavButton.Enable();
            }
            else
            {
                avatarNavButton.BGImage.color = Color.white;
                avatarNavButton.Disable();
            }
        }
        ChoiceButtonList.ClearElements();
        PopulateChoiceButtons();

        if (_page == 0)
            PreviousButton.Deactivate();
        else
            PreviousButton.Activate();
        /*
        Debug.Log("here!");
        if (_page == (BUTTON_COUNT - 1))
            NextButton.Text = "Done";
        else
            NextButton.Text = "Next";
            */
    }

    void ChoiceItemSelected(VisualElement element, object obj)
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.SOFT_CLICK);

        AvatarItem item = obj as AvatarItem;

        int index = item.Index;
        for (int i = 0; i < ChoiceButtonList.ListItems.Count; i++)
        {
            AvatarListItem listItem = ChoiceButtonList.ListItems[i] as AvatarListItem;
            if (i == index)
            {
                listItem.GetItem.Equipped = true;
                listItem.Equip();
                //Debug.Log("now item " + i + " is equipped");
            }
            else
            {
                listItem.GetItem.Equipped = false;
                listItem.Unequip();
                //Debug.Log("now item " + i + " is unequipped");
            }
        }

        if (displayAvatarChoice != null)
            displayAvatarChoice(item);
    }

    void PopulateChoiceButtons()
    {
        //Debug.Log(_page);
        List<AvatarItem> avatarItems;
        if (_page != (int)AvatarItemType.FACE && _page != (int)AvatarItemType.HAIR)
            avatarItems = Database.Instance.GetAvatarItemList((AvatarItemType)_page);
        else
        {
            if (_page == (int)AvatarItemType.FACE)
                avatarItems = Database.Instance.GetCurrentFaceList();
            else
                avatarItems = Database.Instance.GetCurrentHairList();
        }
        bool foundEquipped = false;
        for (int i = 0; i < avatarItems.Count; i++)
        {
            avatarItems[i].Index = i;
            AvatarListItem avatarChoiceItem = Instantiate(ChoiceButtonPrefab, Vector3.zero, Quaternion.identity) as AvatarListItem;
            avatarChoiceItem.Setup(avatarItems[i]);
            ChoiceButtonList.AddListElement(avatarChoiceItem);
            if (avatarItems[i].Equipped)
            {
                avatarChoiceItem.Equip();
                foundEquipped = true;
            }
        }
        if (!foundEquipped)
        {
            avatarItems[0].Equipped = true;
            AvatarListItem listItem = ChoiceButtonList.ListItems[0] as AvatarListItem;
            listItem.Equip();
        }
    }

    public void ClickPreviousButton()
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.BUTTON_CLICK);

        _page--;
        if (_page <= 0)
        {
            _page = 0;
            PreviousButton.Deactivate();
        }
        /*
        if (_page < (BUTTON_COUNT - 1))
            NextButton.Activate();
            */
        SetUpNavButtons();
    }

    public void ClickNextButton()
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.BUTTON_CLICK);

        _page++;
        if (_page > (BUTTON_COUNT - 1))
        {
            StartCoroutine(PostInfo());
        }
        else
        {
            /*
            if (_page > 0)
                PreviousButton.Activate();
                */
            SetUpNavButtons();
        }
    }
    #endregion

    #region Coroutines
    IEnumerator PostInfo()
    {
        yield return StartCoroutine(OnlineManager.Instance.StartPutPlayer());

        yield return StartCoroutine(OnlineManager.Instance.StartPieceInfoPostCoroutine(true));

        UIViewController.DeactivateUIView("AvatarCreationView");
        UIViewController.DeactivateUIView("AvatarChoiceView");
    }
    #endregion
}