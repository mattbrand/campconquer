using UnityEngine;
using UnityEngine.UI;
using System.Collections.Generic;
using CampConquer;
using Newtonsoft.Json;
using System.IO;

public class PathEditor : MonoBehaviour 
{
    #region Constants
    const float LINE_Z = -1.0f;
    #endregion

    #region Public Vars
    public GameObject BlueFlagPrefab;
    public GameObject RedFlagPrefab;
    public PathDot RedDotPrefab;
    public PathDot BlueDotPrefab;
    public Text TeamButtonText;
    public Material BlackLineMat;
    public Material WhiteLineMat;
    public LineRenderer LineRendPrefab;
    public static bool ClickingDot;
    public static Vector3 ClickedDotPos;
    public static PathEditor Instance;
    #endregion

    #region Private Vars
    List<PathDot> _currentDots;
    List<ConnectionInfo> _connections;
    ConnectionInfo _selectedConnection;
    Flag _redFlag;
    Flag _blueFlag;
    TeamColor _color;
    PathDot _firstDot;
    PathDot _secondDot;
    #endregion

    #region Unity Methods
    void Awake() 
    {
        if (Instance == null)
        {
            Instance = this;
        }
        else
        {
            Destroy(gameObject);
        }

        Initialize();
    }

    void OnMouseUp()
    {
        if (!ClickingDot)
        {
            Vector2 newPos = Camera.main.ScreenToWorldPoint(Input.mousePosition);
            PathDot dot = (PathDot)Instantiate(RedDotPrefab, new Vector3(newPos.x, newPos.y, 0.0f), Quaternion.identity);
            dot.Placed = true;
            _currentDots.Add(dot);
            dot.SetIndex(_currentDots.Count - 1);
            dot = null;
        }
    }
    #endregion

    #region Methods
    void Initialize()
    {
        ClickedDotPos = Vector3.zero;
        ClickingDot = false;
        _color = TeamColor.RED;
        _firstDot = null;
        _secondDot = null;
        _connections = new List<ConnectionInfo>();
        _currentDots = new List<PathDot>();

        // create flags
        _redFlag = new Flag(TeamColor.RED, new Vector2(0.5f, 5.0f));
        _redFlag.Obj = (GameObject)Instantiate(RedFlagPrefab, _redFlag.Position, Quaternion.identity);

        _blueFlag = new Flag(TeamColor.BLUE, new Vector2(14.5f, 5.0f));
        _blueFlag.Obj = (GameObject)Instantiate(BlueFlagPrefab, _blueFlag.Position, Quaternion.identity);
    }

    public void ClearMap()
    {
        if (_connections != null && _connections.Count > 0)
        {
            for (int i = _connections.Count - 1; i >= 0; i--)
            {
                Destroy(_connections[i].Line.gameObject);
            }
        }
        if (_currentDots != null && _currentDots.Count > 0)
        {
            for (int i = _currentDots.Count - 1; i >= 0; i--)
            {
                Destroy(_currentDots[i].gameObject);
            }
        }
        _connections = new List<ConnectionInfo>();
        _currentDots = new List<PathDot>();
    }

    /*
    public void AddPath()
    {
        List<float> x = new List<float>();
        List<float> y = new List<float>();
        PathDot firstDot = null;
        float newX;
        float newY;
        int i;

        _currentDots.RemoveAt(0);

        if (_color == TeamColor.RED)
        {
            while (_currentDots.Count > 1)
            {
                for (i = 0; i < _currentDots.Count; i++)
                {
                    if (firstDot == null || _currentDots[i].transform.position.x < firstDot.transform.position.x)
                    {
                        firstDot = _currentDots[i];
                    }
                }
                newX = Utilities.RoundToDecimals(firstDot.transform.position.x, 1);
                newY = Utilities.RoundToDecimals(firstDot.transform.position.y, 1);
                x.Add(newX);
                y.Add(newY);
                _currentDots.Remove(firstDot);
                firstDot = null;
            }
            x.Add(Utilities.RoundToDecimals(_blueFlag.Position.x, 1));
            y.Add(Utilities.RoundToDecimals(_blueFlag.Position.y, 1));
        }
        else
        {
            while (_currentDots.Count > 1)
            {
                for (i = 0; i < _currentDots.Count; i++)
                {
                    if (firstDot == null || _currentDots[i].transform.position.x > firstDot.transform.position.x)
                    {
                        firstDot = _currentDots[i];
                    }
                }
                x.Add(Utilities.RoundToDecimals(firstDot.transform.position.x, 1));
                y.Add(Utilities.RoundToDecimals(firstDot.transform.position.y, 1));
                _currentDots.Remove(firstDot);
                firstDot = null;
            }
            x.Add(Utilities.RoundToDecimals(_redFlag.Position.x, 1));
            y.Add(Utilities.RoundToDecimals(_redFlag.Position.y, 1));
        }
    }
    */

