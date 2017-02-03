using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StoreRefreshButton : MonoBehaviour 
{
    #region Public Vars
    public static event System.Action RefreshStoreData;
    #endregion

    #region Methods
    public void ClickRefresh()
    {
        if (RefreshStoreData != null)
            RefreshStoreData();
    }
    #endregion
}