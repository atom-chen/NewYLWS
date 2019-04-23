using UnityEngine;
using System.Collections;
using XLua;

[Hotfix]
[LuaCallCSharp]


public class PostRenderEffectBase : MonoBehaviour
{
    public void PostRender()
    {
        if (enabled == true)
        {
            DoPostRender();
        }
    }

    protected virtual void DoPostRender()
    {
    }

    public void AddPostRenderEffect(Camera camera, CameraPostRender.PostRenderPriority postRenderPriority)
    {
        CameraPostRender.AddHandler(camera, this, postRenderPriority);
    }

    public void DelPostRenderEffect()
    {
        CameraPostRender.DelHandler(this);
    }
}