    void CreateDot(Vector2 pos)
    {
        PathDot newDot = (PathDot)Instantiate(RedDotPrefab, pos, Quaternion.identity);
        _currentDots.Add(newDot);
        newDot.SetIndex(_currentDots.Count - 1);
    }

    /*
    public void ChangeTeam()
    {
        if (_color == TeamColor.RED)
            _color = TeamColor.BLUE;
        else
            _color = TeamColor.RED;
        TeamButtonText.text = _color.ToString();
        ClearMap();
    }
    */

    public void DeletePath()
    {
        if (_selectedConnection != null)
        {
            for (int i = 0; i < _currentDots.Count; i++)
            {
                for (int j = _currentDots[i].Connections.Count - 1; j >= 0; j--)
                {
                    if (_currentDots[i].Connections[j] == _selectedConnection)
                    {
                        _currentDots[i].Connections.RemoveAt(j);
                        _currentDots[i].Unselect();
                        if (_firstDot == _currentDots[i])
                            _firstDot = null;
                        else if (_secondDot == _currentDots[i])
                            _secondDot = null;
                    }
                }
            }
            _connections.Remove(_selectedConnection);
            Destroy(_selectedConnection.Line.gameObject);

            _selectedConnection = null;
        }
    }

    public void Save()
    {
        #if UNITY_EDITOR
        List<MapNode> mapNodes = new List<MapNode>();
        for (int i = 0; i < _currentDots.Count; i++)
        {
            MapNode mapNode = new MapNode();
            PathDot dot = _currentDots[i];
            List<int> connectedNodes = new List<int>();
            for (int j = 0; j < dot.Connections.Count; j++)
            {
                ConnectionInfo connection = dot.Connections[j];
                if (connection.Dot0 != dot)
                    connectedNodes.Add(connection.Dot0.GetIndex);
                if (connection.Dot1 != dot)
                    connectedNodes.Add(connection.Dot1.GetIndex);
            }
            mapNode.ConnectedNodes = connectedNodes;
            mapNode.Point = new Point(dot.transform.localPosition.x, dot.transform.localPosition.y);
            mapNodes.Add(mapNode);
        }
            
        string jsonData = JsonConvert.SerializeObject(mapNodes);
        string path = "Assets/Resources/map.json";
        if (path != "")
        {
            using (FileStream fs = new FileStream(path, FileMode.Create)){
                using (StreamWriter writer = new StreamWriter(fs)){
                    writer.Write(jsonData);
                }
            }
            UnityEditor.AssetDatabase.Refresh();
        }
        #endif
    }

    public void Load()
    {
        ClearMap();

        TextAsset mapFile = (TextAsset)Resources.Load("map");
        List<MapNode> mapNodes = JsonConvert.DeserializeObject<List<MapNode>>(mapFile.text);

        if (mapNodes != null)
        {
            for (int i = 0; i < mapNodes.Count; i++)
            {
                CreateDot(new Vector2(mapNodes[i].Point.x, mapNodes[i].Point.y));
            }

            for (int i = 0; i < mapNodes.Count; i++)
            {
                PathDot dot0 = _currentDots[i];
                dot0.Placed = true;
                for (int j = 0; j < mapNodes[i].ConnectedNodes.Count; j++)
                {
                    PathDot dot1 = _currentDots[mapNodes[i].ConnectedNodes[j]];
                    bool found = false;
                    for (int k = 0; k < _connections.Count; k++)
                    {
                        ConnectionInfo connection = _connections[k];
                        if ((connection.Dot0 == dot0 && connection.Dot1 == dot1) || (connection.Dot1 == dot0 && connection.Dot0 == dot1))
                            found = true;
                    }

                    if (!found)
                    {
                        LineRenderer newLine = (LineRenderer)Instantiate(Instance.LineRendPrefab, dot0.transform.localPosition, Quaternion.identity);
                        newLine.material = Instance.WhiteLineMat;
                        Vector3[] array = new Vector3[2];
                        array[0] = new Vector3(dot0.transform.localPosition.x, dot0.transform.localPosition.y, LINE_Z);
                        array[1] = new Vector3(dot1.transform.localPosition.x, dot1.transform.localPosition.y, LINE_Z);
                        newLine.SetPositions(array);
                        ConnectionInfo newConnection = new ConnectionInfo(dot0, dot1, newLine);
                        newConnection.Pos0 = dot0.transform.localPosition;
                        newConnection.Pos1 = dot1.transform.localPosition;
                        dot0.Connections.Add(newConnection);
                        dot1.Connections.Add(newConnection);
                        _connections.Add(newConnection);

                    }
                }
            }
        }
    }

