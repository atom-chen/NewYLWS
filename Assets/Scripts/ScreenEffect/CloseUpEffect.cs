using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using XLua;

[Hotfix]
[LuaCallCSharp]
[RequireComponent(typeof(Camera))]
public class CloseUpEffect : PostRenderEffectBase 
{
    public static Color MaskBGColor = new Color(0f, 0f, 0f, 0.5f);
    public static Color MaskFGColor = new Color(0f, 0f, 0f, 0.25f);

    public Color maskBGColor = new Color(0f, 0f, 0f,0.5f);
    public Color maskFGColor = new Color(0f, 0f, 0f, 0.25f);

    private Camera mCacheCamera;                                    // 主摄像机
    private Material maskMat;

    private Camera mCameraObj;

    //public Color color = Color.white;

    private float chgShaderLeftS = 0;

    private static CloseUpEffect instance = null;

    public static void ApplyCloseUpEffect(Material mat)
    {
        if (mat == null)
        {
            return;
        }

        if (instance != null)
        {
            //Destroy(instance);
            //instance = null;
        }
        else
        {
            GameObject cameraGO = GameObject.Find("Main Camera");
            if (cameraGO == null)
            {
                return;
            }

            instance = cameraGO.AddComponent<CloseUpEffect>();
            instance.RealEffect(mat);
        }

        SetCloseUpEffectColor(MaskBGColor);
    }

    public static void StopCloseUpEffect()
    {
        if (instance != null)
        {
            instance.Recover();
            Destroy(instance);
            instance = null;
        }
    }

    void Awake()
    {
        mCacheCamera = GetComponent<Camera>();
        mCameraObj = new GameObject("ScreenColorEffectObjCamera").AddComponent<Camera>();
        mCameraObj.enabled = false;
        mCameraObj.transform.parent = mCacheCamera.transform;
        mCameraObj.transform.localPosition = Vector3.zero;
        mCameraObj.transform.localRotation = Quaternion.identity;
    }

    public void RealEffect(Material mat)
    {
        maskMat = mat;

        GameObject cameraGO = GameObject.Find("Main Camera");
        if (cameraGO)
        {
            AddPostRenderEffect(cameraGO.GetComponent<Camera>(), (CameraPostRender.PostRenderPriority.CloseUpEffect));
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (chgShaderLeftS > 0)
        {
            chgShaderLeftS -= Time.deltaTime;

            if (chgShaderLeftS <= 0)
            {
                chgShaderLeftS = 0;
                AdjustBGColorComplete();
            }
        }
        //UpdateLayer();
    }

    void OnDestroy()
    {
        maskMat = null;
        if (mCameraObj)
        {
            Destroy(mCameraObj.gameObject);
            mCameraObj = null;
        }
        DelPostRenderEffect();
    }

    public static void AdjustBGColor(Camera camera, Color color, float time = 0.1f)
    {
        SetCloseUpEffectColor(color);
        if(instance != null)
        {
            instance.chgShaderLeftS = time;
        }
    }

    public static void AdjustBGColorComplete()
    {
        SetCloseUpEffectColor(MaskBGColor);
    }
    
    protected override void DoPostRender()
    {
        if (maskBGColor.a > 0.01f)
        {
            GL.PushMatrix();
            GL.LoadOrtho();
            maskMat.SetPass(0);
            maskMat.SetFloat("_R", maskBGColor.r);
            maskMat.SetFloat("_G", maskBGColor.g);
            maskMat.SetFloat("_B", maskBGColor.b);
            maskMat.SetFloat("_Alpha", maskBGColor.a);
            GL.Begin(GL.QUADS);
            GL.Vertex3(0f, 0f, 0.1f);
            GL.Vertex3(1f, 0f, 0.1f);
            GL.Vertex3(1f, 1f, 0.1f);
            GL.Vertex3(0f, 1f, 0.1f);
            GL.End();
            GL.PopMatrix();
        }
        mCameraObj.CopyFrom(mCacheCamera);
        mCameraObj.clearFlags = CameraClearFlags.Depth;//.Nothing;
        mCameraObj.depthTextureMode = DepthTextureMode.None;
        Culling1();
        mCameraObj.Render();
        if (maskFGColor.a > 0.01f)
        {
            GL.PushMatrix();
            GL.LoadOrtho();
            maskMat.SetPass(0);
            maskMat.SetFloat("_R", maskFGColor.r);
            maskMat.SetFloat("_G", maskFGColor.g);
            maskMat.SetFloat("_B", maskFGColor.b);
            maskMat.SetFloat("_Alpha", maskFGColor.a);
            GL.Begin(GL.QUADS);
            GL.Vertex3(0f, 0f, 0.1f);
            GL.Vertex3(1f, 0f, 0.1f);
            GL.Vertex3(1f, 1f, 0.1f);
            GL.Vertex3(0f, 1f, 0.1f);
            GL.End();
            GL.PopMatrix();
        }
        mCameraObj.CopyFrom(mCacheCamera);
        mCameraObj.depthTextureMode = DepthTextureMode.None;
        mCameraObj.clearFlags = CameraClearFlags.Nothing;
        Culling2();
        mCameraObj.Render();
    }

    private void Culling1()
    {
        mCameraObj.cullingMask = 1 << 20;
    }

    private void Culling2()
    {
        mCameraObj.cullingMask = 1 << 21;
    }


    void Recover()
    {
        //LayerChanger.RevertAllLayer(LayerChanger.CHANGE_REASONS.CLOSE_UP_EFFECT);
        //this.fgObjDic.Clear();
        //this.focusObjDic.Clear();
        //this.hideObjDic.Clear();

        //mCacheCamera.cullingMask = cacheLayerMask;
        //mCacheCamera.cullingMask = cacheLayerMask & ~(1 << Config.CLOSEUPEFFECT_FOCUS_LAYER)
        //                                          & ~(1 << Config.CLOSEUPEFFECT_SHALLOW_LAYER)
        //                                          & ~(1 << Config.CLOSEUPEFFECT_HIDE_LAYER);
    }

    
    public static void SetCloseUpEffectColor(Color color)
    {
        if(instance)
        {
            instance.maskBGColor = color;
            instance.maskFGColor = color * 0.5f;
        }
    }
}
