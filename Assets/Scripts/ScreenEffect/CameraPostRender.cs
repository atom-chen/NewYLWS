using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using XLua;

[Hotfix]
[LuaCallCSharp]
public class CameraPostRender : MonoBehaviour 
{
    public enum PostRenderPriority
    {
        GrabPass,
        ScreenFlip,

        GuideBuildingMaskEffect,
        GuideMaskEffect,

        ScreenColorEffectWithObj,

        ScreenColorEffect0,
        ScreenColorEffect1,
        ScreenColorEffect2,
        ScreenColorEffect3,

        ScreenSummonEffect,

        CloseUpEffect,
        EyeBlinkEffect,
    }

    private class PostRenderHandler
    {
        public Camera postRenderCamera;
        public PostRenderPriority postRenderPriority;
        public PostRenderEffectBase postRenderEffect;
    }

    private static List<PostRenderHandler> handlers = new List<PostRenderHandler>();
    private static int instanceCount = 0;

    private Camera cachePostRenderCamera;

    void Awake()
    {
        cachePostRenderCamera = GetComponent<Camera>();
        ++instanceCount;
    }

    void OnDestroy()
    {
        --instanceCount;
        if(instanceCount <= 0)
        {
            handlers.Clear();
        }
    }

    void OnPostRender()
    {
        HandlePostRender(cachePostRenderCamera);
    }

    static void HandlePostRender(Camera handelCamera)
    {
        for (int i = handlers.Count - 1; i >= 0; --i)
        {
            if (handlers[i].postRenderCamera != null && handlers[i].postRenderEffect != null)
            {
                if (handlers[i].postRenderCamera == handelCamera)
                {
                    handlers[i].postRenderEffect.PostRender();
                }
            }
            else
            {
                handlers.RemoveAt(i);
            }
        }
    }


    static public CameraPostRender Get(GameObject go)
    {
        CameraPostRender cameraPostRender = go.GetComponent<CameraPostRender>();
        if (cameraPostRender == null) cameraPostRender = go.AddComponent<CameraPostRender>();
        return cameraPostRender;
    }

    static public void AddHandler(Camera camera, PostRenderEffectBase postRenderEffect, CameraPostRender.PostRenderPriority postRenderPriority)
    {
        CameraPostRender cameraPostRender = camera.gameObject.GetComponent<CameraPostRender>();
        if (cameraPostRender == null)
        {
            cameraPostRender = camera.gameObject.AddComponent<CameraPostRender>();
        }
        PostRenderHandler prh = new PostRenderHandler();
        prh.postRenderCamera = camera;
        prh.postRenderEffect = postRenderEffect;
        prh.postRenderPriority = postRenderPriority;
        int i = handlers.Count - 1;
        for (; i >= 0; --i)
        {
            if (handlers[i].postRenderCamera != null && handlers[i].postRenderEffect != null)
            {
                if (handlers[i].postRenderPriority > prh.postRenderPriority)
                {
                    break;
                }
            }
            else
            {
                handlers.RemoveAt(i);
            }
        }
        handlers.Insert(i + 1, prh);
    }

    static public void DelHandler(PostRenderEffectBase postRenderEffect)
    {
        int i = handlers.Count - 1;
        for (; i >= 0; --i)
        {
            if (handlers[i].postRenderCamera != null && handlers[i].postRenderEffect != null)
            {
                if (handlers[i].postRenderEffect == postRenderEffect)
                {
                    handlers.RemoveAt(i);
                    break;
                }
            }
            else
            {
                handlers.RemoveAt(i);
            }
        }
    }
}

