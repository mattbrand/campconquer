using System;
using System.Collections.Generic;
using UnityEngine;
using CampConquer;

#region Global Enums
public enum PieceRole { OFFENSE = 0, DEFENSE }
public enum PieceStatus { NORMAL = 0, OUT }
public enum PieceAnimationState { NONE = 0, RUN, THROW, HIT, CLIMB }
public enum PieceDir { NONE = 0, LEFT, RIGHT }
public enum PieceMoveState { NONE = 0, SET_NODE, HIT_NODE, NEXT_NODE }
public enum PieceType { GENDER_NEUTRAL_1 = 0, GENDER_NEUTRAL_2, MALE, FEMALE }
#endregion

public class Piece : MonoBehaviour
{
    #region Constants
    const string SETUP_PLAYER_SORT_LAYER = "SetupPlayers";
    const float SPEED = 0.025f;
    const float MAX_RANGE = 20.0f;
    const float MAX_SPEED = 20.0f;
    const float OUT_TIME = 1.0f;
    const float MAX_Y = 10.0f;
    const float SPEED_SETTING = 1.0f;
    const float LEFT_CLIMB_X_MIN = 0.4f;
    const float LEFT_CLIMB_X_MAX = 0.85f;
    const float CLIMB_Y_MIN = 1.0f;
    const float CLIMB_Y_MAX = 1.6f;
    const float RIGHT_CLIMB_X_MIN = 14.15f;
    const float RIGHT_CLIMB_X_MAX = 14.6f;
    const float SETUP_RUN_SPEED = 3.0f;
    const float BASE_SPEED = 0.5f;
    const float SPEED_FACTOR = 1.25f;
    const float BASE_RANGE = 0.5f;
    const float RANGE_FACTOR = 3.75f;
    const float ANIM_DELAY = 1.0f;
    const int MAX_HP = 20;
    const int BASE_HEALTH = 5;
    #endregion

    #region Public Vars
    public SpriteRenderer SpriteRend;
    public SpriteRenderer ShirtSpriteRend;
    public SpriteRenderer ShortsSpriteRend;
    public SpriteRenderer ShoesSpriteRend;
    public SpriteRenderer HairSpriteRend;
    public Animator Anim;
    #endregion

    #region Private Vars
    BoxCollider _leftLadderCollider;
    AmmoBandelier _ammo;
    PieceRole _role;
    public PieceStatus _status;
    PieceStatus _lastStatus;
    PieceType _type;
    PieceDir _dir;
    public PieceAnimationState _animationState;
    PieceMoveState _moveState;
    Path _currentPath;
    Team _team;
    MapNode _currentNode;
    MapNode _lastNode;
    string _name;
    public string _lastTrigger;
    public Vector2 _position;
    public Vector2 _destination;
    Vector2 _lastPosition;
    Vector2 _setupScale;
    Vector2 _setupOffset;
    float _rangeCalc;
    float _coolDownTime;
    float _coolDownTimer;
    float _speedCalc;
    float _animTimer;
    public float _outTimer;
    float _distanceWithFlag;
    int _id;
    int _pathIndex;
    int _healthCalc;
    public int _health;
    int _speed;
    int _range;
    int _downs;
    int _takedowns;
    int _balloonsThrown;
    int _pickups;
    public bool _hasFlag;
    bool _lastHasFlag;
    bool _closestToFlag;
    bool _battleSetup;

    //public List<string> _debugStrings;
    //public int _moveData;
    //public string _debugStr;
    #endregion

    #region Unity Methods
    void Start()
    {
        enabled = false;
    }

