using UnityEngine;
using System.Collections.Generic;
using gametheory.UI;
using CampConquer;

public class PathView : UIView 
{
    #region Constants
    const float X_FACTOR = 0.704f;
    const float Y_FACTOR = 0.4575f;
    #endregion

    #region Public Vars
    public PathItem PathItemPrefab;
    public Piece GN1Prefab;
    public ExtendedImage HelpPanel;
    public ExtendedText HelpText;
    public static PathView Instance;
    #endregion

    #region Private Vars
    List<PathItem> _paths;
    PathItem _path;
    Piece _piece;
    Vector2 _offset;
    Vector2 _scale;
    bool _useColliders;
    bool _canClick;
    #endregion

    #region Unity Methods
    void Update()
    {
        /*
        if (_piece != null)
        {
            _piece.MoveForSetup();
        }
        */
    }
    #endregion

    #region Overridden Methods
    protected override void OnInit()
    {
        base.OnInit();

        if (Instance == null)
        {
            Instance = this;

            PathItem.clickPath += ClickedPath;
            PositionItem.clickPosition += ClickedPosition;

            //Debug.Log("OnInit PathView instance created");
        }
        else
        {
            Destroy(gameObject);

            //Debug.Log("OnInit PathView instance exists");
        }
    }

    protected override void OnActivate()
    {
        base.OnActivate();

        GeneratePathList();
        HelpPanel.Deactivate();
        //Debug.Log("generated path list");
        _path = null;
        _canClick = true;
    }

    protected override void OnCleanUp()
    {
        base.OnCleanUp();

        PathItem.clickPath -= ClickedPath;
        PositionItem.clickPosition -= ClickedPosition;

        Instance = null;

        //Debug.Log("OnCleanup PathView");
    }
    #endregion

    #region UI Methods
    public static PathView Load()
    {
        PathView view = UIView.Load("Views/PathView", OverriddenViewController.Instance.transform) as PathView;
        view.name = "PathView";
        return view;
    }
    #endregion

    #region Methods
    void GeneratePathList()
    {
        Camera myCamera = GameObject.Find("Main Camera").GetComponent<Camera>();
        Canvas myCanvas = GameObject.Find("Canvas").GetComponent<Canvas>();

        _scale = new Vector2(0.78f, 0.78f);
        _offset = new Vector2(1.7f, 0.8f);

        //Debug.Log("GeneratePathList - scale = " + _scale + " offset = " + _offset);

        _paths = new List<PathItem>();
        PathItem pathItem;
        float x;
        float y;
        int i;
        //Debug.Log(Avatar.Instance.Color);
        if (Avatar.Instance.Color == TeamColor.RED)
        {
            //Debug.Log(PathManager.Instance.GetRedPathCount());
            for (i = 0; i < PathManager.Instance.GetRedPathCount(); i++)
            {
                x = (PathManager.Instance.GetRedPath(i).Points[2].x * 0.78f) + 1.7f;
                y = (PathManager.Instance.GetRedPath(i).Points[2].y * 0.78f) + 0.8f;

                pathItem = (PathItem)Instantiate(PathItemPrefab, new Vector3(x, y, -9.5f), Quaternion.identity);
                pathItem.Init(PathManager.Instance.GetRedPath(i), new Vector2(x, y));
                //pathItem.Initialize(PathManager.Instance.GetBluePath(i));
                //pathItem.RenderPath(_scale, _offset);
                _paths.Add(pathItem);
            }
        }
        else
        {
            //Debug.Log(PathManager.Instance.GetBluePathCount());
            for (i = 0; i < PathManager.Instance.GetBluePathCount(); i++)
            {
                pathItem = (PathItem)Instantiate(PathItemPrefab, Vector3.zero, Quaternion.identity);
                //pathItem.Initialize(PathManager.Instance.GetBluePath(i));
                //pathItem.RenderPath(_scale, _offset);
                _paths.Add(pathItem);
            }
        }
    }

    public void ClickedPath(PathItem path)
    {
        //Debug.Log("clicked path");

        SoundManager.Instance.PlaySoundEffect(SoundType.SOFT_CLICK);

        UnselectPaths();
        _path = path;
        if (_path != null)
        {
            _path.Select();
        }

        InstantiatePiece();

        HelpPanel.Deactivate();
        HelpText.Deactivate();

        RoleView.Instance.UnselectPositions();
        RoleView.Instance.State = RoleView.RoleViewState.PATH;
    }

    void ClickedPosition(PositionItem positionItem)
    {
        UnselectPaths();
        if (_piece != null)
        {
            RemovePiece();
        }
    }

