using UnityEngine;
using XLua;
using DG.Tweening;
using System;

[Hotfix]
[LuaCallCSharp]

public class EyeBlinkEffect : PostRenderEffectBase
{
    public static EyeBlinkEffect instance = null;

    public Material m_mat;
    public float m_delay = 1f;
    public float m_duration = 1f;
    public float m_totalDuration = 0;
    public float m_blurAmount = 1f;
    // 用两个轴一起变化模拟眨眼效果
    public float m_blinkX = 1; //椭圆焦点在x轴, 这个变量代表长半轴 a
    public float m_blinkY = 0; //椭圆短半轴 b
    public Action m_callback = null;

    public static void ApplyBlinkEffect(Material mat, float delay, float duration, Action callback)
    {
        if (mat == null)
        {
            return;
        }
        
        if (instance!= null)
        {
            Destroy(instance);
            instance = null;
        }

        GameObject cameraGO = GameObject.Find("UIRoot/UICamera");
        if (cameraGO == null)
        {
            return;
        }
        instance = cameraGO.AddComponent<EyeBlinkEffect>();
        instance.m_mat = new Material(mat);
        instance.InitEffect(cameraGO.GetComponent<Camera>(), delay, duration, callback);
    }

    public static void StopBlinkEffect()
    {
        if (instance != null)
        {
            instance.Recover();
        }
    }

    private void InitEffect(Camera cam, float delay, float duration, Action callback)
    {
        m_delay = delay;
        m_duration = duration;
        m_totalDuration = m_duration;
        m_blinkX = 1;
        m_blinkY = 0;
        m_callback = callback;
        if (m_delay < 0f)
        {
            m_delay = 1f;
        }
        if (m_duration < 0)
        {
            m_duration = 1;
        }
        DOTween.DOTween.To((value) => { m_blinkX = 0.5f + value/2; m_blinkY = value*2; }, 0, 1, m_duration).SetEase(Ease.InExpo).SetDelay(delay);
        AddPostRenderEffect(cam, (CameraPostRender.PostRenderPriority.EyeBlinkEffect));
    }

    private void Recover()
    {
        Destroy(instance);
        instance = null;
    }

    void Update()
    {
        m_delay -= Time.deltaTime;
        if (m_delay <= 0 && m_duration > 0)
        {
            m_duration -= Time.deltaTime;
            m_blurAmount = 30 * m_duration / m_totalDuration;
            if (m_duration <= 0f)
            {
                Destroy(instance);
                instance = null;
                if (m_callback != null)
                {
                    m_callback();
                }
            }
        }
    }

    void OnDestroy()
    {
        m_mat = null;
        if (m_mat != null)
        {
            Destroy(m_mat);
            m_mat = null;
        }
        DelPostRenderEffect();
    }


    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (m_mat != null)
        {
            m_mat.SetFloat("_BlurAmount", m_blurAmount);
            m_mat.SetFloat("_BlinkX", m_blinkX);
            m_mat.SetFloat("_BlinkY", m_blinkY);

            Graphics.Blit(src, dest, m_mat);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