    void FixedUpdate()
    {
        if (_battleSetup)
        {
            _animTimer -= Time.deltaTime;
            if (_animTimer <= 0.0f)
            {
                Anim.SetTrigger("Throw");
                enabled = false;
            }
        }
        //Debug.Log("fixed update");
        else if (_status == PieceStatus.OUT && _outTimer >= 0.0f)
        {
            _outTimer -= Time.deltaTime;
            if (_outTimer < 0.0f)
                _outTimer = 0.0f;
            SpriteRend.color = new Color(SpriteRend.color.r, SpriteRend.color.g, SpriteRend.color.b, _outTimer);
            ShirtSpriteRend.color = new Color(ShirtSpriteRend.color.r, ShirtSpriteRend.color.g, ShirtSpriteRend.color.b, _outTimer);
            ShortsSpriteRend.color = new Color(ShortsSpriteRend.color.r, ShortsSpriteRend.color.g, ShortsSpriteRend.color.b, _outTimer);
            ShoesSpriteRend.color = new Color(ShoesSpriteRend.color.r, ShoesSpriteRend.color.g, ShoesSpriteRend.color.b, _outTimer);
            HairSpriteRend.color = new Color(HairSpriteRend.color.r, HairSpriteRend.color.g, HairSpriteRend.color.b, _outTimer);

            if (_outTimer <= 0.0f)
            {
                enabled = false;
                //Destroy(this.gameObject);
            }
        }
    }
    #endregion

    #region Methods
    public void Initialize(int id, string name, PieceRole role, Vector2 position, Path currentPath, PieceType pType, Team team)
    {
        //Debug.Log("initialize");
        //_debugStrings = new List<string>();
        SetStandardStats();
        _id = id;
        _name = name;
        _role = role;
        _team = team;
        _position = position;
        _currentPath = currentPath;
        if (_currentPath != null)
            GetNextDestination();
        else
            _destination = _position;
       
        _type = pType;
        _dir = PieceDir.NONE;
        _moveState = PieceMoveState.NONE;

        CalculateStatsFromData();

        if (_role == PieceRole.DEFENSE)
            _coolDownTime = 1.0f;
        else
            _coolDownTime = 1.0f;
        
        _ammo = new AmmoBandelier();
        GenerateRandomAmmo();
        SetPosition();

        switch (_type)
        {
            case PieceType.GENDER_NEUTRAL_1:
                Anim.speed = UnityEngine.Random.Range(0.9f, 0.95f);
                break;
            case PieceType.GENDER_NEUTRAL_2:
                Anim.speed = UnityEngine.Random.Range(1.0f, 1.05f);
                break;
            case PieceType.MALE:
                Anim.speed = UnityEngine.Random.Range(0.95f, 1.0f);
                break;
            case PieceType.FEMALE:
                Anim.speed = UnityEngine.Random.Range(1.05f, 1.1f);
                break;  
        }
    }

    public void CalculateStatsFromData()
    {
        // assign 10 points across all attributes
        _health = 0;
        _speed = 0;
        _range = 0;
        int totalPoints = 10;
        _health = UnityEngine.Random.Range(0, totalPoints + 1);
        totalPoints -= _health;
        if (totalPoints > 0)
        {
            _speed = UnityEngine.Random.Range(0, totalPoints + 1);
            totalPoints -= _speed;
            _range = totalPoints;
        }

        CalcStatValues();
    }

    void SetStandardStats()
    {
        _status = PieceStatus.NORMAL;
        _pathIndex = 0;
        _dir = PieceDir.NONE;
        _moveState = PieceMoveState.NONE;
        _hasFlag = false;
        _coolDownTimer = 0.0f;
        _animationState = PieceAnimationState.NONE;
        _closestToFlag = false;
        _downs = 0;
        _takedowns = 0;
        _pickups = 0;
        _balloonsThrown = 0;
        _distanceWithFlag = 0.0f;
    }

