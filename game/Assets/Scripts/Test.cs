using UnityEngine;
using UnityEngine.UI;

public class Test : MonoBehaviour 
{
    public Image Image;
    public Color Color;

	// Use this for initialization
	void Start () 
    {
        enabled = false;
        Image.color = Color;
	}
}