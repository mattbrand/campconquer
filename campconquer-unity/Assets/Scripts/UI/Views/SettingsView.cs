using UnityEngine;
using gametheory.UI;

public class SettingsView : UIView
{
    #region Public Vars
    public ExtendedSlider MusicSlider;
    public ExtendedSlider SoundSlider;
    #endregion

    #region Overridden Methods
    protected override void OnActivate()
    {
        base.OnActivate();

        MusicSlider.Value = SoundManager.Instance.MaxMusicVolume;
        SoundSlider.Value = SoundManager.Instance.MaxSoundVolume;
    }
    #endregion

    #region Methods
    public static SettingsView Load()
    {
        SettingsView view = UIView.Load("Views/SettingsView", OverriddenViewController.Instance.transform) as SettingsView;
        view.name = "SettingsView";
        return view;
    }

    public void ChangeMusicSlider()
    {
        SoundManager.Instance.SlideMusicVolume(MusicSlider.Value);
    }

    public void ChangeSoundSlider()
    {
        SoundManager.Instance.SlideSoundVolume(SoundSlider.Value);
    }

    public void ClickBackButton()
    {
        SoundManager.Instance.PlaySoundEffect(SoundType.BUTTON_CLICK);

        UIViewController.DeactivateUIView("SettingsView");
    }
    #endregion
}