    public void SetPieceFromPieceData(PieceData piece, Team redTeam, Team blueTeam)
    {
        // base data
        SetStandardStats();
        _id = piece.player_id;
        _name = piece.player_name;

        // set team
        if (piece.team == "red")
        {
            _team = redTeam;
        }
        else
        {
            _team = blueTeam;
            this.gameObject.transform.localEulerAngles = new Vector3(0.0f, 180.0f, 0.0f);
        }

        // set path/position
        _position = new Vector2(piece.path[0].x, piece.path[0].y);
        SetPosition();
        if (piece.path.Count > 1)
        {
            _currentPath = new Path(piece.path);
            _role = PieceRole.OFFENSE;
        }
        else
        {
            _currentPath = null;
            _role = PieceRole.DEFENSE;
        }
        if (_currentPath != null)
            GetNextDestination();
        else
            _destination = _position;

        // set body type
        switch (piece.body_type)
        {
            case "gender_neutral_1":
                _type = PieceType.GENDER_NEUTRAL_1;
                Anim.speed = UnityEngine.Random.Range(0.9f, 0.95f);
                break;
            case "gender_neutral_2":
                _type = PieceType.GENDER_NEUTRAL_2;
                Anim.speed = UnityEngine.Random.Range(1.0f, 1.05f);
                break;
            case "male":
                _type = PieceType.MALE;
                Anim.speed = UnityEngine.Random.Range(0.95f, 1.0f);
                break;
            default:
                _type = PieceType.FEMALE;
                Anim.speed = UnityEngine.Random.Range(1.05f, 1.1f);
                break;
        }

        // stats
        _health = piece.health;
        _speed = (int)piece.speed;
        //_speed = UnityEngine.Random.Range(1, 5);
        /*
        int random = UnityEngine.Random.Range(0, 2);
        if (random == 0)
            _speed = 0;
        else
            _speed = 20;

        */
        //_speed = 0;
        _range = (int)piece.range;
        CalcStatValues();

        // initialization
        if (_role == PieceRole.DEFENSE)
            _coolDownTime = 1.0f;
        else
            _coolDownTime = 1.0f;

        // sprite colors
        int randomIndex = -1;
        if (piece.hair_color != null)
        {
            HairSpriteRend.color = Colors.HexToColor(piece.hair_color);
        }
        else
        {
            // no hair color found - set random hair color
            randomIndex = UnityEngine.Random.Range(0, Database.Instance.HairColors.Count);
            HairSpriteRend.color = Colors.HexToColor(Database.Instance.HairColors[randomIndex]);
        }
        if (piece.skin_color != null)
        {
            SpriteRend.color = Colors.HexToColor(piece.skin_color);
        }
        else
        {
            // random skin color
            randomIndex = UnityEngine.Random.Range(0, Database.Instance.SkinColors.Count);
            SpriteRend.color = Colors.HexToColor(Database.Instance.SkinColors[randomIndex]);
        }

        if (_team.GetColor == TeamColor.RED)
            ShirtSpriteRend.color = Colors.RedShirtColor;
        else
            ShirtSpriteRend.color = Colors.BlueShirtColor;
        //ShortsSpriteRend.color = new Color(UnityEngine.Random.Range(0.0f, 1.0f), UnityEngine.Random.Range(0.0f, 1.0f), UnityEngine.Random.Range(0.0f, 1.0f));
        //ShoesSpriteRend.color = new Color(UnityEngine.Random.Range(0.0f, 1.0f), UnityEngine.Random.Range(0.0f, 1.0f), UnityEngine.Random.Range(0.0f, 1.0f));

        // set ammo
        _ammo = new AmmoBandelier();
        for (int i = 0; i < piece.ammo.Count; i++)
        {
            _ammo.AddAmmo((AmmoType)Enum.Parse(typeof(AmmoType), piece.ammo[i].ToUpper(), true));
        }
        //GenerateRandomAmmo();
    }

    public void InitializeForSetup(Path path, Vector2 scale, Vector2 offset)
    {
        _setupScale = scale;
        _setupOffset = offset;
        _currentPath = path;
        _pathIndex = 0;
        _position = CalcPositionForSetup(_currentPath.Points[0]);
        _destination = CalcPositionForSetup(_currentPath.Points[1]);
        SpriteRend.sortingLayerName = SETUP_PLAYER_SORT_LAYER;
        ShirtSpriteRend.sortingLayerName = SETUP_PLAYER_SORT_LAYER;
        ShortsSpriteRend.sortingLayerName = SETUP_PLAYER_SORT_LAYER;
        ShoesSpriteRend.sortingLayerName = SETUP_PLAYER_SORT_LAYER;
        HairSpriteRend.sortingLayerName = SETUP_PLAYER_SORT_LAYER;
        SetPositionForSetup();
        SpriteRend.color = Colors.HexToColor(Avatar.Instance.SkinColor);
        HairSpriteRend.color = Colors.HexToColor(Avatar.Instance.HairColor);
        if (Avatar.Instance.Color == TeamColor.RED)
            ShirtSpriteRend.color = Colors.RedShirtColor;
        else
            ShirtSpriteRend.color = Colors.BlueShirtColor;
    }

