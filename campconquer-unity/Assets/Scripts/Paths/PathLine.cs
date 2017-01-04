using UnityEngine;
using System.Collections;

public class PathLine : MonoBehaviour 
{
    #region Constants
    const float UNSELECTED_LINE_ALPHA = 0.25f;
    const float COLLIDER_RADIUS = 0.2f;
    #endregion

    #region Public Vars
    public LineRenderer _line;
    public CapsuleCollider _collider;
    #endregion

    #region Private Vars
    PathItem _path;
    Color _selectedColor;
    Color _unselectedColor;
    Color _pulseColor;
    float _alpha;
    int _dir;
    bool _pulse;
    #endregion

    #region Unity Methods
    void Start()
    {
        //Debug.Log("line start");
        //PathItem.clickPath += Select;
    }

    void Update()
    {
        if (_pulse)
        {
            if (_dir == 1)
            {
                _alpha += 0.05f;
                if (_alpha >= 1.0f)
                {
                    _alpha = 1.0f;
                    _dir = -1;
                }
            }
            else
            {
                _alpha -= 0.05f;
                if (_alpha <= UNSELECTED_LINE_ALPHA)
                {
                    _alpha = UNSELECTED_LINE_ALPHA;
                    _dir = 1;
                }
            }
            _pulseColor.a = _alpha;
            _line.SetColors(_pulseColor, _pulseColor);
        }
    }

    void OnMouseDown()
	{
        /*
		//Debug.Log(name + " " +PathView.Instance.CanClick);
        if (PathView.Instance.CanClick)
            _path.ClickDot();
        */
    }

    void OnDestroy()
    {
        //PathItem.clickPath -= Select;
    }
    #endregion

    #region Methods
    public void Init(PathItem path, Vector3 start, Vector3 end, Color color, Material material)
    {
        if (Avatar.Instance.Color == TeamColor.RED)
        {
            _selectedColor = new Color(0.62f, 0.24f, 0.25f, 1.0f);
            _unselectedColor = new Color(0.62f, 0.24f, 0.25f, UNSELECTED_LINE_ALPHA);
        }
        else
        {
            _selectedColor = new Color(0.24f, 0.38f, 0.62f, 1.0f);
            _unselectedColor = new Color(0.24f, 0.38f, 0.62f, UNSELECTED_LINE_ALPHA);
        }
        //Debug.Log(_selectedColor);
        _alpha = UNSELECTED_LINE_ALPHA;
        _pulseColor = new Color(_selectedColor.r, _selectedColor.g, _selectedColor.b, _alpha);
        _dir = 1;
        _pulse = true;

        _path = path;

        // set up line
        Vector3[] array = new Vector3[2];
        array[0] = start;
        array[1] = end;
        _line.SetPositions(array);
        _line.material = material;
        _line.SetColors(color, color);
        _line.GetComponent<Renderer>().sortingLayerName = "UI";

        //Debug.Log(RoleView.UseCollidersForPaths);
        //if (RoleView.UseCollidersForPaths)
        {
            // set up collider
            _collider.radius = COLLIDER_RADIUS;
            _collider.center = Vector3.zero;
            _collider.direction = 2;
            _collider.transform.position = array[0] + (array[1] - array[0]) / 2;
            _collider.transform.LookAt(array[0]);
            _collider.height = (array[1] - array[0]).magnitude;
            _collider.isTrigger = true;
        }
    }

    public void Select(PathItem path)
    {
        _pulse = false;
        enabled = false;

        if (_path == path)
        {
            _line.SetColors(_selectedColor, _selectedColor);
            //Debug.Log("select path with " + _selectedColor);
        }
        else
            _line.SetColors(_unselectedColor, _unselectedColor);
    }

    public void Unselect()
    {
        _line.SetColors(_unselectedColor, _unselectedColor);
    }

    public void TurnOffCollider()
    {
        _collider.enabled = false;
    }
	public void TurnOnCollider()
	{
		_collider.enabled = true;
	}

    public void Destroy()
    {
        Destroy(_line.gameObject);
        Destroy(_collider.gameObject);
        //Debug.Log("destroyed collider");
    }
    #endregion
}