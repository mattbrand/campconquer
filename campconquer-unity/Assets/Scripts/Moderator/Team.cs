using UnityEngine;
using System.Collections.Generic;
using CampConquer;

#region Global Enums
public enum TeamColor { RED=0, BLUE }
public enum TeamStatus { NONE=0, WON, DONE, LOST, TIE }
#endregion

public class Team
{
    #region Constants
    public static Vector2 RED_OFFENSE_POS = new Vector2(1.5f, 5.0f);
    public static Vector2 BLUE_OFFENSE_POS = new Vector2(13.5f, 5.0f);
    public static Vector2 RED_FLAG_POS = new Vector2(0.5f, 5.0f);
    public static Vector2 BLUE_FLAG_POS = new Vector2(14.5f, 5.0f);
    #endregion

    #region Private Vars
    TeamColor _color;
    TeamStatus _status;
    List<Piece> _pieces;
    List<Vector2> _homePath;
    Dictionary<int, Piece> _pieceLookup;
    Piece _closestToFlag;
    Piece _winner;
    Piece _attackMVP;
    Piece _defendMVP;
    Vector2 _homePosition;
    int _downs;
    int _balloonsThrown;
    int _flagCaptures;
    #endregion

    #region Methods
    public Team(TeamColor color, List<Piece> pieces, Vector2 homePosition)
    {
        _color = color;
        _pieces = pieces;
        _homePosition = homePosition;
        _status = TeamStatus.NONE;
        _closestToFlag = null;
        _winner = null;
        SetHomePath();
        Reset();
    }

    public void SetPieceLookups()
    {
        _pieceLookup = new Dictionary<int, Piece>();
        for (int i = 0; i < _pieces.Count; i++)
        {
           // Debug.Log("adding " + _pieces[i].ID + " --- " + _pieces[i]);
            _pieceLookup.Add(_pieces[i].ID, _pieces[i]);
        }
    }

    void SetHomePath()
    {
        /*
        Path flagPath;
        if (_color == TeamColor.RED)
            flagPath = PathManager.Instance.GetRedPath(0);
        else
            flagPath = PathManager.Instance.GetBluePath(0);

        _homePath = new List<Vector2>();
        for (int i=flagPath.X.Count - 2; i >= 0; i--)
        {
            _homePath.Add(new Vector2(flagPath.X[i], flagPath.Y[i]));
        }
        _homePath.Add(_homePosition);
        */

        _homePath = new List<Vector2>();
        if (_color == TeamColor.RED)
        {
            _homePath.Add(new Vector2(11.25f, 5.0f));
            _homePath.Add(new Vector2(9.75f, 4.5f));
            _homePath.Add(new Vector2(5.25f, 4.5f));
            _homePath.Add(new Vector2(3.75f, 5.0f));
            _homePath.Add(new Vector2(0.5f, 5.0f));
        }
        else
        {
            _homePath.Add(new Vector2(3.75f, 5.0f));
            _homePath.Add(new Vector2(5.25f, 4.5f));
            _homePath.Add(new Vector2(9.75f, 4.5f));
            _homePath.Add(new Vector2(11.25f, 5.0f));
            _homePath.Add(new Vector2(14.5f, 5.0f));
        }
    }

    public void UpdatePieces(Flag enemyFlag)
    {
        //if (_status != TeamStatus.DONE)
        {
            Piece piece;
            Vector2 enemyFlagPos = enemyFlag.Position;
            int i;

            if (_flagCaptures > 0)
            {
                // find piece closest to flag
                float smallestDist = PathManager.LONGEST_DIST;
                for (i = 0; i < _pieces.Count; i++)
                {
                    piece = _pieces[i];
                    if (piece.Status == PieceStatus.NORMAL)
                    {
                        float dist = (piece.Position - enemyFlagPos).magnitude;
                        if (dist < smallestDist)
                        {
                            _closestToFlag = piece;
                            smallestDist = dist;
                        }
                    }
                }

                // reset closest flags
                for (i = 0; i < _pieces.Count; i++)
                {
                    piece = _pieces[i];
                    if (piece.Status == PieceStatus.NORMAL)
                    {
                        if (piece == _closestToFlag)
                            piece.ClosestToFlag = true;
                        else
                            piece.ClosestToFlag = false;
                    }
                }
            }

            bool anyOffenseAlive = false;
            for (i = 0; i < _pieces.Count; i++)
            {
                piece = _pieces[i];
                piece.LastTrigger = "";
                if (piece.Status == PieceStatus.NORMAL)
                {
                    if (_flagCaptures > 0 && !_pieces[i].HasFlag)
                    {
                        piece.SetDestinationForCapturedFlag(enemyFlag);
                    }

                    piece.Move();

                    if (Utilities.CloseEnough(piece.Position, enemyFlag.Position) && enemyFlag.Status != FlagStatus.CAPTURED)
                    {
                        enemyFlag.Status = FlagStatus.CAPTURED;
                        piece.HasFlag = true;
                        _flagCaptures++;
                        piece.Pickups++;
                        piece.Destination = GetNextHomeDestination(piece.Position);

                        SoundManager.Instance.PlaySoundEffect(SoundType.FLAG_CAPTURE);
                        //Debug.Log(_color + " piece " + i + " got flag");
                    }

                    if (piece.HasFlag)
                        enemyFlag.SetPosition(piece.Position);

                    if (piece.Role == PieceRole.OFFENSE)
                        anyOffenseAlive = true;
                }
            }
            if (!anyOffenseAlive)
            {
                _status = TeamStatus.DONE;
            }
        }
    }

