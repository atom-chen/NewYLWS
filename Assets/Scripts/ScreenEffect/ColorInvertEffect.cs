using UnityEngine;
using System.Collections;
using XLua;

[Hotfix]
[LuaCallCSharp]
public class ColorInvertEffect : MonoBehaviour 
{
    private const float TOTAL_INVERT_TIME = 1f;
    private static ColorInvertEffect s_colorInvertEffect = null;

    private Material m_material = null;
    private float m_duration = 0;
    private Transform m_helperCameraTrans = null;
    private Camera m_helperCamera = null;
    private Camera m_mainCamera = null;
    [Range(0.0f, 0.9f)]
    public float m_blurAmount = 0.8f;
    private RenderTexture m_accumulationTexture;
    private float m_invertAmount = 1f;
    private float m_invertTime = 0f;

    public static void ApplyEffect(Material mat, float duration, int excludeLayer)
    {
        if (mat == null)
        {
            return;
        }

        GameObject cameraGO = GameObject.Find("Main Camera");
        if (cameraGO == null)
        {
            return;
        }

        if (s_colorInvertEffect != null)
        {
            Destroy(s_colorInvertEffect);
            s_colorInvertEffect = null;
        }

        s_colorInvertEffect = cameraGO.AddComponent<ColorInvertEffect>();
        s_colorInvertEffect.Init(new Material(mat), duration, excludeLayer);
    }

    public void Init(Material mat, float duration, int excludeLayer)
    {
        m_material = mat;
        m_duration = duration;
        m_invertAmount = 1;
        m_invertTime = TOTAL_INVERT_TIME;

        GameObject helperCam = new GameObject("ColorInvertCamera");
        m_helperCameraTrans = helperCam.transform;
        m_helperCameraTrans.localPosition = transform.localPosition;
        m_helperCameraTrans.localRotation = transform.localRotation;
        m_helperCameraTrans.localScale = transform.localScale;
        m_helperCamera = helperCam.AddComponent<Camera>();
        m_mainCamera = GetComponent<Camera>();
        m_helperCamera.clearFlags = CameraClearFlags.Depth;
        m_helperCamera.fieldOfView = m_mainCamera.fieldOfView;
        m_helperCamera.cullingMask = 1 << excludeLayer; 
    }

    private void Update()
    {
        if (m_invertTime > 0)
        {
            m_helperCameraTrans.localPosition = transform.localPosition;
            m_helperCameraTrans.localRotation = transform.localRotation;
            m_helperCameraTrans.localScale = transform.localScale;
            m_helperCamera.fieldOfView = m_mainCamera.fieldOfView;

            if (m_duration > 0)
            {
                m_duration -= Time.deltaTime;
            }
            else
            {
                m_invertTime -= Time.deltaTime;
                m_invertAmount = m_invertTime / TOTAL_INVERT_TIME;
                m_invertAmount = m_invertAmount < 0 ? 0 : m_invertAmount;

                if (m_invertTime <= 0)
                {
                    StopEffect();
                }
            }
        }
    }

    private void StopEffect()
    {
        if (s_colorInvertEffect != null)
        {
            Destroy(s_colorInvertEffect);
            s_colorInvertEffect = null;
            m_mainCamera = null;
        }

        if (m_material != null)
        {
            Destroy(m_material);
            m_material = null;
        }

        if (m_helperCameraTrans != null)
        {
            Destroy(m_helperCameraTrans.gameObject);
            m_helperCameraTrans = null;
            m_helperCamera = null;
        }
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (m_material != null)
        {
            if (m_accumulationTexture == null || m_accumulationTexture.width != src.width || m_accumulationTexture.height != src.height)
            {
                if (m_accumulationTexture != null)
                {
                    RenderTexture.ReleaseTemporary(m_accumulationTexture);
                }
                m_accumulationTexture = RenderTexture.GetTemporary(src.width, src.height, 0);
                Graphics.Blit(src, m_accumulationTexture);
            }

            m_accumulationTexture.MarkRestoreExpected();

            m_material.SetFloat("_BlurAmount", 1.0f - m_blurAmount);
            m_material.SetFloat("_InvertAmount", m_invertAmount);

            Graphics.Blit(src, m_accumulationTexture, m_material);
            Graphics.Blit(m_accumulationTexture, dest);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }

    void OnDisable()
    {
        if (m_accumulationTexture != null)
        {
            RenderTexture.ReleaseTemporary(m_accumulationTexture);
            m_accumulationTexture = null;
        }
    }
}