    public bool ClickDot(PathDot dot)
    {
        bool canClick = false;

        if (_selectedConnection != null && _selectedConnection.Line != null)
            _selectedConnection.Line.material = WhiteLineMat;

        if (dot.Selected)
        {
            if (dot == _firstDot)
            {
                _firstDot = null;
            }
            else if (dot == _secondDot)
            {
                _secondDot = null;
            }
            canClick = true;
        }
        else
        {
            if (_firstDot == null)
            {
                _firstDot = dot;
                canClick = true;
            }
            else if (_secondDot == null)
            {
                _secondDot = dot;
                canClick = true;
            }

            if (canClick && _firstDot != null && _secondDot != null)
            {
                ConnectionInfo foundConnection = null;
                // check for existing connection
                for (int i = 0; i < _firstDot.Connections.Count; i++)
                {
                    ConnectionInfo connection = _firstDot.Connections[i];
                    for (int j = 0; j < _secondDot.Connections.Count; j++)
                    {
                        if (_secondDot.Connections[j] == connection)
                        {
                            foundConnection = connection;
                            break;
                        }
                    }
                    if (foundConnection != null)
                        break;
                }

                if (foundConnection != null)
                {
                    _selectedConnection = foundConnection;
                    foundConnection.Line.material = BlackLineMat;
                }
                else
                {
                    LineRenderer newLine = (LineRenderer)Instantiate(LineRendPrefab, _firstDot.transform.localPosition, Quaternion.identity);
                    newLine.material = BlackLineMat;
                    Vector3[] array = new Vector3[2];
                    array[0] = new Vector3(_firstDot.transform.localPosition.x, _firstDot.transform.localPosition.y, LINE_Z);
                    array[1] = new Vector3(_secondDot.transform.localPosition.x, _secondDot.transform.localPosition.y, LINE_Z);
                    newLine.SetPositions(array);
                    ConnectionInfo connection = new ConnectionInfo(_firstDot, _secondDot, newLine);
                    _firstDot.Connections.Add(connection);
                    _secondDot.Connections.Add(connection);
                    _selectedConnection = connection;
                    _connections.Add(connection);

                }
            }
        }
        return canClick;
    }

    public void AdjustPaths(PathDot dot)
    {
        if (ClickedDotPos != Vector3.zero)
        {
            for (int i = 0; i < _connections.Count; i++)
            {
                ConnectionInfo connection = _connections[i];
                if (dot == connection.Dot0 && connection.Pos0 == ClickedDotPos)
                {
                    connection.Line.SetPosition(0, new Vector3(dot.transform.localPosition.x, dot.transform.localPosition.y, LINE_Z));
                    connection.Pos0 = dot.transform.localPosition;
                }
                else if (dot == connection.Dot1 && connection.Pos1 == ClickedDotPos)
                {
                    connection.Line.SetPosition(1, new Vector3(dot.transform.localPosition.x, dot.transform.localPosition.y, LINE_Z));
                    connection.Pos1 = dot.transform.localPosition;
                }
            }
        }
    }

    public void DeleteDot()
    {
        if (ClickedDotPos != Vector3.zero && ((_firstDot != null && _secondDot == null) || (_firstDot == null && _secondDot != null)))
        {
            PathDot dot = null;
            if (_firstDot != null && _secondDot == null)
                dot = _firstDot;
            else
                dot = _secondDot;
            for (int i = 0; i < _connections.Count; i++)
            {
                ConnectionInfo connection = _connections[i];
                if (dot == connection.Dot0)
                {
                    _selectedConnection = connection;
                    DeletePath();
                }
                else if (dot == connection.Dot1)
                {
                    _selectedConnection = connection;
                    DeletePath();
                }
            }

            _currentDots.Remove(dot);
            Destroy(dot.gameObject);
            dot = null;
            ClickedDotPos = Vector3.zero;
        }
        else
        {
            PathDot dot = null;
            if (_firstDot != null && _secondDot == null)
                dot = _firstDot;
            else
                dot = _secondDot;
            if (dot != null)
            {
                _currentDots.Remove(dot);
                Destroy(dot.gameObject);
                dot = null;
                ClickedDotPos = Vector3.zero;
            }
        }
    }
    #endregion
}

public class ConnectionInfo
{
    public PathDot Dot0;
    public PathDot Dot1;
    public Vector3 Pos0;
    public Vector3 Pos1;
    public LineRenderer Line;

    public ConnectionInfo(PathDot dot0, PathDot dot1, LineRenderer line)
    {
        Dot0 = dot0;
        Dot1 = dot1;
        Pos0 = dot0.transform.localPosition;
        Pos1 = dot1.transform.localPosition;

        Line = line;
    }
}