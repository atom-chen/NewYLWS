using UnityEngine;
using System.Collections;
using XLua;

[Hotfix]
[LuaCallCSharp]
public class BgBlurEffect : MonoBehaviour 
{
    private static BgBlurEffect s_instance = null;

    private Material m_material = null;
    private Camera m_mainCamera = null;
    [Range(0, 4)]
    public int iterations = 1;
    [Range(0.2f, 3.0f)]
    public float blurSpread = 3f;
    [Range(1, 8)]
    public int downSample = 2;

    public static void ApplyEffect(Material mat, Camera blurCamera)
    {
        if (mat == null)
        {
            return;
        }

        if (s_instance != null)
        {
            s_instance.Init(new Material(mat), blurCamera);
        }
        else
        {
            if (blurCamera == null)
            {
                return;
            }

            s_instance = blurCamera.gameObject.AddComponent<BgBlurEffect>();
            s_instance.Init(new Material(mat), blurCamera);
        }
    }

    public void Init(Material mat, Camera blurCamera)
    {
        m_material = mat;
        m_mainCamera = blurCamera;
    }

    public static void StopBgBlurEffect()
    {
        if (s_instance != null)
        {
            s_instance.StopEffect();
            Destroy(s_instance);
            s_instance = null;
        }
    }

    private void StopEffect()
    {
        m_mainCamera = null;

        if (m_material != null)
        {
            Destroy(m_material);
            m_material = null;
        }
    }

    void OnDestroy()
    {
        StopEffect();
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (m_material != null)
        {
            int rtW = src.width / downSample;
            int rtH = src.height / downSample;

            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            buffer0.filterMode = FilterMode.Bilinear;

            Graphics.Blit(src, buffer0);

            for (int i = 0; i < iterations; i++)
            {
                m_material.SetFloat("_BlurSize", 1.0f + i * blurSpread);

                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                // Render the vertical pass
                Graphics.Blit(buffer0, buffer1, m_material, 0);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                // Render the horizontal pass
                Graphics.Blit(buffer0, buffer1, m_material, 1);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }

            Graphics.Blit(buffer0, dest);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
