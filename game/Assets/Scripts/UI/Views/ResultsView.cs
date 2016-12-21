using UnityEngine;
using gametheory.UI;
using System;

public class ResultsView : UIView 
{
    #region Public Vars
    public ExtendedImage RedBanner;
    public ExtendedText RedTD;
    public ExtendedText RedPeople;
    public ExtendedText RedOMVP;
    public ExtendedText RedDMVP;
    public ExtendedText RedPrizes;

    public ExtendedImage BlueBanner;
    public ExtendedText BlueTD;
    public ExtendedText BluePeople;
    public ExtendedText BlueOMVP;
    public ExtendedText BlueDMVP;
    public ExtendedText BluePrizes;
    #endregion

    #region Overridden Methods
    protected override void OnActivate()
    {
        base.OnActivate();

        LoadingAlert.FinishLoading();
        SoundManager.Instance.StopMusic();
    }
    #endregion

    #region UI Methods
    public void Init(Team redTeam, Team blueTeam, TimeSpan gameTime)
    {
        // display all game info
        if (redTeam.Status == TeamStatus.WON)
        {
            RedBanner.Activate();
            RedPrizes.Text = "     x 1";
            BluePrizes.Text = "     x 0";
        }
        else if (blueTeam.Status == TeamStatus.WON)
        {
            BlueBanner.Activate();
            RedPrizes.Text = "     x 0";
            BluePrizes.Text = "     x 1";
        }
        else
        {
            RedPrizes.Text = "     x 0";
            BluePrizes.Text = "     x 0";
        }

        RedTD.Text = redTeam.Downs.ToString();
        RedPeople.Text = redTeam.FlagCaptures.ToString();
        if (redTeam.AttackMVP)
        {
            RedOMVP.Text = redTeam.AttackMVP.Name;
        }
        else
        {
            RedOMVP.Text = "None";
        }

        if (redTeam.DefendMVP)
        {
            RedDMVP.Text = redTeam.DefendMVP.Name;
        }
        else
            RedDMVP.Text = "None";

        BlueTD.Text = blueTeam.Downs.ToString();
        BluePeople.Text = blueTeam.FlagCaptures.ToString();

        //Debug.Log("about to set blue attack mvp " + blueTeam.AttackMVP.Name);

        if (blueTeam.AttackMVP != null)
        {
            BlueOMVP.Text = blueTeam.AttackMVP.Name;
        }
        else
            BlueOMVP.Text = "None";
        if (blueTeam.DefendMVP != null)
        {
            BlueDMVP.Text = blueTeam.DefendMVP.Name;
        }
        else
            BlueDMVP.Text = "None";

        // play the correct sound effect
        if (GameManager.Client)
        {
            if (GameManager.ClientColor == TeamColor.RED)
            {
                if (redTeam.Status == TeamStatus.WON)
                    SoundManager.Instance.PlaySoundEffect(SoundType.WIN);
                else
                    SoundManager.Instance.PlaySoundEffect(SoundType.LOSE);
            }
            else
            {
                if (blueTeam.Status == TeamStatus.WON)
                    SoundManager.Instance.PlaySoundEffect(SoundType.WIN);
                else
                    SoundManager.Instance.PlaySoundEffect(SoundType.LOSE);
            }
        }
        else
        {
            SoundManager.Instance.PlaySoundEffect(SoundType.WIN);
        }
    }
    #endregion
}