    public void InitializeForAttack(Vector2 scale, Vector2 offset, CampConquer.Point point)
    {
        _setupScale = scale;
        _setupOffset = offset;
        _pathIndex = 0;
        _position = CalcPositionForSetup(point);
        _destination = _position;
        SpriteRend.sortingLayerName = SETUP_PLAYER_SORT_LAYER;
        ShirtSpriteRend.sortingLayerName = SETUP_PLAYER_SORT_LAYER;
        ShortsSpriteRend.sortingLayerName = SETUP_PLAYER_SORT_LAYER;
        ShoesSpriteRend.sortingLayerName = SETUP_PLAYER_SORT_LAYER;
        HairSpriteRend.sortingLayerName = SETUP_PLAYER_SORT_LAYER;
        SetPositionForSetup();
        SpriteRend.color = Colors.HexToColor(Avatar.Instance.SkinColor);
        HairSpriteRend.color = Colors.HexToColor(Avatar.Instance.HairColor);
        if (Avatar.Instance.Color == TeamColor.RED)
            ShirtSpriteRend.color = Colors.RedShirtColor;
        else
            ShirtSpriteRend.color = Colors.BlueShirtColor;
        Anim.SetTrigger("Run");

        //Debug.Log("initalized!");
    }

    public void InitializeForDefense(Vector2 scale, Vector2 offset, CampConquer.Point point)
    {
        _battleSetup = true;
        _setupScale = scale;
        _setupOffset = offset;
        _pathIndex = 0;
        _position = CalcPositionForSetup(point);
        _destination = _position;
        SpriteRend.sortingLayerName = SETUP_PLAYER_SORT_LAYER;
        ShirtSpriteRend.sortingLayerName = SETUP_PLAYER_SORT_LAYER;
        ShortsSpriteRend.sortingLayerName = SETUP_PLAYER_SORT_LAYER;
        ShoesSpriteRend.sortingLayerName = SETUP_PLAYER_SORT_LAYER;
        HairSpriteRend.sortingLayerName = SETUP_PLAYER_SORT_LAYER;
        SetPositionForSetup();
        SpriteRend.color = Colors.HexToColor(Avatar.Instance.SkinColor);
        HairSpriteRend.color = Colors.HexToColor(Avatar.Instance.HairColor);
        if (Avatar.Instance.Color == TeamColor.RED)
            ShirtSpriteRend.color = Colors.RedShirtColor;
        else
            ShirtSpriteRend.color = Colors.BlueShirtColor;
        Anim.SetTrigger("Throw");
    }

    Vector2 CalcPositionForSetup(Point point)
    {
        return new Vector2(point.x * _setupScale.x + _setupOffset.x, point.y * _setupScale.y + _setupOffset.y);
    }

    void CalcStatValues()
    {
        // calculate actual stat values from attribute values
        _healthCalc = BASE_HEALTH + _health;
        _speedCalc = BASE_SPEED + (((float)_speed / MAX_SPEED) * SPEED_FACTOR);
        _speedCalc *= SPEED_SETTING;
        _rangeCalc = BASE_RANGE + (((float)_range / MAX_RANGE) * RANGE_FACTOR);
    }

    public void SetDefenseDir(PieceDir dir)
    {
        _dir = dir;
        if (_dir == PieceDir.LEFT)
            transform.eulerAngles = new Vector3(0.0f, 180.0f, 0.0f);
    }

