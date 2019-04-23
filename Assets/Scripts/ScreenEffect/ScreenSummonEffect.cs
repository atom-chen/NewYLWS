using UnityEngine;
using System.Collections;
using XLua;

[Hotfix]
[LuaCallCSharp]

public class ScreenSummonEffect : PostRenderEffectBase
{
    public Color color = Color.white;

    public float startTime = 1f;
    public float endTime = 1f;

    float leftStartTime = -1;
    float leftEndTime = -1;

    float texValue = 0f;

    Material texMat = null;
    Texture image;

    float borderH = 1f;// 0.5f;
    float centerH = 1f;

    float top;
    float texTop;
    float bottom;
    float texBottom;

    public static ScreenSummonEffect instance = null;

    public static void ApplyScreenColorEffect(Material matAsset, float startTime, Color color)
    {
        if (instance != null)
        {
            Destroy(instance);
            instance = null;
        }
        if (matAsset == null)
        {
            return;
        }

        GameObject cameraGO = GameObject.Find("UIRoot/UICamera");
        if (cameraGO == null)
        {
            return;
        }

        Material mat = new Material(matAsset);
        instance = cameraGO.AddComponent<ScreenSummonEffect>();

        instance.color = color;
        instance.InitEffect(mat, cameraGO.GetComponent<Camera>(), startTime);
    }

    public static void StopScreenColorEffect(float endTime)
    {
        if (instance != null)
        {
            instance.Recover(endTime);
        }
    }

    private void InitEffect(Material mat, Camera cam, float startTime)
    {
        this.startTime = startTime;
        if (this.startTime < 0f)
        {
            texValue = (1f + centerH + borderH + borderH) / 2f;
        }
        else
        {
            leftStartTime = this.startTime;
        }

        texMat = mat;
        image = mat.GetTexture("_AlphaTex");

        if (image == null)
        {
            UnityEngine.Debug.LogError("ScreenSummonEffect no _AlphaTex");
            return;
        }

        AddPostRenderEffect(cam, (CameraPostRender.PostRenderPriority.ScreenSummonEffect));
    }

    private void Recover(float endTime)
    {
        this.endTime = endTime;
        leftEndTime = this.endTime;
        if (leftEndTime < 0f)
        {
            texValue = (1f + centerH + borderH + borderH);

            GameObject.Destroy(ScreenSummonEffect.instance);
            ScreenSummonEffect.instance = null;
        }
    }
    
    void Update()
    {
        if (leftStartTime > 0)
        {
            leftStartTime -= Time.deltaTime;
            if (leftStartTime <= 0f)
            {
                leftStartTime = -1f;
                texValue = (1f + centerH + borderH + borderH) / 2f;
            }
            else
            {
                texValue = (1f + centerH + borderH + borderH) / 2f * (1f - leftStartTime / startTime);
            }
        }
        else if (leftEndTime > 0)
        {
            leftEndTime -= Time.deltaTime;
            if (leftEndTime <= 0f)
            {
                leftEndTime = -1f;

                texValue = (1f + centerH + borderH + borderH);

                GameObject.Destroy(ScreenSummonEffect.instance);
                ScreenSummonEffect.instance = null;
            }
            else
            {
                texValue = (1f + centerH + borderH + borderH) / 2f + (1f + centerH + borderH + borderH) / 2f * (1f - leftEndTime / endTime);
            }
        }
    }

    protected override void DoPostRender()
    {
        top = -texValue + 1f + centerH + borderH + borderH;
        bottom = -texValue + 1f + centerH + borderH;
        if (bottom < 1f && top > 0f)
        {
            if (top > 1f)
            {
                texTop = (borderH - (top - 1f)) / borderH;
                texTop = 1 - texTop;
                top = 1f;
            }
            else
            {
                texTop = 1f;
                texTop = 1 - texTop;
            }

            if (bottom < 0f)
            {
                texBottom = (-bottom) / borderH;
                texBottom = 1 - texBottom;
                bottom = 0f;
            }
            else
            {
                texBottom = 0f;
                texBottom = 1 - texBottom;
            }

            texMat.SetColor("_Color", color);
            texMat.SetTexture("_AlphaTex", image);

            GL.PushMatrix();
            GL.LoadOrtho();
            texMat.SetPass(0);
            GL.Begin(GL.QUADS);
            GL.TexCoord2(0f, texBottom);
            GL.Vertex3(0, bottom, 0.1f);
            GL.TexCoord2(1f, texBottom);
            GL.Vertex3(1, bottom, 0.1f);
            GL.TexCoord2(1f, texTop);
            GL.Vertex3(1, top, 0.1f);
            GL.TexCoord2(0f, texTop);
            GL.Vertex3(0, top, 0.1f);
            GL.End();
            GL.PopMatrix();
        }

        top = -texValue + 1f + centerH + borderH;
        bottom = -texValue + 1f + borderH;
        texTop = 1f;
        texBottom = 0f;
        if (bottom < 1f && top > 0f)
        {
            if (top > 1f)
            {
                top = 1f;
            }

            if (bottom < 0f)
            {
                bottom = 0f;
            }

            texMat.SetColor("_Color", color);
            texMat.SetTexture("_AlphaTex", null);

            GL.PushMatrix();
            GL.LoadOrtho();
            texMat.SetPass(0);
            GL.Begin(GL.QUADS);
            GL.TexCoord2(0f, texBottom);
            GL.Vertex3(0, bottom, 0.1f);
            GL.TexCoord2(1f, texBottom);
            GL.Vertex3(1, bottom, 0.1f);
            GL.TexCoord2(1f, texTop);
            GL.Vertex3(1, top, 0.1f);
            GL.TexCoord2(0f, texTop);
            GL.Vertex3(0, top, 0.1f);
            GL.End();
            GL.PopMatrix();
        }

        top = -texValue + 1f + borderH;
        bottom = -texValue + 1f;
        if (bottom < 1f && top > 0f)
        {
            if (top > 1f)
            {
                texTop = (borderH - (top - 1f)) / borderH;
                top = 1f;
            }
            else
            {
                texTop = 1f;
            }

            if (bottom < 0f)
            {
                texBottom = (-bottom) / borderH;
                bottom = 0f;
            }
            else
            {
                texBottom = 0f;
            }

            texMat.SetColor("_Color", color);

            GL.PushMatrix();
            GL.LoadOrtho();
            texMat.SetPass(0);
            GL.Begin(GL.QUADS);
            GL.TexCoord2(0f, texBottom);
            GL.Vertex3(0, bottom, 0.1f);
            GL.TexCoord2(1f, texBottom);
            GL.Vertex3(1, bottom, 0.1f);
            GL.TexCoord2(1f, texTop);
            GL.Vertex3(1, top, 0.1f);
            GL.TexCoord2(0f, texTop);
            GL.Vertex3(0, top, 0.1f);
            GL.End();
            GL.PopMatrix();
        }
    }

    void OnDestroy()
    {
        if (texMat != null)
        {
            Destroy(texMat);
            texMat = null;
        }
        image = null;
        DelPostRenderEffect();
    }
}
