using UnityEngine;
using System.Collections;

public enum FlagStatus { NONE=0, CAPTURED, DROPPED }

public class Flag
{
    #region Private Vars
    TeamColor _color;
    Vector2 _position;
    FlagStatus _status;
    GameObject _obj;
    #endregion

    #region Methods
    public Flag(TeamColor color, Vector2 position)
    {
        _color = color;
        _position = position;
        _status = FlagStatus.NONE;
    }

    public void SetPosition(Vector2 position)
    {
        _position = new Vector2(position.x, position.y);
        _obj.transform.localPosition = new Vector2(_position.x, _position.y);
    }
    #endregion

    #region Accessors
    public Vector2 Position
    {
        get { return _position; }
        set { _position = value; }
    }

    public FlagStatus Status
    {
        get { return _status; }
        set { _status = value; }
    }

    public GameObject Obj
    {
        get { return _obj; }
        set { _obj = value; }
    }
    #endregion
}