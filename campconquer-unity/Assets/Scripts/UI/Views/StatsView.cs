using UnityEngine;
using UnityEngine.UI;
using gametheory.UI;

public class StatsView : UIView 
{
    #region Constants
    const int TOTAL_POINTS = 10;
    #endregion

    #region Public Vars
    public ExtendedButton NextButton;
    public ExtendedText PointsLeft;
    public Image[] HealthImages;
    public Image[] RangeImages;
    public Image[] SpeedImages;
    public Sprite FilledSprite;
    public Sprite EmptySprite;
    #endregion

    #region Private Vars
    int _health = 0;
    int _range = 0;
    int _speed = 0;
    int _points = TOTAL_POINTS;
    #endregion

    #region Overridden Methods
    protected override void OnActivate()
    {
        base.OnActivate();

        if(_points == 0)
            ShowNextButton();
        else
            HideNextButton();
    }
    #endregion

    #region UI Methods
    public static StatsView Load()
    {
        StatsView view = UIView.Load("Views/StatsView", OverriddenViewController.Instance.transform) as StatsView;
        view.name = "StatsView";
        return view;
    }

    public void ClickHealth(int value)
    {
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
        SetDisplay();
            
        for (int i = 0; i < HealthImages.Length; i++)
        {
            if (i < _health)
                HealthImages[i].sprite = FilledSprite;
            else
                HealthImages[i].sprite = EmptySprite;
        }
    }

    public void ClickSpeed(int value)
    {
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
        SetDisplay();

        for (int i = 0; i < SpeedImages.Length; i++)
        {
            if (i < _speed)
                SpeedImages[i].sprite = FilledSprite;
            else
                SpeedImages[i].sprite = EmptySprite;
        }
    }

    public void ClickRange(int value)
    {
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
        SetDisplay();

        for (int i = 0; i < RangeImages.Length; i++)
        {
            if (i < _range)
                RangeImages[i].sprite = FilledSprite;
            else
                RangeImages[i].sprite = EmptySprite;
        }
    }

    void SetDisplay()
    {
        PointsLeft.Text = _points.ToString() + " / " + TOTAL_POINTS.ToString();

        if (_points == 0)
            ShowNextButton();
        else
            HideNextButton();
    }

    void ShowNextButton()
    {
        NextButton.Activate();
    }

    void HideNextButton()
    {
        NextButton.Deactivate();
    }

    public void ClickNextButton()
    { 
        Avatar.Instance.SetAvatarStats(_health, _speed, _range);
        UIViewController.ActivateUIView(RoleView.Load());
        ClientGameManager.Instance.gameObject.SetActive(true);
        UIViewController.DeactivateUIView("BackgroundView");
        UIViewController.DeactivateUIView("StatsView");
    }

    public void ClickBack()
    {
        UIViewController.DeactivateUIView("StatsView");
        UIViewController.ActivateUIView(JobView.Load());
    }
    #endregion
}