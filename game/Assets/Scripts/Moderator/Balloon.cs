using UnityEngine;

public class Balloon : MonoBehaviour 
{
    #region Constants
    const float SPEED = 0.075f;
    #endregion

    #region Public Vars
    public SpriteRenderer SpriteRend;
    public Sprite RedBalloonSprite;
    public Sprite BlueBalloonSprite;
    public Sprite RedArrowSprite;
    public Sprite BlueArrowSprite;
    public Sprite RedBombSprite;
    public Sprite BlueBombSprite;
    #endregion

    #region Private Vars
    AmmoType _type;
    Vector3 _destination;
    bool _thrown;
    bool _done;
    #endregion

    #region Unity Methods
	void Update() 
    {
        if (_thrown)
        {
            Vector3 dir = (_destination - transform.localPosition).normalized * SPEED;
            transform.localPosition = transform.localPosition + dir;
            if (Utilities.CloseEnough(transform.localPosition, _destination))
            {
                SoundManager.Instance.PlaySoundEffect(SoundType.SPLASH);
                _done = true;
                enabled = false;
                SpriteRend.enabled = false;
            }
        }
	}
    #endregion

    #region Methods
    public void StartThrow(Vector3 position, Vector3 destination, AmmoType type, TeamColor color)
    {
        transform.localPosition = position;
        _destination = destination;
        // flip if going right
        if (transform.localPosition.x < _destination.x)
            SpriteRend.flipX = true;
        _thrown = true;
        _type = type;
        switch (_type)
        {
            case AmmoType.BALLOON:
                if (color == TeamColor.RED)
                    SpriteRend.sprite = RedBalloonSprite;
                else
                    SpriteRend.sprite = BlueBalloonSprite;
                break;
            case AmmoType.ARROW:
                if (color == TeamColor.RED)
                    SpriteRend.sprite = RedArrowSprite;
                else
                    SpriteRend.sprite = BlueArrowSprite;
                break;
            case AmmoType.BOMB:
                if (color == TeamColor.RED)
                    SpriteRend.sprite = RedBombSprite;
                else
                    SpriteRend.sprite = BlueBombSprite;
                break;
        }
    }
    #endregion

    #region Accessors
    public bool Done
    {
        get { return _done; }
    }
    #endregion
}