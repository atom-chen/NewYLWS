using UnityEngine;
using UnityEngine.UI;
using XLua;
using DG.Tweening;

[Hotfix]
[LuaCallCSharp]
public class UISliderHelper : MonoBehaviour 
{
    public Slider slider;

    private Transform m_transThis = null;

    private void Start()
    {
        m_transThis = transform;
    }

    public float GetSliderValue()
    {
        if (slider != null)
        {
            return slider.value;
        }
        return 0;
    }

    public void UpdateSliderImmediately(float value)
    {
        if (slider != null)
        {
            slider.value = value;
        }
    }

    public void TweenUpdateSlider(float to, float duration)
    {
        StopDOTween();
        slider.DOValue(to, duration).SetDelay(0.2f).OnUpdate(OnTweenUpdate);
    }

    public void OnTweenUpdate()
    { 
    
    }

    public void Dispose()
    {
        StopDOTween();
    }

    public void StopDOTween()
    {
        DOTween.DOTween.Kill(slider);
    }
}
