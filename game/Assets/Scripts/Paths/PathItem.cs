using UnityEngine;
using UnityEngine.UI;
using System.Collections.Generic;
using CampConquer;

public class PathItem : MonoBehaviour 
{
    #region Events
    //public static System.Action<PathItem> clickPath;
    #endregion

    #region Constants
    const float LINE_Z = -1.0f;
    const float DOT_Z = -9.5f;
    const float UNSELECTED_LINE_ALPHA = 0.25f;
    const float X_FACTOR = 0.704f;
    const float Y_FACTOR = 0.4575f;
    #endregion

    #region Public Vars
    public PathItemDot RedPathItemDotPrefab;
    public PathItemDot BluePathItemDotPrefab;
    public GameObject PathIndicatorPrefab;
    public PathLine PathLinePrefab;
    public Material BlackLineMat;
    public Material WhiteLineMat;
    public Text PathTextPrefab;
    #endregion

    #region Private Vars
    GameObject _pathIndicator;
    SpriteRenderer _pathIndicatorSpriteRend;
    List<PathItemDot> _dots;
    List<PathLine> _lines;
    Color _selectedColor;
    Color _unselectedColor;
    Color _pulseColor;
    Text _countText;
    float _alpha;
    int _dir;
    int _count;
    Path _path;
    bool _selected;
    bool _pulse;
    #endregion

