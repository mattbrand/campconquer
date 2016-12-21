using UnityEngine;
using gametheory.UI;

public class ClientGameManager : MonoBehaviour 
{
    #region Public Vars
    public static ClientGameManager Instance;
    #endregion

    #region Unity Methods
    void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
        }
        else
        {
            Destroy(gameObject);
        }
    }
    #endregion
}