using UnityEngine;
using System.Collections;
using XLua;

[Hotfix]
[LuaCallCSharp]
public class RenderTextureMgr
{
    private RenderTexture screenBlurRT = null;          // 背景模糊
    private RenderTexture screenRT = null;              // 技能释放, 出场背景

    private static RenderTextureMgr m_instance;

    public static RenderTextureMgr GetInstance()
    {
        if (m_instance == null)
        {
            m_instance = new RenderTextureMgr();
        }
        return m_instance;
    }
    
    public void Clear()
    {
        DisposeScreenBlurRT();
        DisposeScreenRT();
    }

    public void CreateRT(ref RenderTexture rt, int width, int height, int depth)
    {
        if (rt != null)
        {
            GameObject.DestroyImmediate(rt);
            rt = null;
        }

        rt = new RenderTexture(width, height, depth, RenderTextureFormat.ARGB32);
        rt.wrapMode = TextureWrapMode.Clamp;
        rt.filterMode = FilterMode.Bilinear;
        rt.isPowerOfTwo = false;
        rt.hideFlags = HideFlags.HideAndDontSave;
        
        rt.Create();
    }

    public RenderTexture CreateScreenBlurRT()
    {
        if (screenBlurRT == null)
        {
            CreateRT(ref screenBlurRT, Screen.width / 2, Screen.height / 2, 24);
        }
        return screenBlurRT;
    }

    public RenderTexture CreateScreenRT()
    {
        if (screenRT == null)
        {
            CreateRT(ref screenRT, Screen.width * 2 / 3, Screen.height * 2 / 3, 24);
        }
        return screenRT;
    }

    public void DisposeScreenBlurRT()
    {
        if (screenBlurRT != null)
        {
            GameObject.DestroyImmediate(screenBlurRT);
            screenBlurRT = null;
        }
    }

    public void DisposeScreenRT()
    {
        if (screenRT != null)
        {
            GameObject.DestroyImmediate(screenRT);
            screenRT = null;
        }
    }
}
