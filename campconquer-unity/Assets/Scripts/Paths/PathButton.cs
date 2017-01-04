using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PathButton : MonoBehaviour 
{
    public PathItem PathItem;

	void OnMouseUp()
    {
        PathItem.Click();
    }
}