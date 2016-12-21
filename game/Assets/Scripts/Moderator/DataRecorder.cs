using UnityEngine;
using System.Collections.Generic;
using System.IO;
using Newtonsoft.Json;

public class DataRecorder : MonoBehaviour
{
    #region Public Vars
    public static DataRecorder Instance;
    #endregion

    #region Private Vars
    List<TurnData> _turnDataList;
    TurnData _currentTurnData;
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
        _turnDataList = new List<TurnData>();
    }

    public void StartTurnData()
    {
        _currentTurnData = new TurnData();
    }

    public void AddMoveToTurnData(Piece piece)
    {
        Move move = new Move(piece.ID, piece.LastTrigger, piece.Position, piece.Status, piece.HasFlag);
        if (piece.GetTeam.GetColor == TeamColor.RED)
            _currentTurnData.AddRedMove(move);
        else
            _currentTurnData.AddBlueMove(move);
    }

    public void AddThrowToTurnData(Vector3 source, Vector3 target, AmmoType type, TeamColor color)
    {
        Throw t = new Throw(source, target, type, color);
        _currentTurnData.AddThrow(t);
    }

    public void EndTurnData()
    {
        _turnDataList.Add(Instance._currentTurnData);
    }

    public void DisplayTurnData()
    {
        string json = JsonConvert.SerializeObject(_turnDataList);
    }

    public void OutputTurnDataToFile()
    {
        StreamWriter sw = new StreamWriter("gameData.json");
        string json = JsonConvert.SerializeObject(Instance._turnDataList);
        sw.Write(json);
    }

    public string GetJsonTurnData()
    {
        return JsonConvert.SerializeObject(_turnDataList);
    }

    public void SetDataFromJson(string json)
    {
        _turnDataList = JsonConvert.DeserializeObject<List<TurnData>>(json);
    }

    public void TestDataLoad(string json)
    {
        _turnDataList = JsonConvert.DeserializeObject<List<TurnData>>(json);
    }
    #endregion

    #region Accessors
    public List<TurnData> TurnDataList
    {
        get { return Instance._turnDataList; }
    }
    #endregion
}

public class TurnData
{
    #region Public Vars
    public List<Move> RM;
    public List<Move> BM;
    public List<Throw> T;
    #endregion

    #region Constructor
    public TurnData()
    {
        RM = new List<Move>();
        BM = new List<Move>();
        T = new List<Throw>();
    }
    #endregion

    #region Methods
    public void AddRedMove(Move move)
    {
        RM.Add(move);
    }

    public void AddBlueMove(Move move)
    {
        BM.Add(move);
    }

    public void AddThrow(Throw t)
    {
        T.Add(t);
    }
    #endregion
}

public class Move
{
    #region Public Vars
    public int ID;
    public string T;
    public float X;
    public float Y;
    public int S;
    public bool F;
    #endregion

    #region Constructor
    public Move(int playerID, string trigger, Vector2 destination, PieceStatus status, bool hasFlag)
    {
        ID = playerID;
        T = trigger;
        X = Utilities.RoundToDecimals(destination.x, 5);
        Y = Utilities.RoundToDecimals(destination.y, 5);
        S = (int)status;
        F = hasFlag;
    }
    #endregion
}

public class Throw
{
    #region Public Vars
    public float SX;
    public float SY;
    public float TX;
    public float TY;
    public int T;
    public int C;
    #endregion

    #region Constructor
    public Throw(Vector3 source, Vector3 target, AmmoType type, TeamColor color)
    {
        SX = source.x;
        SY = source.y;
        TX = target.x;
        TY = target.y;
        T = (int)type;
        C = (int)color;
    }
    #endregion
}