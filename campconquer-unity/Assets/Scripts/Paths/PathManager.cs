using UnityEngine;
using UnityEngine.SceneManagement;
using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using Newtonsoft.Json;

namespace CampConquer
{
    public enum MapQuadrant { NONE=0, UPPER_LEFT, LOWER_LEFT, UPPER_RIGHT, LOWER_RIGHT }

    public class PathManager : MonoBehaviour 
    {
        #region Constants
        public const float LONGEST_DIST = 15.0f;
        #endregion

        #region Public Vars
        public Material LineMat;
        public static PathManager Instance;
        #endregion

        #region Private Vars
        List<Path> _redPaths;
        List<Path> _bluePaths;
        List<DefensePos> _redDefensePos;
        List<DefensePos> _blueDefensePos;
        List<MapNode> _mapNodes;
        List<MapNode> _upperRightNodes;
        List<MapNode> _lowerRightNodes;
        List<MapNode> _upperLeftNodes;
        List<MapNode> _lowerLeftNodes;
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
        }
        #endregion

        #region Methods
        public void Initialize()
        {
            //Debug.Log("PathManager Initialize");

            _redPaths = new List<Path>();
            _bluePaths = new List<Path>();

            _redDefensePos = new List<DefensePos>();
            _blueDefensePos = new List<DefensePos>();

            /*
            TextAsset pathJson = Resources.Load<TextAsset>("redPaths");
            _redPaths = JsonConvert.DeserializeObject<List<Path>>(pathJson.text);

            pathJson = Resources.Load<TextAsset>("bluePaths");
            _bluePaths = JsonConvert.DeserializeObject<List<Path>>(pathJson.text);
            */

            /*
            pathJson = Resources.Load<TextAsset>("redDefensePos");
            _redDefensePos = JsonConvert.DeserializeObject<List<DefensePos>>(pathJson.text);

            pathJson = Resources.Load<TextAsset>("blueDefensePos");
            _blueDefensePos = JsonConvert.DeserializeObject<List<DefensePos>>(pathJson.text);
            */

            TextAsset pathJson = (TextAsset)Resources.Load("map");
            _mapNodes = JsonConvert.DeserializeObject<List<MapNode>>(pathJson.text);

            LoadPathsFromGameData();

            /*
            if (SceneManager.GetActiveScene().name == "Moderator" && !GameManager.Client)
                StartCoroutine(StartGetPathsAndPositionsFromServer());
            else
                LoadPathsFromGameData();
                */
        }

        /*
        IEnumerator StartGetPathsAndPositionsFromServer()
        {
            yield return OnlineManager.Instance.StartGetPaths();

            for (int i = 0; i < OnlineManager.Instance.GameData.paths.Count; i++)
            {
                PathData pathData = OnlineManager.Instance.GameData.paths[i];
                TeamColor color = TeamColor.RED;
                if (pathData.team == "blue")
                {
                    color = TeamColor.BLUE;
                }

                if (pathData.role == "defense")
                {
                    AddDefensePos(color, pathData.points[0], pathData.count);
                }
                else
                {
                    //Debug.Log("adding path for " + color);
                    AddOffensePath(color, pathData.points, pathData.count);
                }
            }
        }
        */

        void LoadPathsFromGameData()
        {
            //Debug.Log("LoadPathsFromGameData");

            for (int i = 0; i < OnlineManager.Instance.GameData.paths.Count; i++)
            {
                PathData pathData = OnlineManager.Instance.GameData.paths[i];
                TeamColor color = TeamColor.RED;
                if (pathData.team == "blue")
                {
                    color = TeamColor.BLUE;
                }

                if (pathData.role == "defense")
                {
                    AddDefensePos(color, pathData.points[0], pathData.count);
                }
                else
                {
                    //Debug.Log("adding path for " + color);
                    AddOffensePath(color, pathData.points, pathData.count, pathData.button_position, pathData.button_angle);
                }
            }
        }

        void AddDefensePos(TeamColor color, Point point, int count)
        {
            DefensePos pos = new DefensePos(point.x, point.y, count);
            if (color == TeamColor.RED)
                _redDefensePos.Add(pos);
            else
                _blueDefensePos.Add(pos);
        }

