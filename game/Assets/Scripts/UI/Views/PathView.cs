using UnityEngine;
using System.Collections.Generic;
using gametheory.UI;
using CampConquer;

public class PathView : UIView 
{
    #region Events
    public static System.Action activateSelectButton;
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
        if (_piece != null)
        {
            _piece.MoveForSetup();
        }
    }
    #endregion

    #region Overridden Methods
    protected override void OnInit()
    {
        base.OnInit();

        if (Instance == null)
        {
            Instance = this;

            //PathItem.clickPath += ClickedPath;

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
        //Debug.Log("generated path list");
        _path = null;
        _canClick = true;
    }

    protected override void OnCleanUp()
    {
        base.OnCleanUp();

        //PathItem.clickPath -= ClickedPath;

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
        _scale = new Vector2(0.78f, 0.78f);
        _offset = new Vector2(1.7f, 0.8f);

        //Debug.Log("GeneratePathList - scale = " + _scale + " offset = " + _offset);

        _paths = new List<PathItem>();
        PathItem pathItem;
        int i;
        //Debug.Log(Avatar.Instance.Color);
        if (Avatar.Instance.Color == TeamColor.RED)
        {
            //Debug.Log(PathManager.Instance.GetRedPathCount());
            for (i = 0; i < PathManager.Instance.GetRedPathCount(); i++)
            {
                pathItem = (PathItem)Instantiate(PathItemPrefab, Vector3.zero, Quaternion.identity);
                pathItem.Initialize(PathManager.Instance.GetRedPath(i));
                pathItem.RenderPath(_scale, _offset);
                _paths.Add(pathItem);
            }
        }
        else
        {
            //Debug.Log(PathManager.Instance.GetBluePathCount());
            for (i = 0; i < PathManager.Instance.GetBluePathCount(); i++)
            {
                pathItem = (PathItem)Instantiate(PathItemPrefab, Vector3.zero, Quaternion.identity);
                pathItem.Initialize(PathManager.Instance.GetBluePath(i));
                pathItem.RenderPath(_scale, _offset);
                _paths.Add(pathItem);
            }
        }
    }

    public void ClickedPath(PathItem path)
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.SOFT_CLICK);

        _path = path;

        for (int i = 0; i < _paths.Count; i++)
        {
            _paths[i].UnselectIndicator(_path);

            for (int j = 0; j < _paths[i].Lines.Count; j++)
            {
                _paths[i].Lines[j].Select(_path);
            }
        }

        //Debug.Log("clicked path");
        /*
        for (int i = 0; i < _path.GetPath().Points.Count; i++)
        {
            Debug.Log(_path.GetPath().Points[i].x + ", " + _path.GetPath().Points[i].y);
        }
        */

        InstantiatePiece();

        if (activateSelectButton != null)
            activateSelectButton();
        HelpPanel.Deactivate();
        HelpText.Deactivate();
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
            _piece = (Piece)Instantiate(GN1Prefab, new Vector2(_path.GetPath().Points[0].x, _path.GetPath().Points[0].y), rotation);
            _piece.InitializeForSetup(_path.GetPath(), _scale, _offset);
            _piece.StartRunning();
            enabled = true;
        }
        else
        {
            _piece.InitializeForSetup(_path.GetPath(), _scale, _offset);
        }
    }

    public void SelectPath()
    {
        //Debug.Log("SelectPath");

        if (_path != null)
        {
            Avatar.Instance.Path = _path.GetPath();
        }
    }

    public void RemovePaths()
    {
        //Debug.Log("RemovePaths");
        for (int i = 0; i < _paths.Count; i++)
        {
            //Debug.Log("destroying path " + i);
            _paths[i].DestroyPath();
            Destroy(_paths[i].gameObject);
        }
        _paths = new List<PathItem>();

        if (_piece != null)
        {
            Destroy(_piece.gameObject);
        }
    }

    public void ActivateExistingPath()
    {
        //Debug.Log("activating existing path - path count = " + _paths.Count);
        PathItem path = null;
        int i;
        for (i = 0; i < _paths.Count; i++)
        {
            //Debug.Log("avatar count = " + Avatar.Instance.Path.Points.Count + " path count = " + _paths[i].GetPath().Points.Count);
            if (Avatar.Instance.Path.Points.Count == _paths[i].GetPath().Points.Count)
            {
                bool same = true;
                for (int j = 0; j < _paths[i].GetPath().Points.Count; j++)
                {
                    //Debug.Log("Comparing " + Avatar.Instance.Path.Points[i].x.ToString() + "," + Avatar.Instance.Path.Points[i].y.ToString() + " to " + _paths[i].GetPath().Points[i].x.ToString() + ", " + _paths[i].GetPath().Points[i].y.ToString());
                    if (!(Avatar.Instance.Path.Points[j].x == _paths[i].GetPath().Points[j].x && Avatar.Instance.Path.Points[j].y == _paths[i].GetPath().Points[j].y))
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
                _paths[i].SetForPreselectedPath(_path);
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
            _paths[i].TurnOffColliders();
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