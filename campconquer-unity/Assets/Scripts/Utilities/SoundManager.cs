using System;
using UnityEngine;

public enum SoundType { NONE=0, SPLASH, THROW, CHEER, FLAG_CAPTURE, ITEM_PURCHASE, COIN_CLAIM, BUTTON_CLICK, SOFT_CLICK, WIN, LOSE, COINS_TALLY, BALLOON_PURCHASE, ARROW_PURCHASE, BOMB_PURCHASE };

public class SoundManager : MonoBehaviour 
{
    #region Constants
    const string SAVE_SOUND = "Sound";
    const string SAVE_MUSIC = "Music";
    const string SAVE_MUSIC_VOLUME = "MusicVolume";
    const string SAVE_SOUND_VOLUME = "SoundVolume";

    const int SOUND_TIME_DELAY = 5; // in milliseconds

    const float MUSIC_PLAY_TIME = 600.0f;
    const float MUSIC_DELAY_TIME = 120.0f;

    const int MUSIC_FADE_FACTOR = 10;
    #endregion

    #region Public Vars
    public AudioClip SplashClip;
    public AudioClip ThrowClip;
    public AudioClip CheerClip;
    public AudioClip FlagCaptureClip;
    public AudioClip ButtonClickClip;
    public AudioClip CoinClaimClip;
    public AudioClip ItemPurchaseClip;
    public AudioClip SoftClickClip;
    public AudioClip WinClip;
    public AudioClip LoseClip;
    public AudioClip CoinTallyClip;
    public AudioClip BalloonPurchaseClip;
    public AudioClip ArrowPurchaseClip;
    public AudioClip BombPurchaseClip;
    public AudioClip BattleSong;
    public AudioClip MenuSong;

    public AudioSource SongSource;
    public AudioSource[] OtherSourceArray;
    public AudioSource[] ThrowSourceArray;
    public AudioSource[] SplashSourceArray;
    public AudioSource CoinsTallySource;

    public static SoundManager Instance = null;
    #endregion

    #region Private Vars
    DateTime _lastSplash;
    DateTime _lastThrow;

    float _musicTime;
    float _maxMusicVolume;
    float _fadeVolume;
    float _maxSoundVolume;

    bool _musicFadeOut;
    bool _musicFadeIn;
    bool _musicDelay;
    bool _sound;
    bool _music;
    #endregion

    #region Unity Methods
    void Awake()
    {
        if(Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(this.gameObject);
        }
        else
            Destroy(gameObject);

        // sound and music save info
        if (PlayerPrefs.HasKey(SAVE_SOUND))
        {
            if (PlayerPrefs.GetInt(SAVE_SOUND) == 0)
                _sound = false;
            else
                _sound = true;
        }
        else
            _sound = true;

        if (PlayerPrefs.HasKey(SAVE_MUSIC))
        {
            if (PlayerPrefs.GetInt(SAVE_MUSIC) == 0)
                _music = false;
            else
                _music = true;
        }
        else
            _music = true;

        _musicDelay = false;
        _musicFadeOut = false;
        _musicFadeIn = false;
        _musicTime = 0.0f;
        _fadeVolume = 1.0f;

        if (PlayerPrefs.HasKey(SAVE_MUSIC_VOLUME))
        {
            _maxMusicVolume = PlayerPrefs.GetFloat(SAVE_MUSIC_VOLUME);
            //PopUp.Instance.SetVolumeSlider(_maxMusicVolume);
        }
        else
            _maxMusicVolume = 1.0f;
        SetVolume();

        if (PlayerPrefs.HasKey(SAVE_SOUND_VOLUME))
        {
            _maxSoundVolume = PlayerPrefs.GetFloat(SAVE_SOUND_VOLUME);
            //PopUp.Instance.SetSoundVolumeSlider(_maxSoundVolume);
        }
        else
            _maxSoundVolume = 1.0f;
        SetSoundVolume();

        _lastSplash = DateTime.UtcNow;
        _lastThrow = DateTime.UtcNow;
    }

