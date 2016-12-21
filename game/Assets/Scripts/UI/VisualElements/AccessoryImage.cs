using UnityEngine;
using System.Collections;

using gametheory.UI;

public class AccessoryImage : ExtendedImage
{
	#region Methods
	public void Remove()
	{
		Destroy(gameObject);
	}
	#endregion
}
