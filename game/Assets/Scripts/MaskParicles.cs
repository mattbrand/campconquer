using UnityEngine;
using System.Collections;

public class MaskParicles : MonoBehaviour 
{
    public Camera ParticleCamera;

	void Start() 
    {
	
	}
	
	void Update() 
    {
	    RenderTexture rt = new RenderTexture(960, 640, 24);
        Camera.main.targetTexture = rt;
        Texture2D tex = new Texture2D(960, 640, TextureFormat.ARGB32, false);
        Camera.main.Render();
        RenderTexture.active = rt;
        tex.ReadPixels(new Rect(ParticleCamera.transform.position.x, ParticleCamera.transform.position.y, 960, 640), 0, 0);
        Camera.main.targetTexture = null;
        RenderTexture.active = null; // JC: added to avoid errors
        Destroy(rt);


        tex.Apply();
        //CameraObj.GetComponent<Image>().sprite = Sprite.Create(tex, new Rect(0, 0, 960, 640), new Vector2(0.0f, 0.0f));
	}
}