    void Update()
    {
        if (_music)
        {
            if (!_musicDelay)
            {
                if (_musicFadeOut)
                {
                    _fadeVolume -= (Time.deltaTime / MUSIC_FADE_FACTOR);
                    SetVolume();
                    if (SongSource.volume <= 0.0f)
                    {
                        SongSource.volume = 0.0f;
                        SongSource.Pause();
                        _musicFadeOut = false;
                        _musicDelay = true;
                    }
                }
                else
                {
                    _musicTime += Time.deltaTime;
                    if (_musicTime >= MUSIC_PLAY_TIME)
                    {
                        _musicTime = 0.0f;
                        _musicFadeOut = true;
                    }
                }
            }
            else
            {
                if (_musicFadeIn)
                {
                    _fadeVolume += (Time.deltaTime / MUSIC_FADE_FACTOR);
                    SetVolume();
                    if (SongSource.volume >= 1.0f)
                    {
                        SongSource.volume = 1.0f;
                        _musicFadeIn = false;
                        _musicDelay = false;
                    }
                }
                else
                {
                    _musicTime += Time.deltaTime;
                    if (_musicTime >= MUSIC_DELAY_TIME)
                    {
                        _musicTime = 0.0f;
                        _musicFadeIn = true;
                        SongSource.Play();
                    }
                }
            }
        }
    }
    #endregion

    #region Music and Sound
    public void ToggleMusic()
    {
        //Debug.Log("ToggleMusic with " + _music);

        if (_music)
        {
            _music = false;
            SongSource.Pause();
        }
        else
        {
            _music = true;
            SongSource.Play();
        }
        _musicTime = 0.0f;
        _musicDelay = false;
        _musicFadeOut = false;
        _musicFadeIn = false;
        PlayerPrefs.SetInt(SAVE_MUSIC, (_music ? 1 : 0));
        PlayerPrefs.Save();
    }

    public void ToggleSound()
    {
        if (_sound)
            _sound = false;
        else
            _sound = true;
        PlayerPrefs.SetInt(SAVE_SOUND, (_sound ? 1 : 0));
        PlayerPrefs.Save();
    }

    public void PlaySoundEffect(SoundType type)
    {
        if (_sound)
        {
            int index = FindAvailableAudioSourceIndex(type);
            if (index >= 0)
            {
                AudioSource source = null;
                float timeSinceLast = 0.0f;
                DateTime now = DateTime.UtcNow;

                switch (type)
                {
                    case SoundType.SPLASH:
                        timeSinceLast = (now - _lastSplash).Milliseconds;
                        if (timeSinceLast >= SOUND_TIME_DELAY)
                        {
                            source = SplashSourceArray[index];
                            source.clip = SplashClip;
                            _lastSplash = now;
                        }
                        break;
                    case SoundType.THROW:
                        timeSinceLast = (now - _lastThrow).Milliseconds;
                        if (timeSinceLast >= SOUND_TIME_DELAY)
                        {
                            source = SplashSourceArray[index];
                            source.clip = ThrowClip;
                            _lastThrow = now;
                        }
                        break;
                    case SoundType.CHEER:
                        source = OtherSourceArray[index];
                        source.clip = CheerClip;
                        break;
                    case SoundType.FLAG_CAPTURE:
                        source = OtherSourceArray[index];
                        source.clip = FlagCaptureClip;
                        break;
                    case SoundType.BUTTON_CLICK:
                        source = OtherSourceArray[index];
                        source.clip = ButtonClickClip;
                        break;
                    case SoundType.ITEM_PURCHASE:
                        source = OtherSourceArray[index];
                        source.clip = ItemPurchaseClip;
                        break;
                    case SoundType.COIN_CLAIM:
                        source = OtherSourceArray[index];
                        source.clip = CoinClaimClip;
                        break;
                    case SoundType.SOFT_CLICK:
                        source = OtherSourceArray[index];
                        source.clip = SoftClickClip;
                        break;
                    case SoundType.WIN:
                        source = OtherSourceArray[index];
                        source.clip = WinClip;
                        break;
                    case SoundType.LOSE:
                        source = OtherSourceArray[index];
                        source.clip = LoseClip;
                        break;
                    case SoundType.COINS_TALLY:
                        source = CoinsTallySource;
                        source.clip = CoinTallyClip;
                        break;
                    case SoundType.BALLOON_PURCHASE:
                        source = OtherSourceArray[index];
                        source.clip = BalloonPurchaseClip;
                        break;
                    case SoundType.ARROW_PURCHASE:
                        source = OtherSourceArray[index];
                        source.clip = ArrowPurchaseClip;
                        break;
                    case SoundType.BOMB_PURCHASE:
                        source = OtherSourceArray[index];
                        source.clip = BombPurchaseClip;
                        break;
                }
                if (source != null)
                    source.Play();
            }
        }
    }

