using UnityEngine;
using System.Collections;
using XLua;

[Hotfix]
[LuaCallCSharp]

public class EyeVisionEffect : MonoBehaviour 
{

    private Material m_mat = null;

    public float m_alpha = 0f;

    public Transform m_targetTransform = null;
    public Vector3 m_targetVector = Vector3.zero;

    public float m_startTime = 1f;
    public float m_endTime = 1f;
    public float m_changeTime = 1f;

    float m_leftStartTime = -1;
    float m_leftEndTime = -1;
    float m_leftChangeTime = -1;
    float m_startX;
    float m_startY;
    float m_targetX;
    float m_targetY;

    public float m_sizeX;
    public float m_sizeY;
    public float m_blur = 0;

    float m_changeBlurTime = -1f;
    float m_leftChangeBlurTime = -1f;
    float m_startBlur;
    float m_targetBlur;

    float m_resolutionScale;
    float m_viewPortExtendX;
    float m_viewPortExtendY;
    Vector2 m_pos = Vector2.zero;
    Vector2 m_topLeft = Vector2.zero;
    Vector2 m_bottomRight = Vector2.zero;

    public Camera m_camera;


    public static EyeVisionEffect instance = null;

    public float SizeX
    {
        get
        {
            return m_sizeX;
        }
        set
        {
            m_sizeX = value;
        }
    }
    public float SizeY
    {
        get
        {
            return m_sizeY;
        }
        set
        {
            m_sizeY = value;
        }
    }

    public Transform TargetTransform
    {
        get
        {
            return m_targetTransform;
        }
        set
        {
            m_targetTransform = value;
        }
    }

    public Vector3 TargetVector
    {
        get
        {
            return m_targetVector;
        }
        set
        {
            m_targetVector = value;
        }
    }


    public static void ApplyEyeVisionEffect(Material mat, float startTime)
    {
        if (mat == null)
        {
            return;
        }
        if (instance == null)
        {
            GameObject cameraGO = GameObject.Find("Main Camera");
            if (cameraGO == null)
            {
                return;
            }
            instance = cameraGO.AddComponent<EyeVisionEffect>();
        }
        instance.InitEffect(mat, startTime);
    }

    public static void StopEyeVisionEffect(float endTime)
    {
        if (instance != null)
        {
            instance.Recover(endTime);
        }
    }


    private void InitEffect(Material mat, float startTime)
    {
        this.m_mat = mat;
        this.m_startTime = startTime;
        this.m_camera = GetComponent<Camera>();

        m_leftStartTime = this.m_startTime;

        if (m_leftStartTime <= 0f)
        {
            m_leftStartTime = -1f;
            m_alpha = 1f;
        }
    }

    private void Recover(float endTime)
    {
        this.m_endTime = endTime;
        if (this.m_endTime <= 0f)
        {
            m_leftEndTime = -1f;
            m_alpha = 0f;
            m_mat = null;
            m_camera = null;
            GameObject.Destroy(EyeVisionEffect.instance);
            EyeVisionEffect.instance = null;
        }
        else
        {
            m_leftEndTime = this.m_endTime;
        }
    }

    public void Blink(float x, float y, float time)
    {
        m_changeTime = time;
        if (m_changeTime < 0f)
        {
            m_sizeX = x;
            m_sizeY = y;
        }
        else
        {
            m_leftChangeTime = m_changeTime;
            m_targetX = x;
            m_targetY = y;
            m_startX = m_sizeX;
            m_startY = m_sizeY;
        }
    }

    public void ChangeBlur(float toBLur, float time = -1f)
    {
        m_changeBlurTime = time;
        if (m_changeBlurTime < 0f)
        {
            m_blur = toBLur;
        }
        else
        {
            m_startBlur = m_blur;
            m_targetBlur = toBLur;
            m_leftChangeBlurTime = m_changeBlurTime;
        }
    }


    void Update()
    {
        if (m_leftChangeTime > 0)
        {
            m_leftChangeTime -= Time.deltaTime;
            if (m_leftChangeTime <= 0f)
            {
                m_leftChangeTime = -1f;
                m_sizeX = m_targetX;
                m_sizeY = m_targetY;
            }
            else
            {
                m_sizeX = m_startX + (m_targetX - m_startX) * (1f - m_leftChangeTime / m_changeTime);
                m_sizeY = m_startY + (m_targetY - m_startY) * (1f - m_leftChangeTime / m_changeTime);
            }
        }

        if (m_leftChangeBlurTime > 0)
        {
            m_leftChangeBlurTime -= Time.deltaTime;
            if (m_leftChangeBlurTime <= 0f)
            {
                m_leftChangeBlurTime = -1f;
                m_blur = m_targetBlur;
            }
            else
            {
                m_blur = m_startBlur + (m_targetBlur - m_startBlur) * (1f - m_leftChangeBlurTime / m_changeBlurTime);
            }
        }

        if (m_leftStartTime > 0)
        {
            m_leftStartTime -= Time.deltaTime;
            if (m_leftStartTime <= 0f)
            {
                m_leftStartTime = -1f;
                m_alpha = 1f;
            }
            else
            {
                m_alpha = 1f - m_leftStartTime / m_startTime;
            }
        }
        else if (m_leftEndTime > 0)
        {
            m_leftEndTime -= Time.deltaTime;
            if (m_leftEndTime <= 0f)
            {
                m_leftEndTime = -1f;

                m_alpha = 0f;
                m_mat = null;
                m_camera = null;
                GameObject.Destroy(EyeVisionEffect.instance);
                EyeVisionEffect.instance = null;
            }
            else
            {
                m_alpha = m_leftEndTime / m_endTime;
            }
        }
    }

