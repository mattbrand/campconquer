using UnityEngine;
using gametheory.Utilities;

#region Enums
public enum AvatarItemType { BODY = 0, SKIN_COLOR, HAIR_COLOR, FACE, HAIR };
#endregion

public class AvatarItem
{
    #region Public Vars
    public int Index;
    public bool Equipped;

    [CSVColumn("ObjectId")]
    public string ObjectId;

    [CSVColumn("Type")]
    public string Type;

    [CSVColumn("Body Type")]
    public string BodyType;

    [CSVColumn("Icon Name")]
    public string IconName;

    [CSVColumn("Name")]
    public string Name;

    [CSVColumn("Color")]
    public string Color;

    [CSVColumn("Face Color")]
    public string FaceColor;

    [CSVColumn("Shirt Asset")]
    public string ShirtAsset;

    [CSVColumn("Shorts Asset")]
    public string ShortsAsset;
    #endregion

    #region Constructors
    public AvatarItem() { }
    #endregion

    #region Methods
    public Sprite GetIcon()
    {
        return AssetLookUp.Instance.GetAvatarIcon(IconName);
    }
    #endregion
}