    void GetNextDestination()
    {
        if (_moveState == PieceMoveState.NONE)
        {
            //Debug.Log("getnextdest - pathIndex = " + _pathIndex + " current x count = " + _currentPath.X.Count);
            if (_currentPath != null && _currentPath.Points.Count > _pathIndex)
            {
                _destination = new Vector2(_currentPath.Points[_pathIndex].x, _currentPath.Points[_pathIndex].y);
                //Debug.Log("destination = " + _destination);
            }
        }
        else
        {
            if (_moveState == PieceMoveState.SET_NODE)
            {
                _moveState = PieceMoveState.HIT_NODE;
            }
        }
    }

    void GetNextDestinationForSetup()
    {
        if (_currentPath != null && _currentPath.Points.Count > _pathIndex)
        {
            _destination = CalcPositionForSetup(_currentPath.Points[_pathIndex]);
            //_destination = new Vector2(_currentPath.Points[_pathIndex].X, _currentPath.Points[_pathIndex].Y);
        }
        else
        {
            _pathIndex = 0;
            _position = CalcPositionForSetup(_currentPath.Points[0]);
            _destination = CalcPositionForSetup(_currentPath.Points[1]);
            //_position = new Vector2(_currentPath.Points[0].X, _currentPath.Points[0].Y);
            //_destination = new Vector2(_currentPath.Points[1].X, _currentPath.Points[1].Y);
        }
    }

    public void SetDestinationForCapturedFlag(Flag enemyFlag)
    {
        if (enemyFlag.Status == FlagStatus.CAPTURED)
        {
            MapNode closestNode = null;
            switch (_moveState)
            {
                case PieceMoveState.NONE:
                    closestNode = PathManager.Instance.GetClosestNodePos(_position);
                    if (closestNode != null)
                    {
                        _destination = new Vector2(closestNode.Point.x, closestNode.Point.y);
                        _moveState = PieceMoveState.SET_NODE;
                        _lastNode = _currentNode;
                        _currentNode = closestNode;
                    }
                    break;
                case PieceMoveState.SET_NODE:
                case PieceMoveState.HIT_NODE:
                    if (Utilities.CloseEnough(_position, _destination))
                    {
                        if (_lastNode != null)
                            closestNode = PathManager.Instance.GetLinkedNodeClosestToPosNotLastNode(_currentNode, enemyFlag.Position, _lastNode);
                        else
                            closestNode = PathManager.Instance.GetLinkedNodeClosestToPos(_currentNode, enemyFlag.Position);
                        if (closestNode != null)
                        {
                            _destination = new Vector2(closestNode.Point.x, closestNode.Point.y);
                            _moveState = PieceMoveState.SET_NODE;
                            _lastNode = _currentNode;
                            _currentNode = closestNode;
                        }
                    }
                    break;
            }
        }
        else
        {
            MapNode closestNode = null;
            float distanceToFlag = (_position - enemyFlag.Position).magnitude;
            if (_closestToFlag && distanceToFlag < 1.0f)
            {
                _destination = enemyFlag.Position;
            }
            else
            {
                switch (_moveState)
                {
                    case PieceMoveState.NONE:
                        closestNode = PathManager.Instance.GetClosestNodePos(_position);
                        if (closestNode != null)
                        {
                            _destination = new Vector2(closestNode.Point.x, closestNode.Point.y);
                            _moveState = PieceMoveState.SET_NODE;
                            _currentNode = closestNode;
                        }
                        break;
                    case PieceMoveState.SET_NODE:
                    case PieceMoveState.HIT_NODE:
                        if (Utilities.CloseEnough(_position, _destination))
                        {
                            if (_lastNode != null)
                                closestNode = PathManager.Instance.GetLinkedNodeClosestToPosNotLastNode(_currentNode, enemyFlag.Position, _lastNode);
                            else
                                closestNode = PathManager.Instance.GetLinkedNodeClosestToPos(_currentNode, enemyFlag.Position);
                            if (closestNode != null)
                            {
                                _destination = new Vector2(closestNode.Point.x, closestNode.Point.y);
                                _moveState = PieceMoveState.SET_NODE;
                                _currentNode = closestNode;
                            }
                        }
                        break;
                }
            }
        }
    }