        void AddOffensePath(TeamColor color, List<Point> points, int count, Point buttonPosition, int buttonAngle)
        {
            Path path = new Path(points, count);
            path.ButtonPosition = buttonPosition;
            path.ButtonAngle = buttonAngle;
            if (color == TeamColor.RED)
                _redPaths.Add(path);
            else
                _bluePaths.Add(path);
        }

        public Path GetRedPath(int pathIndex)
        {
            if (_redPaths.Count > pathIndex)
                return _redPaths[pathIndex];
            return null;
        }

        public int GetRedPathPlacementCount(int pathIndex)
        {
            if (_redPaths.Count > pathIndex)
                return _redPaths[pathIndex].Count;
            return -1;
        }

        public Path GetBluePath(int pathIndex)
        {
            if (_bluePaths.Count > pathIndex)
                return _bluePaths[pathIndex];
            return null;
        }

        public int GetBluePathPlacementCount(int pathIndex)
        {
            if (_bluePaths.Count > pathIndex)
                return _bluePaths[pathIndex].Count;
            return -1;
        }

        public List<Path> GetRedPaths()
        {
            return _redPaths;
        }

        public List<Path> GetBluePaths()
        {
            return _bluePaths;
        }

        public int GetRedPathCount()
        {
            return _redPaths.Count;
        }

        public int GetBluePathCount()
        {
            return _bluePaths.Count;
        }

        public DefensePos GetRedDefensePos(int pathIndex)
        {
            if (_redDefensePos.Count > pathIndex)
                return _redDefensePos[pathIndex];
            return null;
        }

        public DefensePos GetBlueDefensePos(int pathIndex)
        {
            if (_blueDefensePos.Count > pathIndex)
                return _blueDefensePos[pathIndex];
            return null;
        }

        public int GetRedDefensePlacementCount(int pathIndex)
        {
            if (_redDefensePos.Count > pathIndex)
                return _redDefensePos[pathIndex].Count;
            return -1;
        }

        public int GetBlueDefensePlacementCount(int pathIndex)
        {
            if (_blueDefensePos.Count > pathIndex)
                return _blueDefensePos[pathIndex].Count;
            return -1;
        }

        public int GetRedDefensePosCount()
        {
            return _redDefensePos.Count;
        }

        public int GetBlueDefensePosCount()
        {
            return _blueDefensePos.Count;
        }

        /*
        public void AddRedPath(List<Point> points)
        {
            Path newPath = new Path();
            newPath.Points = points;
            _redPaths.Add(newPath);

            SavePaths();
        }

        public void AddBluePath(List<Point> points)
        {
            Path newPath = new Path();
            newPath.Points = points;
            _bluePaths.Add(newPath);

            SavePaths();
        }
        */

        public void SavePaths()
        {
            #if UNITY_EDITOR
            string path = null;
            string pathJson = null;

            path = "Assets/Resources/redPaths.json";
            pathJson = JsonConvert.SerializeObject(_redPaths);
            using (FileStream fs = new FileStream(path, FileMode.Create)){
                using (StreamWriter writer = new StreamWriter(fs)){
                    writer.Write(pathJson);
                }
            }

            path = "Assets/Resources/bluePaths.json";
            pathJson = JsonConvert.SerializeObject(_bluePaths);
            using (FileStream fs = new FileStream(path, FileMode.Create)){
                using (StreamWriter writer = new StreamWriter(fs)){
                    writer.Write(pathJson);
                }
            }

            UnityEditor.AssetDatabase.Refresh();
            #endif
        }
        #endregion

