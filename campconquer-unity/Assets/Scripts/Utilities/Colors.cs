using UnityEngine;

public static class Colors 
{
    #region Vars
    // avatar stats button colors
    public static Color ActiveColor = new Color(0.98f, 0.60f, 0.17f, 1.0f);
    public static Color InactiveColor = new Color(0.24f, 0.13f, 0.18f, 0.5f);
    public static Color PreviewColor = new Color(0.24f, 0.13f, 0.18f, 1.0f);

    // character skin colors
    public static Color LightestSkin = new Color(0.94f, 0.85f, 0.8f);
    public static Color LightSkin = new Color(0.71f, 0.6f, 0.53f);
    public static Color MediumSkin = new Color(0.64f, 0.41f, 0.27f);
    public static Color DarkSkin = new Color(0.45f, 0.22f, 0.16f);
    public static Color DarkestSkin = new Color(0.24f, 0.10f, 0.07f);

    // shirt colors
    public static Color RedShirtColor = new Color(0.95f, 0.11f, 0.17f);
    public static Color BlueShirtColor = new Color(0.33f, 0.45f, 0.90f);

    // banner colors
    public static Color RedBannerColor = new Color(0.85f, 0.13f, 0.22f);
    public static Color BlueBannerColor = new Color(0.11f, 0.47f, 0.85f);
    public static Color PurpleBannerColor = new Color(0.43f, 0.33f, 0.58f);
    #endregion

    #region Methods
    public static Color HexToColor(string hex)
    {
        //Debug.Log(hex);
        if (hex == null || hex == "")
            return Color.white;
        byte r = byte.Parse(hex.Substring(0, 2), System.Globalization.NumberStyles.HexNumber);
        byte g = byte.Parse(hex.Substring(2, 2), System.Globalization.NumberStyles.HexNumber);
        byte b = byte.Parse(hex.Substring(4, 2), System.Globalization.NumberStyles.HexNumber);
        return new Color32(r, g, b, 255);
    }
    #endregion
}