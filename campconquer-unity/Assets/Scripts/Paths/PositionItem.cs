using UnityEngine;
using UnityEngine.UI;
using CampConquer;

public class PositionItem : MonoBehaviour 
{
    #region Events
    public static System.Action<PositionItem> clickPosition;
    #endregion

    #region Constants
    const float LARGE_DOT_SCALE = 1.0f;
    const float SMALL_DOT_SCALE = 0.75f;
    const float X_FACTOR = 0.704f;
    const float Y_FACTOR = 0.4575f;
    const float UNSELECTED_LINE_ALPHA = 0.25f;
    #endregion

    #region Public Vars
    public SpriteRenderer SpriteRend;
    //public SpriteRenderer BodySpriteRend;
    //public SpriteRenderer HairSpriteRend;
    //public SpriteRenderer ShirtSpriteRend;
    //public SpriteRenderer ShortsSpriteRend;
    public Text PositionTextPrefab;
    #endregion

    #region Private Vars
    Text _countText;
    Color _pulseColor;
    Vector2 _position;
    float _alpha;
    int _count;
    int _dir;
    bool _selected;
    bool _pulse;
	public static bool CanClick = true;
    #endregion

    #region Unity Methods
    void Update()
    {
        if (_pulse)
        {
            if (_dir == 1)
            {
                _alpha += 0.05f;
                if (_alpha >= 1.0f)
                {
                    _alpha = 1.0f;
                    _dir = -1;
                }
            }
            else
            {
                _alpha -= 0.05f;
                if (_alpha <= UNSELECTED_LINE_ALPHA)
                {
                    _alpha = UNSELECTED_LINE_ALPHA;
                    _dir = 1;
                }
            }
            _pulseColor.a = _alpha;
            SpriteRend.color = _pulseColor;
        }
    }

    void OnMouseUp()
    {
		if (CanClick && !_selected)
        {
            if (clickPosition != null)
                clickPosition(this);
        }
    }
    #endregion

    #region Methods
    public void Init(DefensePos defensePos)
    {
        Vector2 position = new Vector2(defensePos.Point.x, defensePos.Point.y);

        // create count text
        Camera myCamera = GameObject.Find("Main Camera").GetComponent<Camera>();
        Canvas myCanvas = GameObject.Find("Canvas").GetComponent<Canvas>();
        _countText = (Text)Instantiate(PositionTextPrefab, Vector3.zero, Quaternion.identity);
        _countText.transform.SetParent(myCanvas.transform, false);
        RectTransform CanvasRect = myCanvas.GetComponent<RectTransform>();
        Vector2 ViewportPosition = myCamera.WorldToViewportPoint(this.transform.position);
        Vector2 WorldObject_ScreenPosition = new Vector2(((ViewportPosition.x * CanvasRect.sizeDelta.x) - (CanvasRect.sizeDelta.x * X_FACTOR)), ((ViewportPosition.y * CanvasRect.sizeDelta.y) - (CanvasRect.sizeDelta.y * Y_FACTOR)));
        _countText.rectTransform.anchoredPosition3D = new Vector3(WorldObject_ScreenPosition.x, WorldObject_ScreenPosition.y, 0.0f);

        // set initial variables
        _position = position;
        SetCount(defensePos.Count);
        _selected = false;
        _pulse = true;
        _dir = 1;
        _alpha = UNSELECTED_LINE_ALPHA;
        _pulseColor = new Color(1.0f, 1.0f, 1.0f, _alpha);
        //SpriteRend.color = _pulseColor;
    }

    public void Select()
    {
        _pulse = false;
        enabled = false;
        if (!_selected)
        {
            _selected = true;
            _count++;
            SetCountText();
        }
        transform.localPosition = new Vector3(transform.localPosition.x, transform.localPosition.y, -9.51f);
        transform.localScale = new Vector3(LARGE_DOT_SCALE, LARGE_DOT_SCALE, LARGE_DOT_SCALE);
        _pulseColor.a = 1.0f;
        //SpriteRend.color = _pulseColor;
    }

    public void SelectForExistingSelection()
    {
        _pulse = false;
        enabled = false;
        _selected = true;
        transform.localPosition = new Vector3(transform.localPosition.x, transform.localPosition.y, -9.51f);
        transform.localScale = new Vector3(LARGE_DOT_SCALE, LARGE_DOT_SCALE, LARGE_DOT_SCALE);
        _pulseColor.a = 1.0f;
        //SpriteRend.color = _pulseColor;
    }

    public void Unselect()
    {
        _pulse = false;
        enabled = false;
        if (_selected)
        {
            _selected = false;
            _count--;
            SetCountText();
        }
        transform.localPosition = new Vector3(transform.localPosition.x, transform.localPosition.y, -9.5f);
        transform.localScale = new Vector3(SMALL_DOT_SCALE, SMALL_DOT_SCALE, SMALL_DOT_SCALE);
        _pulseColor.a = UNSELECTED_LINE_ALPHA;
        //SpriteRend.color = _pulseColor;
    }

    public void Remove()
    {
        //Debug.Log("removing " + _countText.text);
        Destroy(_countText.gameObject);
    }

    void SetCountText()
    {
        _countText.text = _count.ToString();
    }

    public void SetCount(int count)
    {
        _count = count;
        SetCountText();
    }
    #endregion

    #region Accessors
    public Vector2 Position
    {
        get { return _position; }
    }
    #endregion
}