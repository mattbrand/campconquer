using UnityEngine;
using System.Collections;

public static class Utilities 
{
    #region Constants
    const float CLOSE_X = 0.085f;
    const float CLOSE_Y = 0.085f;
    #endregion

    #region Methods
    public static bool CloseEnough(Vector2 pos1, Vector2 pos2)
    {
        float x = Mathf.Abs(pos1.x - pos2.x);
        float y = Mathf.Abs(pos1.y - pos2.y);
        if (x <= CLOSE_X && y <= CLOSE_Y)
            return true;
        return false;
    }

    public static float RoundToDecimals(float number, int decimals)
    {
        return (Mathf.Round(number * Mathf.Pow(10.0f, decimals)) / Mathf.Pow(10.0f, decimals));
    }

    public static string OneOrZero(bool yes)
    {
        if (yes)
        {
            return "1";
        }
        else {
            return "0";
        }
    }
    #endregion
}