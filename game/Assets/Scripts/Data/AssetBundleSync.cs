using UnityEngine;

/// <summary>
/// Legacy-ish. Used to pull asset bundles using Parse, but that has
/// shutdown, so we just access information locally. I've left the class
/// intact incase we switch to another service in the future.
/// </summary>
public class AssetBundleSync : MonoBehaviour 
{
	#region Public Vars
	public static AssetBundleSync Instance = null;
	#endregion

	#region Unity Methods
	void Awake()
	{
		if(Instance == null)
		{
			Instance = this;
			DontDestroyOnLoad(gameObject);
		}
		else
			Destroy(gameObject);
	}
	#endregion

	#region Methods
	public TextAsset GetFile(string name)
	{
		return Resources.Load<TextAsset>(System.IO.Path.Combine("Databases", name));
	}
	#endregion
}