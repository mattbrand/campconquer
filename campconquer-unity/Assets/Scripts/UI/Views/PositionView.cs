using UnityEngine;
using System.Collections.Generic;
using gametheory.UI;
using CampConquer;

public class PositionView : UIView 
{
    #region Constants
    const float MAP_SCALE_X = 27.5f;
    const float MAP_SCALE_Y = 23.5f;
    #endregion

    #region Public Vars
    public PositionItem RedPosition2Prefab;
    public PositionItem BluePosition2Prefab;
    public Piece GN1Prefab;
    public static PositionView Instance;
    #endregion

    #region Private Vars
    List<PositionItem> _positions;
    Vector2 _position;
    Vector2 _offset;
    Vector2 _scale;
    Piece _piece;
    #endregion

    #region Overridden Methods
    protected override void OnInit()
    {
        base.OnInit();

        if (Instance == null)
        {
            Instance = this;

            PositionItem.clickPosition += ClickedPosition;
            PathItem.clickPath += ClickedPath;
        }
        else
        {
            Destroy(gameObject);
        }
    }

    protected override void OnActivate()
    {
        base.OnActivate();

        GeneratePositionList();
    }

    protected override void OnCleanUp()
    {
        base.OnCleanUp();

        PositionItem.clickPosition -= ClickedPosition;
        PathItem.clickPath -= ClickedPath;

        Instance = null;
    }
    #endregion

    #region UI Methods
    public static PositionView Load()
    {
        PositionView view = UIView.Load("Views/PositionView", OverriddenViewController.Instance.transform) as PositionView;
        view.name = "PositionView";
        return view;
    }
    #endregion

    #region Methods
    void GeneratePositionList()
    {
        _scale = new Vector2(0.78f, 0.78f);
        _offset = new Vector2(1.7f, 1.1f);

        _positions = new List<PositionItem>();
        PositionItem position;
        float x;
        float y;
        int i;
        if (Avatar.Instance.Color == TeamColor.RED)
        {
            for (i = 0; i < PathManager.Instance.GetRedDefensePosCount(); i++)
            {
                x = (PathManager.Instance.GetRedDefensePos(i).Point.x * 0.78f) + 1.7f;
                y = (PathManager.Instance.GetRedDefensePos(i).Point.y * 0.78f) + 0.7f;

                position = (PositionItem)Instantiate(RedPosition2Prefab, new Vector3(x, y, -9.5f), Quaternion.identity);
                position.Init(PathManager.Instance.GetRedDefensePos(i));

                _positions.Add(position);
            }
        }
        else
        {
            for (i = 0; i < PathManager.Instance.GetBlueDefensePosCount(); i++)
            {
                x = (PathManager.Instance.GetBlueDefensePos(i).Point.x * 0.78f) + 1.7f;
                y = (PathManager.Instance.GetBlueDefensePos(i).Point.y * 0.78f) + 0.7f;

                position = (PositionItem)Instantiate(BluePosition2Prefab, new Vector3(x, y, -9.5f), Quaternion.identity);
                position.Init(PathManager.Instance.GetBlueDefensePos(i));

                _positions.Add(position);
            }
        }
    }
        
    void ClickedPosition(PositionItem positionItem)
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.SOFT_CLICK);

        UnselectPositions();
        _position = positionItem.Position;
        if (_position != null)
        {
            positionItem.Select();
        }

        InstantiatePiece();

        RoleView.Instance.UnselectPaths();
        RoleView.Instance.State = RoleView.RoleViewState.POSITION;
    }

    void ClickedPath(PathItem pathItem)
    {
        UnselectPositions();
        if (_piece != null)
        {
            RemovePiece();
        }
    }

    void RemovePiece()
    {
        if (_piece != null)
        {
            Destroy(_piece.gameObject);
            _piece = null;
        }
    }

    public void UnselectPositions()
    {
        for (int i = 0; i < _positions.Count; i++)
        {
            _positions[i].Unselect();
        }
    }

    public void SelectPosition()
    {
        List<Point> pathPoints = new List<Point>();
        Point point = new Point(_position.x, _position.y);
        pathPoints.Add(point);
        Path path = new Path(pathPoints);
        Avatar.Instance.Path = path;
        Avatar.Instance.Position = _position;
    }

    public void RemovePositions()
    {
        for (int i = 0; i < _positions.Count; i++)
        {
            _positions[i].Remove();
            Destroy(_positions[i].gameObject);
        }
        _positions = new List<PositionItem>();

        RemovePiece();
    }

    public void ActivateExistingPosition()
    {
        PositionItem position = null;
        int i;
        for (i = 0; i < _positions.Count; i++)
        {
            if (Avatar.Instance.Path.Points[0].x == _positions[i].Position.x && Avatar.Instance.Path.Points[0].y == _positions[i].Position.y)
            {
                //Debug.Log("found!");
                position = _positions[i];
                break;
            }
        }

        if (position != null)
        {
            for (i = 0; i < _positions.Count; i++)
            {
                if (_positions[i] == position)
                {
                    _positions[i].SelectForExistingSelection();
                    _position = _positions[i].Position;
                    InstantiatePiece();
                }
                else
                {
                    _positions[i].Unselect();
                }
            }
        }
    }

    public void Refresh()
    {
        //Debug.Log("refresh");

        int i;
        if (Avatar.Instance.Color == TeamColor.RED)
        {
            for (i = 0; i < PathManager.Instance.GetRedDefensePosCount(); i++)
            {
                _positions[i].SetCount(PathManager.Instance.GetRedDefensePlacementCount(i));
            }
        }
        else
        {
            for (i = 0; i < PathManager.Instance.GetBlueDefensePosCount(); i++)
            {
                _positions[i].SetCount(PathManager.Instance.GetBlueDefensePlacementCount(i));
            }
        }
    }

    void InstantiatePiece()
    {
        // set up piece to run on path
        if (_piece == null)
        {
            //Debug.Log(_path.GetPath().Points[0].X + ", " + _path.GetPath().Points[0].Y);
            Quaternion rotation = Quaternion.identity;
            if (Avatar.Instance.Color == TeamColor.BLUE)
                rotation = Quaternion.Euler(0.0f, 180.0f, 0.0f);
            _piece = (Piece)Instantiate(GN1Prefab, new Vector2(_position.x, _position.y), rotation);
            CampConquer.Point point = new Point(_position.x, _position.y);
            _piece.InitializeForDefense(_scale, _offset, point);
        }
        else
        {
            CampConquer.Point point = new Point(_position.x, _position.y);
            _piece.InitializeForDefense(_scale, _offset, point);
        }
    }
    #endregion
}