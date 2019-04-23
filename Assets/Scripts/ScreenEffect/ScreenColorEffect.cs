using UnityEngine;
using System.Collections;
using XLua;

[Hotfix]
[LuaCallCSharp]

public class ScreenColorEffect : PostRenderEffectBase
{
    private Material whiteMat;

    public float alpha = 0f;
    public Color color = Color.white;

    public float startTime = 1f;
    public float endTime = 1f;
    public float alphaDuration = 1;

    float leftStartTime = -1;
    float leftEndTime = -1;
    float leftAlphaDuration = -1;
    float toAlpha = 1;
    float fromAlpha = 1;

    public int priority = 0;
    public bool coverUI = false;

    public static ScreenColorEffect[] instance = new ScreenColorEffect[4];

    public static void ApplyScreenColorEffect(Material mat, float startTime, Color color, bool coverUI = false, int priority = 0)
    {
        if (mat == null)
        {
            return;
        }
        
        if (instance[priority] != null)
        {
            Destroy(instance[priority]);
            instance[priority] = null;
        }
        if (coverUI)
        {
            GameObject cameraGO = GameObject.Find("UIRoot/UICamera");
            if (cameraGO == null)
            {
                return;
            }
            instance[priority] = cameraGO.AddComponent<ScreenColorEffect>();
            instance[priority].whiteMat = new Material(mat);
            instance[priority].coverUI = coverUI;
            instance[priority].color = color;
            instance[priority].priority = priority;
            instance[priority].InitEffect(cameraGO.GetComponent<Camera>(), startTime);
        }
        else
        {
            GameObject cameraGO = GameObject.Find("Main Camera");
            if (cameraGO == null)
            {
                return;
            }
            instance[priority] = cameraGO.AddComponent<ScreenColorEffect>();
            instance[priority].whiteMat = new Material(mat);
            instance[priority].coverUI = coverUI;
            instance[priority].color = color;
            instance[priority].priority = priority;
            instance[priority].InitEffect(cameraGO.GetComponent<Camera>(), startTime);
        }
    }

    public static void StopScreenColorEffect(float endTime, int priority = 0)
    {
        if (instance[priority] != null)
        {
            instance[priority].Recover(endTime);
        }
    }

    public static void TweenScreenColorAlpha(float duration, float fromAlpha, float toAlpha, int priority = 0)
    {
        if (instance[priority] != null)
        {
            instance[priority].TweenColorAlpha(duration, fromAlpha, toAlpha);
        }
    }

    private void InitEffect(Camera cam, float startTime)
    {
        this.startTime = startTime;
        if (this.startTime < 0f)
        {
            alpha = 1f;
        }
        else
        {
            leftStartTime = this.startTime;
        }

        if (coverUI)
        {
            AddPostRenderEffect(cam, (CameraPostRender.PostRenderPriority.ScreenColorEffect0 + priority));
        }
        else
        {
            AddPostRenderEffect(cam, (CameraPostRender.PostRenderPriority.ScreenColorEffect0 + priority));
        }
    }

    private void Recover(float endTime)
    {
        this.endTime = endTime;
        leftEndTime = this.endTime;
        if (leftEndTime < 0f)
        {
            alpha = 0f;
            GameObject.Destroy(ScreenColorEffect.instance[priority]);
            ScreenColorEffect.instance[priority] = null;
        }
        else
        {
            alpha = leftEndTime / endTime;
            DoPostRender();
        }
    }

    private void TweenColorAlpha(float duration, float fromAlpha, float toAlpha)
    {
        leftStartTime = 0;
        leftEndTime = 0;
        alpha = fromAlpha;
        leftAlphaDuration = duration;
        alphaDuration = duration;
        this.toAlpha = toAlpha;
        this.fromAlpha = fromAlpha;
        if (leftAlphaDuration < 0f)
        {
            alpha = toAlpha;
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
                alpha = 1f;
            }
            else
            {
                alpha = 1f - leftStartTime / startTime;
            }
        }
        else if (leftEndTime > 0)
        {
            leftEndTime -= Time.deltaTime;
            if (leftEndTime <= 0f)
            {
                leftEndTime = -1f;

                alpha = 0f;
                GameObject.Destroy(ScreenColorEffect.instance[priority]);
                ScreenColorEffect.instance[priority] = null;
            }
            else
            {
                alpha = leftEndTime / endTime;
            }
        }
        else if (leftAlphaDuration > 0)
        {
            leftAlphaDuration -= Time.deltaTime;
            if (leftAlphaDuration <= 0)
            {
                alpha = toAlpha;
            }
            else
            {
                alpha = (fromAlpha - toAlpha) * (leftAlphaDuration / alphaDuration) + toAlpha;
            }
        }
    }

    protected override void DoPostRender()
    {
        if (alpha > 0.01f)
        {
            GL.PushMatrix();
            GL.LoadOrtho();
            whiteMat.SetPass(0);
            whiteMat.SetFloat("_R", color.r);
            whiteMat.SetFloat("_G", color.g);
            whiteMat.SetFloat("_B", color.b);
            whiteMat.SetFloat("_Alpha", color.a * alpha);
            GL.Begin(GL.QUADS);
            GL.Vertex3(0f, 0f, 0.1f);
            GL.Vertex3(1f, 0f, 0.1f);
            GL.Vertex3(1f, 1f, 0.1f);
            GL.Vertex3(0f, 1f, 0.1f);
            GL.End();
            GL.PopMatrix();
        }
    }

    void OnDestroy()
    {
        whiteMat = null;
        if (whiteMat != null)
        {
            Destroy(whiteMat);
            whiteMat = null;
        }
        DelPostRenderEffect();
    }
}