    int FindAvailableAudioSourceIndex(SoundType type)
    {
        AudioSource[] sourceArray = OtherSourceArray;
        int index = -1;
        switch (type)
        {
            case SoundType.SPLASH:
                sourceArray = SplashSourceArray;
                break;
            case SoundType.THROW:
                sourceArray = ThrowSourceArray;
                break;
        }
        for (int i = 0; i < sourceArray.Length; i++)
        {
            if (!sourceArray[i].isPlaying)
            {
                index = i;
                break;
            }
        }
        return index;
    }

    public void StartBattleMusic()
    {
        SongSource.clip = BattleSong;
        StartMusic();
    }

    public void StartMenuMusic()
    {
        SongSource.clip = MenuSong;
        StartMusic();
    }

    void StartMusic()
    {
        SongSource.loop = true;
        if (_music)
        {
            SongSource.Play();
        }
    }

    public void StopMusic()
    {
        if (_music)
        {
            SongSource.Stop();
        }
    }

    public void SlideMusicVolume(float newVolume)
    {
        _maxMusicVolume = newVolume;
        SetVolume();
        PlayerPrefs.SetFloat(SAVE_MUSIC_VOLUME, newVolume);
        PlayerPrefs.Save();
    }

    void SetVolume()
    {
        SongSource.volume = _fadeVolume * _maxMusicVolume;
    }

    public void SlideSoundVolume(float newVolume)
    {
        _maxSoundVolume = newVolume;
        SetSoundVolume();
        PlayerPrefs.SetFloat(SAVE_SOUND_VOLUME, newVolume);
        PlayerPrefs.Save();
    }

    void SetSoundVolume()
    {
        int i;
        for (i = 0; i < SplashSourceArray.Length; i++)
        {
            SplashSourceArray[i].volume = _maxSoundVolume;
        }
        for (i = 0; i < ThrowSourceArray.Length; i++)
        {
            ThrowSourceArray[i].volume = _maxSoundVolume;
        }
        for (i = 0; i < OtherSourceArray.Length; i++)
        {
            OtherSourceArray[i].volume = _maxSoundVolume;
        }
    }

    public void SetBothVolumeSliders()
    {
        //MenuPopUp.Instance.SetVolumeSlider(_maxMusicVolume);
        //MenuPopUp.Instance.SetSoundVolumeSlider(_maxSoundVolume);
    }

    public void StopCoinTallySound()
    {
        CoinsTallySource.Stop();
    }
    #endregion

    #region Accessors
    public bool Sound
    {
        get { return _sound; }
    }

    public bool Music
    {
        get { return _music; }
    }

    public float MaxMusicVolume
    {
        get { return _maxMusicVolume; }
    }

    public float MaxSoundVolume
    {
        get { return _maxSoundVolume; }
    }
    #endregion
}