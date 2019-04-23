using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[RequireComponent(typeof(Camera))]
public class TestDepth : MonoBehaviour {

    public GameObject depthCamObj;

    private Camera mCam;
    public Shader mCustomDepth;
    //public Material mMat;
    private RenderTexture depthTexture;

    //public Shader getDepthShader;

    void Awake()
    {
        mCam = GetComponent<Camera>();

        mCustomDepth = Shader.Find("Custom/CopyDepth");
        //getDepthShader = Shader.Find("Custom/CopyDepth");
        //mMat = new Material(mCustomDepth);


        // mCam.SetReplacementShader(Shader.Find("Custom/CopyDepth"), "RenderType");
    }

    //可优化
    internal void OnPreRender()
    {
        if (depthTexture)
        {
            RenderTexture.ReleaseTemporary(depthTexture);
            depthTexture = null;
        }
        Camera depthCam;
        if (depthCamObj == null)
        {
            depthCamObj = new GameObject("DepthCamera");
            depthCamObj.AddComponent<Camera>();
            depthCam = depthCamObj.GetComponent<Camera>();
            depthCam.enabled = false;
            // depthCamObj.hideFlags = HideFlags.HideAndDontSave;
        }
        else
        {
            depthCam = depthCamObj.GetComponent<Camera>();
        }

        depthCam.CopyFrom(mCam);
        depthTexture = RenderTexture.GetTemporary(mCam.pixelWidth, mCam.pixelHeight, 0, RenderTextureFormat.ARGB32);
        depthCam.backgroundColor = new Color(0, 0, 0, 0);
        depthCam.clearFlags = CameraClearFlags.SolidColor; ;
        depthCam.targetTexture = depthTexture;
        depthCam.RenderWithShader(mCustomDepth, "RenderType");
        //mMat.SetTexture();
        Shader.SetGlobalTexture("_DepthTexture", depthTexture);
    }

    //void OnRenderImage(RenderTexture source, RenderTexture destination)
    //{
    //    if (null != mMat)
    //    {
    //        Graphics.Blit(source, destination, mMat);
    //    }
    //    else
    //    {
    //        Graphics.Blit(source, destination);
    //    }
    //}
}
