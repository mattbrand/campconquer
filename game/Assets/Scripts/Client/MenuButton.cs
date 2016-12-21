using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using gametheory.UI;

public class MenuButton : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler
{
    #region Constants
    const float LARGE_SCALE = 1.1f;
    #endregion

    #region Public Vars
    public Sprite MetalBorderButton;
    public Sprite NormalButton;
    public ExtendedButton Button;
    public RectTransform RectTransform;
    public bool ScaleUp;
    #endregion

    #region Methods
    public void OnPointerEnter(PointerEventData eventData)
    {
        Button.ButtonIconImage.sprite = MetalBorderButton;
        if (ScaleUp)
            RectTransform.localScale = new Vector3(LARGE_SCALE, LARGE_SCALE, LARGE_SCALE);
    }

    public void OnPointerExit(PointerEventData eventData)
    {
        Reset();
    }

    public void Reset()
    {
        Button.ButtonIconImage.sprite = NormalButton;
        RectTransform.localScale = Vector3.one;
    }
    #endregion
}