using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class PathDot : MonoBehaviour 
{
    #region Constants
    const float CLICK_HOLD_TIME = 0.15f;
    #endregion

    #region Public Vars
    public SpriteRenderer SpriteRend;
    public Sprite WhiteDot;
    #endregion

    #region Private Vars
    List<ConnectionInfo> _connections;
    float _timer;
    int _index;
    bool _selected;
    bool _placed;
    bool _mouseDown;
    bool _moved;
    #endregion

    #region Unity Methods
    void Awake()
    {
        _selected = false;
        _placed = false;
        _moved = false;
        _mouseDown = false;
        _connections = new List<ConnectionInfo>();
    }

    void Update()
    {
        if (_mouseDown)
        {
            _timer += Time.deltaTime;
            if (_timer > CLICK_HOLD_TIME) 
            {
                Vector3 initPos = transform.position;
                Vector2 newPos = Camera.main.ScreenToWorldPoint (Input.mousePosition);
                transform.position = new Vector3 (Utilities.RoundToDecimals (newPos.x, 1), Utilities.RoundToDecimals (newPos.y, 1), 0.0f);
                if (transform.position != initPos) 
                {
                    _moved = true;
                    PathEditor.ClickedDotPos = initPos;
                    PathEditor.Instance.AdjustPaths (this);
                }
            }
        }
    }

    void OnMouseDown()
    {
        PathEditor.ClickingDot = true;
        _mouseDown = true;
        _timer = 0.0f;
    }

    void OnMouseUp()
    {
        if (_placed && !_moved)
        {
            bool canClick = PathEditor.Instance.ClickDot(this);
            if (canClick)
            {
                if (!_selected)
                {
                    Select();
                }
                else
                {
                    Unselect();
                }
            }
        }
        else if (_moved)
        {
            //PathEditor.Instance.AdjustPaths(this);
        }
        _mouseDown = false;
        _moved = false;

        PathEditor.ClickingDot = false;
    }
    #endregion

    #region Methods
    public void Select()
    {
        _selected = true;
        SpriteRend.color = Color.black;
    }

    public void Unselect()
    {
        _selected = false;
        SpriteRend.color = Color.white;
    }

    public void SetIndex(int index)
    {
        _index = index;
    }
    #endregion

    #region Accessors
    public bool Selected
    {
        get { return _selected; }
        set { _selected = value; }
    }

    public bool Placed
    {
        get { return _placed; }
        set { _placed = value; }
    }

    public List<ConnectionInfo> Connections
    {
        get { return _connections; }
        set { _connections = value; }
    }

    public int GetIndex
    {
        get { return _index; }
    }
    #endregion
}