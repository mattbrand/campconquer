using UnityEngine;
using gametheory.Utilities;

public enum GearType { NONE = 0, HEAD, SHIRT, SHOES, ACCESSORY };

public class StoreItem 
{
	#region Public Vars
	public bool Purchased;
	public bool Equipped;

	[CSVColumn("Name")]
	public string Name;

    [CSVColumn("Type")]
    public string Type;

    [CSVColumn("Body Type")]
    public string BodyType;

    [CSVColumn("Display Name")]
	public string DisplayName;

	[CSVColumn("Description")]
	public string Description;

	[CSVColumn("Asset Name")]
	public string AssetName;

	[CSVColumn("Icon Name")]
	public string IconName;

	[CSVColumn("Coins")]
	public int Coins;

    [CSVColumn("Gems")]
    public int Gems;

	[CSVColumn("Level")]
	public int Level;

    [CSVColumn("Health Bonus")]
    public int HealthBonus;

    [CSVColumn("Speed Bonus")]
    public int SpeedBonus;

    [CSVColumn("Range Bonus")]
    public int RangeBonus;

    [CSVColumn("Hair")]
    public string Hair;

    [CSVColumn("Owned By Default")]
    public int OwnedByDefault;

    [CSVColumn("Equipped By Default")]
    public int EquippedByDefault;

    [CSVColumn("Color Decal")]
    public bool ColorDecal;
	#endregion

	#region Constructors
	public StoreItem(){}
	#endregion

	#region Methods
	public Sprite GetIcon()
	{
		return AssetLookUp.Instance.GetGearIcon(IconName);
	}
	#endregion
}