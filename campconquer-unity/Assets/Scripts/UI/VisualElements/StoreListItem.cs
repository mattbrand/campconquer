using UnityEngine;
using UnityEngine.UI;
using gametheory.UI;

public class StoreListItem : ListElement 
{
	#region Constants
	const string GOAL_PATH = "GoalImage";
	#endregion

	#region Events
	public static event System.Action<StoreListItem> selected;
	#endregion

	#region Public Vars
	public bool Locked;
	public Image Icon;
	public Button ActionButton;
	#endregion

	#region Private Vars
	Image _goalImage;
	bool _selected;
	static Color PurchasedColor = UnityExtensions.ColorFromRGB(195,195,195);
	static Color LockedColor = UnityExtensions.ColorFromRGB(80,80,80);
	#endregion

	#region Overridden Methods
	public override void PresentVisuals (bool display)
	{
		base.PresentVisuals (display);

		if(Icon)
			Icon.enabled = display;

		if(ActionButton)
		{
			ActionButton.enabled = display;
			ActionButton.image.enabled = display;
		}

		if(_goalImage)
			_goalImage.enabled = display;
	}
	public override void Setup (object obj)
	{
		base.Setup (obj);
		StoreItem item = obj as StoreItem;

        Icon.sprite = item.GetIcon();

        /*
		if(item.Level <= Player.Instance.Level && 
			(!item.Hidden || item.Hidden && item.Purchased))
		{
			Icon.sprite = item.GetIcon();

			if(IsGoal)
			{
				_goalImage = (Image)GameObject.Instantiate(Resources.Load<Image>(GOAL_PATH)
					,Vector3.zero,Quaternion.identity);
				_goalImage.rectTransform.SetParent(transform,false);
			}
		}
		else
		{
			Locked = true;
			Icon.sprite = AssetLookUp.Instance.Locked;
			ActionButton.interactable = false;
			ActionButton.image.color = LockedColor;
		}
  */      
		
		SetBackground();
	}
	protected override void OnSelected ()
	{
		if(!_selected)
		{
			_selected = true;

			base.OnSelected ();

			ActionButton.image.sprite = AssetLookUp.Instance.StoreSelected;

			if(selected != null)
				selected(this);
		}
	}
	#endregion

	#region Methods
	public void Unselect()
	{
		_selected = false;
		SetBackground();
	}
	public void SetBackground()
	{
		if((_obj as StoreItem).Purchased)
			ActionButton.image.sprite = AssetLookUp.Instance.StorePurchased;
		else
			ActionButton.image.sprite = AssetLookUp.Instance.StoreNormal;
	}
	#endregion
}
