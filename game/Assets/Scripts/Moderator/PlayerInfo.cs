using UnityEngine;
using UnityEngine.UI;
using System.Collections;
using gametheory.UI;

public class PlayerInfo : VisualElement
{
    #region Constants
    const float X_FACTOR = 0.5f; //0.704f;
    const float Y_FACTOR = 0.5f; //0.4575f;
    #endregion

    #region Public Vars
    public Text PlayerName;
    public Image PlayerIndicator;
    public Image InfoBox;
    #endregion

    #region Private Vars
    Camera _camera;
    RectTransform _canvasRect;
    #endregion

    #region Methods
    public void Initialize(TeamColor color, string playerName)
    {
        _camera = GameObject.Find("Main Camera").GetComponent<Camera>();
        _canvasRect = GameObject.Find("Canvas").GetComponent<Canvas>().GetComponent<RectTransform>();

        if (color == TeamColor.RED)
            PlayerIndicator.color = Colors.RedBannerColor;
        else
            PlayerIndicator.color = Colors.BlueBannerColor;
        //InfoBox.text = playerName;
        //Debug.Log("before set name, width = " + PlayerName.rectTransform.sizeDelta.x);
        PlayerName.text = playerName;
        //Debug.Log("after set name, width = " + PlayerName.rectTransform.sizeDelta.x);
        //Debug.Log("before set box, width = " + InfoBox.rectTransform.sizeDelta.x);
        //InfoBox.rectTransform.sizeDelta = new Vector2(PlayerName.rectTransform.sizeDelta.x, InfoBox.rectTransform.sizeDelta.y);
        //Debug.Log("after set box, width = " + InfoBox.rectTransform.sizeDelta.x);
    }

    public void SetPosition(Vector2 position)
    {
        Vector2 ViewportPosition = _camera.WorldToViewportPoint(position);
        Vector2 WorldObject_ScreenPosition = new Vector2(((ViewportPosition.x * _canvasRect.sizeDelta.x) - (_canvasRect.sizeDelta.x * X_FACTOR)), ((ViewportPosition.y * _canvasRect.sizeDelta.y) - (_canvasRect.sizeDelta.y * Y_FACTOR)));
        PlayerIndicator.rectTransform.anchoredPosition3D = new Vector3(WorldObject_ScreenPosition.x, WorldObject_ScreenPosition.y, 0.0f);
    }
    #endregion
}