    #region Unity Methods
    void Start()
    {
        //PathItem.clickPath += UnselectIndicator;
    }

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
            _pathIndicatorSpriteRend.color = _pulseColor;
        }
    }

    void OnDestroy()
    {
        //PathItem.clickPath -= UnselectIndicator;
    }
    #endregion

    #region Methods
    public void Initialize(Path path)
    {
        _path = path;

        if (Avatar.Instance.Color == TeamColor.RED)
        {
            _selectedColor = new Color(1.0f, 1.0f, 1.0f, 1.0f);
            _unselectedColor = new Color(1.0f, 1.0f, 1.0f, UNSELECTED_LINE_ALPHA);
        }
        else
        {
            _selectedColor = new Color(1.0f, 1.0f, 1.0f, 1.0f);
            _unselectedColor = new Color(1.0f, 1.0f, 1.0f, UNSELECTED_LINE_ALPHA);
        }

        _count = path.Count;
        //_count = 3;
    }

    public Path GetPath()
    {
        return _path;
    }

    public void RenderPath(Vector2 scale, Vector2 offset)
    {
        //Debug.Log("RenderPath");
        _dots = new List<PathItemDot>();
        //_lines = new List<LineRenderer>();
        _lines = new List<PathLine>();
        PathItemDot lastDot = null;
        Vector3 indicatorPos = Vector3.zero;

        for (int i = 0; i < _path.Points.Count; i++)
        {
            Vector3 pos = new Vector3((_path.Points[i].x * scale.x) + offset.x, (_path.Points[i].y * scale.y) + offset.y, DOT_Z);
            if (i == 2)
                indicatorPos = pos;
            PathItemDot dot = null;
            if (Avatar.Instance.Color == TeamColor.RED)
                dot = (PathItemDot)Instantiate(RedPathItemDotPrefab, pos, Quaternion.identity);
            else
                dot = (PathItemDot)Instantiate(BluePathItemDotPrefab, pos, Quaternion.identity);
            dot.SetPathItem(this);
            _dots.Add(dot);
            if (i > 0 && i < _path.Points.Count)
            {
                //Debug.Log("instantiating line");
                PathLine newLine2 = (PathLine)Instantiate(PathLinePrefab, lastDot.transform.localPosition, Quaternion.identity);
                //Debug.Log("instantiated line");
                Vector3 start = new Vector3(lastDot.transform.localPosition.x, lastDot.transform.localPosition.y, DOT_Z);
                Vector3 end = new Vector3(dot.transform.localPosition.x, dot.transform.localPosition.y, DOT_Z);
                newLine2.Init(this, start, end, _unselectedColor, WhiteLineMat);
                _lines.Add(newLine2);
            }
            lastDot = dot;
        }

        // create path indicator
        _pathIndicator = (GameObject)Instantiate(PathIndicatorPrefab, indicatorPos, Quaternion.identity);
        _pathIndicatorSpriteRend = _pathIndicator.GetComponent<SpriteRenderer>();
        _alpha = UNSELECTED_LINE_ALPHA;
        _pulseColor = new Color(1.0f, 1.0f, 1.0f, _alpha);
        _pathIndicatorSpriteRend.color = _pulseColor;
        _pulse = true;
        _dir = 1;

        // create path indicator text
        Camera myCamera = GameObject.Find("Main Camera").GetComponent<Camera>();
        Canvas myCanvas = GameObject.Find("Canvas").GetComponent<Canvas>();
        _countText = (Text)Instantiate(PathTextPrefab, Vector3.zero, Quaternion.identity);
        _countText.transform.SetParent(myCanvas.transform, false);
        RectTransform canvasRect = myCanvas.GetComponent<RectTransform>();
        Vector2 viewportPosition = myCamera.WorldToViewportPoint(_pathIndicator.transform.position);
        Vector2 worldObjectScreenPosition = new Vector2(((viewportPosition.x * canvasRect.sizeDelta.x) - (canvasRect.sizeDelta.x * X_FACTOR)), ((viewportPosition.y * canvasRect.sizeDelta.y) - (canvasRect.sizeDelta.y * Y_FACTOR)));
        _countText.rectTransform.anchoredPosition3D = new Vector3(worldObjectScreenPosition.x, worldObjectScreenPosition.y, 0.0f);
        SetCountText();
    }

    public void ClickDot()
    {
        PathView.Instance.ClickedPath(this);

        /*
        Debug.Log("click dot");
        if (clickPath != null)
            clickPath(this);
            */
    }

    public void UnselectIndicator(PathItem path)
    {
        //Debug.Log("UnselectIndicator");
        _pulse = false;
        enabled = false;

        if (path == this)
        {
            _pulseColor.a = 1.0f;
            if (!_selected)
            {
                _selected = true;
                _count++;
                SetCountText();
            }
        }
        else
        {
            _pulseColor.a = UNSELECTED_LINE_ALPHA;
            if (_selected)
            {
                _selected = false;
                _count--;
                SetCountText();
            }
        }
        _pathIndicatorSpriteRend.color = _pulseColor;
    }

    void SetCountText()
    {
        _countText.text = _count.ToString();
    }

    public void DestroyPath()
    {
        for (int i = 0; i < _dots.Count; i++)
        {
            Destroy(_dots[i].gameObject);
        }
        for (int i = 0; i < _lines.Count; i++)
        {
            _lines[i].Destroy();
            Destroy(_lines[i].gameObject);
        }
        Destroy(_pathIndicator.gameObject);
        Destroy(_countText.gameObject);
    }

    public void SetForPreselectedPath(PathItem path)
    {
        //Debug.Log("UnselectIndicator");
        _pulse = false;
        enabled = false;

        if (path == this)
        {
            _pulseColor.a = 1.0f;
            if (!_selected)
            {
                _selected = true;
            }
        }
        _pathIndicatorSpriteRend.color = _pulseColor;

        for (int i = 0; i < _lines.Count; i++)
            _lines[i].Select(path);
    }

    public void TurnOffColliders()
    {
        for (int i = 0; i < _lines.Count; i++)
        {
            _lines[i].TurnOffCollider();
        }
    }

    public void SetCount(int count)
    {
        _count = count;
        SetCountText();
    }
    #endregion

    #region Accessors
    public List<PathLine> Lines
    {
        get { return _lines; }
        set { _lines = value; }
    }
    #endregion
}