    public void UnselectPaths()
    {
        //Debug.Log("unselect paths");

        _path = null;
        for (int i = 0; i < _paths.Count; i++)
        {
            _paths[i].Unselect();
        }
    }

    void InstantiatePiece()
    {
        // set up piece to run on path
        if (_piece == null)
        {
            //Debug.Log(_path.GetPath.Points[0].x + ", " + _path.GetPath.Points[0].y);
            Quaternion rotation = Quaternion.identity;
            if (Avatar.Instance.Color == TeamColor.BLUE)
                rotation = Quaternion.Euler(0.0f, 180.0f, 0.0f);

            //Debug.Log("instantiating piece!");
            _piece = (Piece)Instantiate(GN1Prefab, new Vector2(_path.GetPath.Points[2].x, _path.GetPath.Points[2].y), rotation);
            _piece.InitializeForAttack(_scale, _offset, new CampConquer.Point(_path.GetPath.Points[2].x, _path.GetPath.Points[2].y));
        }
        else
        {
            _piece.InitializeForAttack(_scale, _offset, new CampConquer.Point(_path.GetPath.Points[2].x, _path.GetPath.Points[2].y));
        }
    }

    public void SelectPath()
    {
        //Debug.Log("SelectPath");

        if (_path != null)
        {
            Avatar.Instance.Path = _path.GetPath;
            Avatar.Instance.Position = Vector2.zero;
        }
    }

    public void RemovePaths()
    {
        //Debug.Log("RemovePaths");
        for (int i = 0; i < _paths.Count; i++)
        {
            _paths[i].Remove();
            Destroy(_paths[i].gameObject);
        }
        _paths = new List<PathItem>();

        if (_piece != null)
        {
            RemovePiece();
        }
    }

    void RemovePiece()
    {
        Destroy(_piece.gameObject);
        _piece = null;
    }

    public void ActivateExistingPath()
    {
        //Debug.Log("activating existing path - path count = " + _paths.Count);
        PathItem path = null;
        int i;
        for (i = 0; i < _paths.Count; i++)
        {
            if (Avatar.Instance.Path.Points.Count == _paths[i].GetPath.Points.Count)
            {
                bool same = true;
                for (int j = 0; j < _paths[i].GetPath.Points.Count; j++)
                {
                    //Debug.Log("Comparing " + Avatar.Instance.Path.Points[i].x.ToString() + "," + Avatar.Instance.Path.Points[i].y.ToString() + " to " + _paths[i].GetPath().Points[i].x.ToString() + ", " + _paths[i].GetPath().Points[i].y.ToString());
                    if (!(Avatar.Instance.Path.Points[j].x == _paths[i].GetPath.Points[j].x && Avatar.Instance.Path.Points[j].y == _paths[i].GetPath.Points[j].y))
                        same = false;
                }
                //Debug.Log("same = " + same);
                if (same)
                {
                    //Debug.Log("same!");
                    path = _paths[i];
                    break;
                }
            }
        }
        if (path != null)
        {
            //Debug.Log("here!");
            _path = path;
            //_path.ClickDot();
            for (i = 0; i < _paths.Count; i++)
            {
                if (_paths[i] == path)
                {
                    _paths[i].SelectForExistingSelection();
                }
                else
                {
                    _paths[i].Unselect();
                }
            }
            InstantiatePiece();
        }

        HelpPanel.Deactivate();
        HelpText.Deactivate();
    }

    public void TurnOffCollidersForAllPaths()
    {
        for (int i = 0; i < _paths.Count; i++)
        {
            //_paths[i].TurnOffColliders();
        }
    }
	public void TurnOnCollidersForAllPaths()
	{
		for (int i = 0; i < _paths.Count; i++)
		{
			//_paths[i].TurnOnColliders();
		}
	}

    public void Refresh()
    {
        // refresh path counts
        int i;
        if (Avatar.Instance.Color == TeamColor.RED)
        {
            //Debug.Log(PathManager.Instance.GetRedPathCount());
            for (i = 0; i < PathManager.Instance.GetRedPathCount(); i++)
            {
                _paths[i].SetCount(PathManager.Instance.GetRedPathPlacementCount(i));
            }
        }
        else
        {
            //Debug.Log(PathManager.Instance.GetBluePathCount());
            for (i = 0; i < PathManager.Instance.GetBluePathCount(); i++)
            {
                _paths[i].SetCount(PathManager.Instance.GetBluePathPlacementCount(i));
            }
        }
    }
    #endregion

    #region Accessors
    public bool UseColliders
    {
        get { return _useColliders; }
        set { _useColliders = value; }
    }

    public bool CanClick
    {
        get { return _canClick; }
        set { _canClick = value; }
    }
    #endregion
}