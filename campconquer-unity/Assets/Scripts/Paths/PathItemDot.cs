using UnityEngine;
using TextFx;
using UnityEngine.UI;

public class PathItemDot : MonoBehaviour 
{
    #region Constants
    const float LARGE_DOT_SCALE = 1.5f;
    const float SMALL_DOT_SCALE = 1.2f;
    #endregion

    #region Private Vars
    PathItem _pathItem;
    bool _selected = false;
    #endregion

    #region Unity Methods
    void Start()
    {
        /*
        Camera myCamera = GameObject.Find("Main Camera").GetComponent<Camera>();
        Canvas myCanvas = GameObject.Find("Canvas").GetComponent<Canvas>();
        _testText = (Text)Instantiate(PathTextPrefab, Vector3.zero, Quaternion.identity);
        _testText.transform.SetParent(myCanvas.transform, false);
        RectTransform CanvasRect = myCanvas.GetComponent<RectTransform>();
        Vector2 ViewportPosition = myCamera.WorldToViewportPoint(this.transform.position);
        Vector2 WorldObject_ScreenPosition = new Vector2(((ViewportPosition.x * CanvasRect.sizeDelta.x) - (CanvasRect.sizeDelta.x * 0.685f)), ((ViewportPosition.y * CanvasRect.sizeDelta.y) - (CanvasRect.sizeDelta.y * 0.44f)));
        _testText.rectTransform.anchoredPosition3D = new Vector3(WorldObject_ScreenPosition.x, WorldObject_ScreenPosition.y, 0.0f);
        */
    }

    void OnMouseUp()
    {
        /*
        if (!_selected && PathView.Instance.CanClick)
            _pathItem.ClickDot();
            */
    }
    #endregion

    #region Methods
    public void SetPathItem(PathItem pathItem)
    {
        _pathItem = pathItem;
    }

    public void Select()
    {
        _selected = true;
        transform.localPosition = new Vector3(transform.localPosition.x, transform.localPosition.y, -9.51f);
        transform.localScale = new Vector3(LARGE_DOT_SCALE, LARGE_DOT_SCALE, LARGE_DOT_SCALE);
    }

    public void Unselect()
    {
        _selected = false;
        transform.localPosition = new Vector3(transform.localPosition.x, transform.localPosition.y, -9.5f);
        transform.localScale = new Vector3(SMALL_DOT_SCALE, SMALL_DOT_SCALE, SMALL_DOT_SCALE);
    }
    #endregion
}