    public void Move()
    {
        if (IsClimbing() && (_animationState == PieceAnimationState.HIT || _animationState == PieceAnimationState.THROW))
        {
            _animationState = PieceAnimationState.CLIMB;
            _lastTrigger = "Climb";
        }

        if (_role == PieceRole.OFFENSE && (_animationState == PieceAnimationState.RUN || _animationState == PieceAnimationState.NONE || _animationState == PieceAnimationState.CLIMB))
        {
            if (_position != _destination)
            {
                if (CheckClimbPos())
                {
                    if (!IsClimbing())
                        SetClimbAnimation();
                }
                else if (!IsRunning())
                    SetRunAnimation();

                float xDiff = _destination.x - _position.x;
                if (xDiff < 0.0f && _dir != PieceDir.LEFT)
                {
                    transform.eulerAngles = new Vector3(0.0f, 180.0f, 0.0f);
                    _dir = PieceDir.LEFT;
                }
                else if (xDiff > 0.0f && _dir != PieceDir.RIGHT)
                {
                    transform.eulerAngles = new Vector3(0.0f, 0.0f, 0.0f);
                    _dir = PieceDir.RIGHT;
                }
            }

            Vector2 oldPosition = _position;
            if (Utilities.CloseEnough(_position, _destination))
            {
                _position = _destination;
                SetPosition();
                _pathIndex++;
                if (_hasFlag)
                    _destination = _team.GetNextHomeDestination(_position);
                else
                    GetNextDestination();
            }
            else
            {
                Vector2 direction = ((_destination - _position).normalized) * (SPEED * _speedCalc);
                _position += direction;
                SetPosition();
            }

            if (_hasFlag)
                AddToDistanceWithFlag(oldPosition, _position);
        }
    }

    public void MoveForSetup()
    {
        Vector2 oldPosition = _position;
        if (Utilities.CloseEnough(_position, _destination))
        {
            _position = _destination;
            _pathIndex++;
            GetNextDestinationForSetup();
        }
        else
        {
            Vector2 direction = ((_destination - _position).normalized) * (SPEED * SETUP_RUN_SPEED);
            _position += direction;

        }
        SetPositionForSetup();
    }

    void AddToDistanceWithFlag(Vector2 start, Vector2 end)
    {
        _distanceWithFlag += (end - start).magnitude;
    }

    public void SetPosition()
    {
        transform.localPosition = new Vector2(_position.x, _position.y);
        SetSpriteSortingOrder();
    }

    void SetPositionForSetup()
    {
        transform.localPosition = new Vector3(_position.x, _position.y, -9.5f);
        SetSpriteSortingOrder();
    }

    void SetSpriteSortingOrder()
    {
        // set sorting order. get distance from top of screen, and translate into integer sorting order (* 100)
        int bodySortOrder = (int)((MAX_Y - _position.y) * 100.0f);
        SpriteRend.sortingOrder = bodySortOrder;
        if (ShirtSpriteRend != null)
        {
            ShirtSpriteRend.sortingOrder = bodySortOrder + 1;
            ShortsSpriteRend.sortingOrder = bodySortOrder + 1;
            ShoesSpriteRend.sortingOrder = bodySortOrder + 1;
            HairSpriteRend.sortingOrder = bodySortOrder + 1;
        }
    }

    public bool GetHit(int hitPoints)
    {
        if (_animationState != PieceAnimationState.HIT)
        {
            Anim.SetTrigger("Hit");
            _lastTrigger = "Hit";
            _animationState = PieceAnimationState.HIT;
        }
        //Debug.Log(this.name + " GetHit");

        bool hadFlag = false;
        _healthCalc -= hitPoints;
        if (_healthCalc <= 0)
        {
            _healthCalc = 0;
            _status = PieceStatus.OUT;
            enabled = true;
            _outTimer = OUT_TIME;
            StopAnimation();
            _team.Downs++;
            _downs++;

            if (_hasFlag)
            {
                hadFlag = true;
                _hasFlag = false;
            }
        }

        return hadFlag;
    }

