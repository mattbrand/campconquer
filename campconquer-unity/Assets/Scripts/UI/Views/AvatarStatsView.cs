using UnityEngine;
using UnityEngine.UI;
using System.Collections;
using gametheory.UI;

public class AvatarStatsView : UIView 
{
    #region Events
    public static System.Action<bool> setNextButton;
    #endregion

    #region Constants
    const int TOTAL_POINTS = 10;
    #endregion

    #region Public Vars
    public ExtendedInputField NameInput;
    public Image[] HealthImages;
    public Image[] RangeImages;
    public Image[] SpeedImages;
    public ExtendedText PointsLeft;
    #endregion

    #region Private Vars
    int _health;
    int _range;
    int _speed;
    int _points = TOTAL_POINTS;
    bool _nameReady;
    #endregion

    #region Overridden Methods
    protected override void OnInit()
    {
        base.OnInit();

        _nameReady = false;
    }

    protected override void OnActivate()
    {
        base.OnActivate();

        _health = Avatar.Instance.Health;
        _speed = Avatar.Instance.Speed;
        _range = Avatar.Instance.Range;
        _points -= (_health + _speed + _range);
        SetHealthImages();
        SetSpeedImages();
        SetRangeImages();
        NameInput.Text = Avatar.Instance.Name;
        ChangedName();
    }
    #endregion

    #region UI Methods
    public static AvatarStatsView Load()
    {
        AvatarStatsView view = UIView.Load("Views/AvatarStatsView", OverriddenViewController.Instance.transform) as AvatarStatsView;
        view.name = "AvatarStatsView";
        return view;
    }

    public void ClickHealth(int value)
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.SOFT_CLICK);

        int neededVal = value - _health;
        if (neededVal > 0)
        {
            if (neededVal > _points)
            {
                neededVal = _points;
            }

            _health += neededVal;
            _points -= neededVal;
        }
        else if (neededVal < 0)
        {
            _health = value;
            _points -= neededVal;
        }
        else
        {
            _points += _health;
            _health = 0;
        }

        Avatar.Instance.Health = _health;

        SetDisplay();
        SetHealthImages();
    }

    void SetHealthImages()
    {
        for(int i = 0; i < HealthImages.Length; i++)
        {
            if (i < _health)
                HealthImages[i].color = Colors.ActiveColor;
            else
                HealthImages[i].color = Colors.InactiveColor;
        }
    }

    public void ClickSpeed(int value)
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.SOFT_CLICK);

        int neededVal = value - _speed;
        if (neededVal > 0)
        {
            if (neededVal > _points)
            {
                neededVal = _points;
            }

            _speed += neededVal;
            _points -= neededVal;
        }
        else if (neededVal < 0)
        {
            _speed = value;
            _points -= neededVal;
        }
        else
        {
            _points += _speed;
            _speed = 0;
        }

        Avatar.Instance.Speed = _speed;

        SetDisplay();
        SetSpeedImages();
    }

    void SetSpeedImages()
    {
        for (int i = 0; i < SpeedImages.Length; i++)
        {
            if (i < _speed)
                SpeedImages[i].color = Colors.ActiveColor;
            else
                SpeedImages[i].color = Colors.InactiveColor;
        }
    }

    public void ClickRange(int value)
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.SOFT_CLICK);

        int neededVal = value - _range;
        if (neededVal > 0)
        {
            if (neededVal > _points)
            {
                neededVal = _points;
            }

            _range += neededVal;
            _points -= neededVal;
        }
        else if (neededVal < 0)
        {
            _range = value;
            _points -= neededVal;
        }
        else
        {
            _points += _range;
            _range = 0;
        }

        Avatar.Instance.Range = _range;

        SetDisplay();
        SetRangeImages();
    }

    void SetRangeImages()
    {
        for (int i = 0; i < RangeImages.Length; i++)
        {
            if (i < _range)
                RangeImages[i].color = Colors.ActiveColor;
            else
                RangeImages[i].color = Colors.InactiveColor;
        }
    }

    void SetDisplay()
    {
        PointsLeft.Text = "Remaining: " + _points.ToString() + "/" + TOTAL_POINTS.ToString();

        if (setNextButton != null)
        {
            if (_points == 0 && _nameReady)
                setNextButton(true);
            else
                setNextButton(false);
        }
    }

    public void ChangedName()
    {
        if (NameInput.Text.Length > 0 && NameInput.Text != "Name")
            _nameReady = true;
        else
            _nameReady = false;
        Avatar.Instance.Name = NameInput.Text;
        SetDisplay();
    }

    public void EndEditName()
    {
    }
    #endregion
}