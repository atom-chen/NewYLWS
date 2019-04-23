using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

[LuaCallCSharp]
[Hotfix]
public class MotionBlurEffect : MonoBehaviour {

    private static MotionBlurEffect instance = null;

    private RenderTexture m_accumulationTexture;
    private Material m_material = null;

    public float m_blurAmount = 0.8f;
    public float m_duration = 0;

    public static void ApplyEffect(GameObject cameraGO, Material mat, float duration, float blurAmount)
    {
        if (mat == null)
        {
            return;
        }

        if (instance != null)
        {
            Destroy(instance);
            instance = null;
        }

        instance = cameraGO.AddComponent<MotionBlurEffect>();
        instance.Init(new Material(mat), duration, blurAmount);
    }

    public void Init(Material mat, float duration, float blurAmount)
    {
        m_material = mat;
        m_duration = duration;
        m_blurAmount = blurAmount;
    }

    void Update()
    {
        if (m_duration > 0)
        {
            m_duration -= Time.deltaTime;
            if (m_duration <= 0)
            {
                StopEffect();
            }
        }
    }

    public static void StopEffect()
    {
        if (instance != null)
        {
            Destroy(instance);
            instance = null;
        }
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (m_material != null)
        {
            if (m_accumulationTexture == null || m_accumulationTexture.width != src.width || m_accumulationTexture.height != src.height)
            {
                ReleaseRenderTex();

                m_accumulationTexture = RenderTexture.GetTemporary(src.width, src.height, 0);
                Graphics.Blit(src, m_accumulationTexture);
            }

            m_accumulationTexture.MarkRestoreExpected();
            m_material.SetFloat("_BlurAmount", 1.0f - m_blurAmount);

            Graphics.Blit(src, m_accumulationTexture, m_material);
            Graphics.Blit(m_accumulationTexture, dest);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }

    void OnDestroy()
    {
        Debug.Log("MotionBlurEffect OnDestroy");
        DestroyMat();
        ReleaseRenderTex();
    }

    void DestroyMat()
    {
        if (m_material != null)
        {
            Destroy(m_material);
            m_material = null;
        }
    }

    void ReleaseRenderTex()
    {
        if (m_accumulationTexture != null)
        {
            RenderTexture.ReleaseTemporary(m_accumulationTexture);
            m_accumulationTexture = null;
        }
    }
}
