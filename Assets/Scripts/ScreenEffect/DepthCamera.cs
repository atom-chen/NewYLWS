using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class DepthCamera : MonoBehaviour 
{
    [Tooltip("When enabled, cam.depthTextureMode = DepthTextureMode.Depth;")]
    public bool m_OpenDepthTexture = true;
    public Renderer m_waterRender = null;

    private GameObject depthCamObj;
    private Camera mCam;
    private RenderTexture depthTexture;
    private Shader m_depthShader;
    
	void Start () 
    {
        if (m_OpenDepthTexture)
        {
            GetComponent<Camera>().depthTextureMode = DepthTextureMode.Depth;
        }
	}

    void Awake()
    {
        mCam = GetComponent<Camera>();

        m_depthShader = Shader.Find("Custom/GenerateDepthTex");
        //mCam.SetReplacementShader(m_depthShader, "RenderType");
    }

    private void OnPreRender()
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
        }
        else
        {
            depthCam = depthCamObj.GetComponent<Camera>();
        }

        depthCam.CopyFrom(mCam);
        depthTexture = RenderTexture.GetTemporary(mCam.pixelWidth, mCam.pixelHeight, 16, RenderTextureFormat.ARGB32);
        depthCam.backgroundColor = new Color(1, 1, 1, 1);
        depthCam.clearFlags = CameraClearFlags.SolidColor;
        depthCam.targetTexture = depthTexture;
        depthCam.RenderWithShader(m_depthShader, "RenderType");
        m_waterRender.material.SetTexture("_DepthTexture", depthTexture);
    }
}