    public Vector2 GetNextHomeDestination(Vector2 currentPos)
    {
        Vector2 returnPos = Vector2.zero;
        for (int i = 0; i < _homePath.Count; i++)
        {
            if (_color == TeamColor.RED)
            {
                returnPos = _homePath[i];
                if (_homePath[i].x < currentPos.x)
                {
                    break;
                }
            }
            else
            {
                returnPos = _homePath[i];
                if (_homePath[i].x > currentPos.x)
                {
                    break;
                }
            }
        }
        return returnPos;
    }

    public bool CheckGameOver()
    {
        for (int i = 0; i < _pieces.Count; i++)
        {
            if (_pieces[i].HasFlag && _pieces[i].Position == _homePosition)
            {
                _status = TeamStatus.WON;
                _winner = _pieces[i];
                //Debug.Log("set winner to " + _winner.Name);
                return true;
            }
        }
        return false;
    }

    public Piece FindClosestPiece(Vector2 position, float range, float rangeBonus)
    {
        Piece piece = null;
        float shortestDistance = 100.0f;
        float totalRange = range + (range * (rangeBonus / 100.0f));

        for (int i = 0; i < _pieces.Count; i++)
        {
            if (_pieces[i].Status == PieceStatus.NORMAL)
            {
                float diff = (_pieces[i].Position - position).magnitude;
                if (diff <= totalRange && diff < shortestDistance)
                {
                    shortestDistance = diff;
                    piece = _pieces[i];
                }
            }
        }

        return piece;
    }

    public void StopPieceAnimations()
    {
        for (int i = 0; i < _pieces.Count; i++)
        {
            _pieces[i].StopAnimation();
        }
    }

    public void Reset()
    {
        _flagCaptures = 0;
        _downs = 0;
        _balloonsThrown = 0;
        _status = TeamStatus.NONE;
    }

    public void RecordPieceMoves()
    {
        // set moves
        for (int i = 0; i < _pieces.Count; i++)
        {
            _pieces[i].RecordMove();
            _pieces[i].SetLastInfo();
        }
    }

    public Piece LookupPiece(int id)
    {
        return _pieceLookup[id];
    }

    public void CalulateMVPs()
    {
        if (_status == TeamStatus.WON)
        {
            _attackMVP = _winner;
        }
        else
        {
            _attackMVP = FindPieceWithLongestFlagDistance();
        }

        _defendMVP = FindPieceWithMostTakedowns();
    }

    Piece FindPieceWithLongestFlagDistance()
    {
        Piece pieceFound = null;
        float highestDistance = 0.0f;
        for (int i = 0; i < _pieces.Count; i++)
        {
            if (_pieces[i].DistanceWithFlag > highestDistance)
            {
                pieceFound = _pieces[i];
                highestDistance = _pieces[i].DistanceWithFlag;
            }
        }
        //Debug.Log("team " + _color + " has longest distance of " + pieceFound.DistanceWithFlag);
        return pieceFound;
    }

    Piece FindPieceWithMostTakedowns()
    {
        Piece pieceFound = null;
        int mostTakedowns = 0;
        for (int i = 0; i < _pieces.Count; i++)
        {
            if (_pieces[i].Takedowns > mostTakedowns)
            {
                pieceFound = _pieces[i];
                mostTakedowns = _pieces[i].Takedowns;
            }
        }
        return pieceFound;
    }
    #endregion

    #region Accessors
    public TeamStatus Status
    {
        get { return _status; }
        set { _status = value; }
    }

    public List<Piece> Pieces
    {
        get { return _pieces; }
        set { _pieces = value; }
    }

    public Piece AttackMVP
    {
        get { return _attackMVP; }
        set { _attackMVP = value; }
    }

    public Piece DefendMVP
    {
        get { return _defendMVP; }
        set { _defendMVP = value; }
    }

    public Piece Winner
    {
        get { return _winner; }
    }

    public TeamColor GetColor
    {
        get { return _color; }
    }

    public int Downs
    {
        get { return _downs; }
        set { _downs = value; }
    }

    public int BalloonsThrown
    {
        get { return _balloonsThrown; }
        set { _balloonsThrown = value; }
    }

    public int FlagCaptures
    {
        get { return _flagCaptures; }
        set { _flagCaptures = value; }
    }
    #endregion
}