    void GenerateRandomAmmo()
    {
        int gold = 80;
        int typeIndex = -1;
        while (gold > 0)
        {
            if (gold >= 50)
            {
                typeIndex = UnityEngine.Random.Range(0, 3);
            }
            else if (gold >= 30)
            {
                typeIndex = UnityEngine.Random.Range(0, 2);
            }
            else
            {
                typeIndex = 0;
            }

            gold -= AmmoManager.Instance.AmmoDataList[typeIndex].Cost;
            _ammo.AddAmmo((AmmoType)typeIndex);
            //_ammoList.Add((AmmoType)typeIndex);
        }
    }

    public AmmoType Throw()
    {
        PlayThrowSound();

        AmmoType type = _ammo.GetNextAmmo();
        _team.BalloonsThrown++;
        _balloonsThrown++;

        PlayThrowAnimation();

        return type;
    }
    #endregion

    #region Replay Methods
    public void SetReplayPosition(Vector2 position, string trigger, int status)
    {
        // if player has moved and they are not out, move the player and set their direction
        if (_position != position && _status != PieceStatus.OUT)
        {
            float xDiff = position.x - _position.x;
            if (xDiff < 0.0f && _dir != PieceDir.LEFT)
            {
                transform.eulerAngles = new Vector3(0.0f, 180.0f, 0.0f);
                _dir = PieceDir.LEFT;
            }
            else if (xDiff > 0.0f && _dir != PieceDir.RIGHT)
            {
                transform.eulerAngles = new Vector3(0.0f, 0.0f, 0.0f);
                _dir = PieceDir.RIGHT;
            }
            _position = position;
            SetPosition();
        }
        // check if player is out
        if (_status != PieceStatus.OUT && (PieceStatus)status == PieceStatus.OUT)
        {
            //Debug.Log("piece is out!");
            _status = PieceStatus.OUT;
            enabled = true;
            _outTimer = OUT_TIME;
            StopAnimation();
        }
        // set animation trigger for Run, Throw, Hit and Default
        if (trigger != "" && _status != PieceStatus.OUT)
            Anim.SetTrigger(trigger);
    }

    public void RecordMove()
    {
        if (_lastPosition != _position || _lastStatus != _status || _lastHasFlag != _hasFlag || DataRecorder.Instance.TurnDataList.Count == 0)
            DataRecorder.Instance.AddMoveToTurnData(this);
    }

    public void SetLastInfo()
    {
        _lastHasFlag = _hasFlag;
        _lastPosition = _position;
        _lastStatus = _status;
    }
    #endregion

    #region Animation Methods
    bool IsClimbing()
    {
        return (Anim.GetCurrentAnimatorStateInfo(0).IsName("Climb"));
    }

    bool IsRunning()
    {
        return (Anim.GetCurrentAnimatorStateInfo(0).IsName("Run"));
    }

    void SetRunAnimation()
    {
        Anim.SetTrigger("Run");
        _lastTrigger = "Run";
        _animationState = PieceAnimationState.RUN;
    }

    void SetClimbAnimation()
    {
        //Debug.Log(this.name + " setclimb");
        Anim.SetTrigger("Climb");
        _lastTrigger = "Climb";
        _animationState = PieceAnimationState.CLIMB;
    }

    /*
    void CheckClimbAnimation()
    {
        if (CheckClimbPos() && _lastTrigger != "Climb")
        {
            Anim.SetTrigger("Climb");
            _lastTrigger = "Climb";
        }
    }
    */

    bool CheckClimbPos()
    {
        if (_position.y >= CLIMB_Y_MIN && _position.y <= CLIMB_Y_MAX && ((_position.x >= LEFT_CLIMB_X_MIN && _position.x <= LEFT_CLIMB_X_MAX) || (_position.x >= RIGHT_CLIMB_X_MIN && _position.x <= RIGHT_CLIMB_X_MAX)))
        {
            return true;
        }
        return false;
    }

    void PlayThrowAnimation()
    {
        Anim.SetTrigger("Throw");
        _lastTrigger = "Throw";
        _animationState = PieceAnimationState.THROW;

        //Debug.Log(this.name + " Throw");
    }