    void DoPostRender()
    {
        if (m_alpha > 0.01f)
        {
            m_mat.SetFloat("_Alpha", m_alpha);

            m_resolutionScale = Screen.width / 1280f;

            m_viewPortExtendX = m_sizeX / Screen.width / 2f * m_resolutionScale;
            m_viewPortExtendY = m_sizeY / Screen.height / 2f * m_resolutionScale;

            if (m_camera)
            {
                if (m_targetTransform)
                {
                    m_pos = m_camera.WorldToViewportPoint(m_targetTransform.position);
                }
                else
                {
                    m_pos = m_camera.WorldToViewportPoint(m_targetVector);
                }
            }
            m_topLeft.x = m_pos.x - m_viewPortExtendX;
            m_topLeft.y = m_pos.y - m_viewPortExtendY;
            m_bottomRight.x = m_pos.x + m_viewPortExtendX;
            m_bottomRight.y = m_pos.y + m_viewPortExtendY;

            if (m_topLeft.x > 0f)
            {
                GL.PushMatrix();
                GL.LoadOrtho();
                m_mat.SetPass(1);
                GL.Begin(GL.QUADS);
                GL.Vertex3(0f, 0f, 0.1f);
                GL.Vertex3(m_topLeft.x, 0f, 0.1f);
                GL.Vertex3(m_topLeft.x, 1f, 0.1f);
                GL.Vertex3(0f, 1f, 0.1f);
                GL.End();
                GL.PopMatrix();
            }
            if (m_bottomRight.x < 1f)
            {
                GL.PushMatrix();
                GL.LoadOrtho();
                m_mat.SetPass(1);
                GL.Begin(GL.QUADS);
                GL.Vertex3(m_bottomRight.x, 0f, 0.1f);
                GL.Vertex3(1f, 0f, 0.1f);
                GL.Vertex3(1f, 1f, 0.1f);
                GL.Vertex3(m_bottomRight.x, 1f, 0.1f);
                GL.End();
                GL.PopMatrix();
            }
            if (m_topLeft.y > 0f)
            {
                GL.PushMatrix();
                GL.LoadOrtho();
                m_mat.SetPass(1);
                GL.Begin(GL.QUADS);
                GL.Vertex3(m_topLeft.x, 0f, 0.1f);
                GL.Vertex3(m_bottomRight.x, 0f, 0.1f);
                GL.Vertex3(m_bottomRight.x, m_topLeft.y, 0.1f);
                GL.Vertex3(m_topLeft.x, m_topLeft.y, 0.1f);
                GL.End();
                GL.PopMatrix();
            }
            if (m_bottomRight.y < 1f)
            {
                GL.PushMatrix();
                GL.LoadOrtho();
                m_mat.SetPass(1);
                GL.Begin(GL.QUADS);
                GL.Vertex3(m_topLeft.x, m_bottomRight.y, 0.1f);
                GL.Vertex3(m_bottomRight.x, m_bottomRight.y, 0.1f);
                GL.Vertex3(m_bottomRight.x, 1f, 0.1f);
                GL.Vertex3(m_topLeft.x, 1f, 0.1f);
                GL.End();
                GL.PopMatrix();
            }

            GL.PushMatrix();
            GL.LoadOrtho();
            m_mat.SetPass(0);
            GL.Begin(GL.QUADS);
            GL.TexCoord2(0f, 0f);
            GL.Vertex3(m_topLeft.x, m_topLeft.y, 0.1f);
            GL.TexCoord2(1f, 0f);
            GL.Vertex3(m_bottomRight.x, m_topLeft.y, 0.1f);
            GL.TexCoord2(1f, 1f);
            GL.Vertex3(m_bottomRight.x, m_bottomRight.y, 0.1f);
            GL.TexCoord2(0f, 1f);
            GL.Vertex3(m_topLeft.x, m_bottomRight.y, 0.1f);
            GL.End();
            GL.PopMatrix();
        }
    }

    void OnPostRender()
    {
        DoPostRender();
    }

    void DoRenderImage(RenderTexture source, RenderTexture destination)
    {
        RenderTexture rt = RenderTexture.GetTemporary(source.width / 4, source.height / 4, 0, source.format);
        rt.wrapMode = TextureWrapMode.Clamp;
        rt.filterMode = FilterMode.Bilinear;
        Graphics.Blit(source, rt, m_mat, 2);
        m_mat.SetTexture("_BlurTex", rt);
        m_mat.SetFloat("_Blur", m_blur);
        Graphics.Blit(source, destination, m_mat, 3);
        RenderTexture.ReleaseTemporary(rt);
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        DoRenderImage(source, destination);
    }
}