        #region Game Methods
        public MapNode GetClosestNodePos(Vector2 pos)
        {
            /*
            MapQuadrant quad = GetQuadrant(pos);
            List<MapNode> nodesToCheck;
            switch (quad)
            {
                case MapQuadrant.UPPER_RIGHT:
                    nodesToCheck = _upperRightNodes;
                    break;
                case MapQuadrant.LOWER_RIGHT:
                    nodesToCheck = _lowerRightNodes;
                    break;
                case MapQuadrant.UPPER_LEFT:
                    nodesToCheck = _upperLeftNodes;
                    break;
                default:
                    nodesToCheck = _lowerLeftNodes;
                    break;
            }

            MapNode closestNode = null;
            float closestDistance = LONGEST_DIST;
            for (int i=0; i<nodesToCheck.Count; i++)
            {
                MapNode node = nodesToCheck[i];
                float dist = (new Vector2(node.X, node.Y) - pos).magnitude;
                if (dist < closestDistance)
                {
                    closestDistance = dist;
                    closestNode = node;
                }
            }
            */

            MapNode closestNode = null;

            if (_mapNodes != null)
            {
                float closestDistance = LONGEST_DIST;
                for (int i = 0; i < _mapNodes.Count; i++)
                {
                    MapNode node = _mapNodes[i];
                    float dist = (new Vector2(node.Point.x, node.Point.y) - pos).magnitude;
                    if (dist < closestDistance)
                    {
                        closestDistance = dist;
                        closestNode = node;
                }
            }
            }
            return closestNode;
        }

        public MapNode GetLinkedNodeClosestToPos(MapNode currentNode, Vector2 pos)
        {
            MapNode closestNode = null;
            float closestDistance = LONGEST_DIST;
            for (int i=0; i<currentNode.ConnectedNodes.Count; i++)
            {
                MapNode node = _mapNodes[currentNode.ConnectedNodes[i]];
                float dist = (new Vector2(node.Point.x, node.Point.y) - pos).magnitude;
                if (dist < closestDistance)
                {
                    closestDistance = dist;
                    closestNode = node;
                }
            }
            return closestNode;
        }

        public MapNode GetLinkedNodeClosestToPosNotLastNode(MapNode currentNode, Vector2 pos, MapNode lastNode)
        {
            MapNode closestNode = null;
            float closestDistance = LONGEST_DIST;
            for (int i = 0; i < currentNode.ConnectedNodes.Count; i++)
            {
                MapNode node = _mapNodes[currentNode.ConnectedNodes[i]];
                if (node != lastNode)
                {
                    float dist = (new Vector2(node.Point.x, node.Point.y) - pos).magnitude;
                    if (dist < closestDistance)
                    {
                        closestDistance = dist;
                        closestNode = node;
                    }
                }
            }
            return closestNode;
        }

        MapQuadrant GetQuadrant(Vector2 pos)
        {
            if (pos.x > 7.5f)
            {
                if (pos.y > 5.0f)
                    return MapQuadrant.UPPER_RIGHT;
                else
                    return MapQuadrant.LOWER_RIGHT;
            }
            else
            {
                if (pos.y > 5.0f)
                    return MapQuadrant.UPPER_LEFT;
            }
            return MapQuadrant.LOWER_LEFT;
        }
        #endregion
    }

    #region Related Classes        
    public class Path
    {
        public List<Point> Points;
        public int Count;
        public Point ButtonPosition;
        public int ButtonAngle;

        public Path(List<Point> points)
        {
            Points = new List<Point>();
            if (points != null)
            {
                for (int i = 0; i < points.Count; i++)
                {
                    Points.Add(new Point(points[i].x, points[i].y));
                }
            }
            Count = 1;
        }

        public Path(List<Point> points, int count)
        {
            if (points != null)
            {
                Points = new List<Point>();
                for (int i = 0; i < points.Count; i++)
                {
                    Points.Add(new Point(points[i].x, points[i].y));
                }
            }
            Count = count;
        }
    }

    public class DefensePos
    {
        public Point Point;
        public int Count;

        public DefensePos(float x, float y)
        {
            Point = new Point(x, y);
            Count = 1;
        }

        public DefensePos(float x, float y, int count)
        {
            Point = new Point(x, y);
            Count = count;
        }
    }

    public class PathNode
    {
        public Point Point;
    }

    public class MapNode
    {
        public Point Point;
        public List<int> ConnectedNodes;
    }

    public class Point
    {
        public float x;
        public float y;

        public Point(float xIn, float yIn)
        {
            x = xIn;
            y = yIn;
        }
    }
    #endregion
}