    public void EndThrow()
    {
        if (_battleSetup)
        {
            _animTimer = ANIM_DELAY;
            enabled = true;
            //Anim.SetTrigger("Throw");
        }
        else
        {
            if (_role == PieceRole.OFFENSE)
            {
                //SetRunAnimation();
                _animationState = PieceAnimationState.NONE;

                //Debug.Log(this.name + " EndThrow");
                /*
                if (CheckClimbPos() && _animationState != PieceAnimationState.CLIMB)
                    SetClimbAnimation();
                else
                    SetRunAnimation();
                    */
            }
            else
            {
                _animationState = PieceAnimationState.NONE;
                Anim.SetTrigger("Default");
                _lastTrigger = "Default";
            }
        }
    }

    public void EndHit()
    {
        if (_role == PieceRole.OFFENSE)
        {
            _animationState = PieceAnimationState.NONE;
            if (_id == 365)
                Debug.Log("finish hit animation - health = " + _health);
        }
        else
        {
            _animationState = PieceAnimationState.NONE;
            Anim.SetTrigger("Default");
            _lastTrigger = "Default";
        }
    }

    public void StopAnimation()
    {
        if (Anim != null)
            Anim.enabled = false;
    }

    public void SetTriggerFromData(string trigger)
    {
        Anim.SetTrigger(trigger);
    }

    public void StartRunning()
    {
        Anim.SetTrigger("Run");
    }
    #endregion

    #region Audio Methods
    public void PlayThrowSound()
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.THROW);
    }
    #endregion

    #region Accessors
    public PieceRole Role
    { 
        get { return _role; }
    }

    public PieceStatus Status
    {
        get { return _status; }
        set { _status = value; }
    }

    public Vector2 Position
    {
        get { return _position; }
        set { _position = value; }
    }

    public Vector2 Destination
    {
        get { return _destination; }
        set { _destination = value; }
    }

    public string Name
    {
        get { return _name; }
        set { _name = value; }
    }

    public int ID
    {
        get { return _id; }
        set { _id = value; }
    }

    public string LastTrigger
    {
        get { return _lastTrigger; }
        set { _lastTrigger = value; }
    }

    public Path CurrentPath
    {
        get { return _currentPath; }
        set { _currentPath = value; }
    }

    public float CoolDownTime
    {
        get { return _coolDownTime; }
        set { _coolDownTime = value; }
    }

    public float CoolDownTimer
    {
        get { return _coolDownTimer; }
        set { _coolDownTimer = value; }
    }

    public float RangeCalc
    {
        get { return _rangeCalc; }
        set { _rangeCalc = value; }
    }

    public int PathIndex
    {
        get { return _pathIndex; }
        set { _pathIndex = value; }
    }

    public int HealthCalc
    {
        get { return _healthCalc; }
        set { _healthCalc = value; }
    }

    public float SpeedCalc
    {
        get { return _speedCalc; }
    }

    public float DistanceWithFlag
    {
        get { return _distanceWithFlag; }
        set { _distanceWithFlag = value; }
    }

    public int Health
    {
        get { return _health; }
        set { _health = value; }
    }

    public int Speed
    {
        get { return _speed; }
        set { _speed = value; }
    }

    public int Range
    {
        get { return _range; }
        set { _range = value; }
    }

    public bool HasFlag
    {
        get { return _hasFlag; }
        set { _hasFlag = value; }
    }

    public bool LastHasFlag
    {
        get { return _lastHasFlag; }
        set { _lastHasFlag = value; }
    }

    public Team GetTeam
    {
        get { return _team; }
    }

    public bool ClosestToFlag
    {
        get { return _closestToFlag; }
        set { _closestToFlag = value; }
    }

    public AmmoBandelier Ammo
    {
        get { return _ammo; }
        set { _ammo = value; }
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

    public int Pickups
    {
        get { return _pickups; }
        set { _pickups = value; }
    }

    public int Takedowns
    {
        get { return _takedowns; }
        set { _takedowns = value; }
    }
    #endregion
}