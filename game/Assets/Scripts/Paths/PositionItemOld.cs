using UnityEngine;
using UnityEngine.UI;
using gametheory.UI;

public class PositionItemOld : MonoBehaviour
{
    #region Events
    public static System.Action<Vector2> clickPosition;
    #endregion

    #region Public Vars
    public Image Image;
    public ExtendedText PlayerCount;
    public ExtendedImage BodyImage;
    #endregion

    #region Private Vars
    Vector2 _position;
    int _count;
    bool _selected;
    #endregion

    #region Unity Methods
    void Start()
    {
        enabled = false;
    }
    #endregion

    #region Methods
    public void Initialize()
    {
        PlayerCount.Init();
        PlayerCount.Activate();
        BodyImage.Activate();
        BodyImage.Deactivate();
    }

    public void SetPosition(Vector2 position)
    {
        _position = position;
    }

    public void Click()
    {
        if (clickPosition != null)
            clickPosition(_position);
        if (!_selected)
        {
            //Image.color = Color.black;
            _selected = true;
            transform.localScale = new Vector3(5.0f, 5.0f, 5.0f);
            BodyImage.Activate();
            this.transform.SetAsLastSibling();
        }
        else
        {
            Unselect();
        }
    }

    public void Unselect()
    {
        _selected = false;
        Image.color = Color.white;
        transform.localScale = new Vector3(3.0f, 3.0f, 3.0f);
        BodyImage.Deactivate();
    }

    public void Remove()
    {
    }

    public void SetCount(int count)
    {
        _count = count;
        if (_count > 0)
        {
            PlayerCount.Activate();
            PlayerCount.Text = _count.ToString();
        }
        else
        {
            PlayerCount.Deactivate();
        }
    }
    #endregion

    #region Accessors
    public bool Selected
    {
        get { return _selected; }
    }

    public Vector2 Position
    {
        get { return _position; }
    }
    #endregion
}