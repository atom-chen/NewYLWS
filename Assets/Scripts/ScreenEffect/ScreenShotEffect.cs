using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using XLua;

[Hotfix]
[LuaCallCSharp]

public class ScreenShotEffect : MonoBehaviour
{
    private float m_startTime = 1f;
    private float m_leftStartTime = -1;
    private float m_alpha = 0f;

    private Material m_mat = null;

    private static ScreenShotEffect instance = null;

    public static void ApplyScreenShotEffect(Material matAsset, float startTime)
    {
        GameObject cameraGO = GameObject.Find("Main Camera");
        if (cameraGO == null)
        {
            return;
        }

        if (matAsset == null)
        {
            return;
        }

        if (instance == null)
        {
            instance = cameraGO.GetComponent<ScreenShotEffect>();
            if (instance == null)
            {
                instance = cameraGO.AddComponent<ScreenShotEffect>();
            }
        }
        instance.InitEffect(new Material(matAsset), startTime);
    }

    public static void StopScreenShotEffect()
    {
        if (instance != null)
        {
            instance.Finished();
        }
    }

    private void Finished()
    {
        m_alpha = 0f;
        if (ScreenShotEffect.instance != null)
        {
            GameObject.DestroyImmediate(ScreenShotEffect.instance);
            ScreenShotEffect.instance = null;
        }
        
        if (m_mat != null)
        {
            Destroy(m_mat);
            m_mat = null;
        }
    }

    private void InitEffect(Material mat, float startTime)
    {
        this.m_mat = mat;
        this.m_startTime = startTime;
        m_alpha = 0;

        if (this.m_startTime <= 0f)
        {
            Finished();
        }
        else
        {
            CaptureScreensShotTex();
            m_leftStartTime = this.m_startTime;
        }
    }
    
    void Update()
    {
        if (m_leftStartTime > 0)
        {
            m_leftStartTime -= Time.deltaTime;
            if (m_leftStartTime <= 0f)
            {
                m_leftStartTime = -1f;
                Finished();
            }
            else
            {
                m_alpha = m_leftStartTime / m_startTime;
            }
        }
    }

    void OnPostRender()
    {
        if (m_alpha > 0.01f)
        {
            m_mat.SetFloat("_Alpha", m_alpha * 0.6f);
            m_mat.SetTexture("_ScreenShotTex", RenderTextureMgr.GetInstance().CreateScreenRT());

            GL.PushMatrix();
            GL.LoadOrtho();
            m_mat.SetPass(0);
            GL.Begin(GL.QUADS);
            GL.TexCoord2(0f, 0f);
            GL.Vertex3(0, 0, 0.1f);
            GL.TexCoord2(1f, 0f);
            GL.Vertex3(1, 0, 0.1f);
            GL.TexCoord2(1f, 1f);
            GL.Vertex3(1, 1, 0.1f);
            GL.TexCoord2(0f, 1f);
            GL.Vertex3(0, 1, 0.1f);
            GL.End();
            GL.PopMatrix();
        }
    }

    public RenderTexture CaptureScreensShotTex()
    {
        Camera[] cameras = GameObject.FindObjectsOfType<Camera>();
        List<Camera> list = new List<Camera>(cameras);
        list.Sort((Camera a, Camera b) => { return (int)a.depth - (int)b.depth; });
        RenderTexture accumTexture = RenderTextureMgr.GetInstance().CreateScreenRT();
        foreach (var e in list)
        {
            if (e.enabled && e.gameObject.activeInHierarchy && !e.orthographic)
            {
                RenderTexture old = e.targetTexture;
                e.targetTexture = accumTexture;
                e.Render();
                e.targetTexture = old;
            }
        }

        return accumTexture;
    }

    void OnDestroy()
    {
        if (m_mat != null)
        {
            Destroy(m_mat);
            m_mat = null;
        }
    }
}
