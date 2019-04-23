using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class MatcapMaker : MonoBehaviour
{
    private Camera matcapCam;
    private Camera mainCam;
    //private Shader mCustomDepth;
    //public Material mMat;
    private RenderTexture matcapTexture;
    private Transform target;

    private GameObject matcapCamObj;
    private int cullingmask = 0;
    private float oSize = 0.36f;

    public void Prepare(string targetName, int cullingmask = 1<<8, float oSize=0.36f)
    {
        GameObject go = GameObject.FindGameObjectWithTag("Matcap");
        if (go == null)
        {
            go = GameObject.Find(targetName);
        }

        if (go == null)
        {
            Logger.LogError("No matcap target");
            return;
        }

        target = go.transform;
        this.cullingmask = cullingmask;
        this.oSize = oSize;
    }
    
    void Start()
    {
        mainCam = Camera.main;

        if (mainCam == null)
        {
            return;
        }
        
        matcapCam = gameObject.AddComponent<Camera>();
        //matcapCam.orthographic = true;
        //matcapCam.orthographicSize = 1;
        matcapCam.backgroundColor = Color.grey;
        matcapCam.clearFlags = CameraClearFlags.SolidColor;
        matcapCam.cullingMask = cullingmask;    // 1 << 8;
        matcapCam.depth = 1;

        if (SystemInfo.SupportsRenderTextureFormat(RenderTextureFormat.ARGBHalf))
        {
            matcapTexture = RenderTexture.GetTemporary(128, 128, 0, RenderTextureFormat.ARGBHalf);
        }
        else
        {
            matcapTexture = RenderTexture.GetTemporary(128, 128, 0, RenderTextureFormat.ARGB32);
        }
        matcapTexture.autoGenerateMips = false;
        //matcapTexture.antiAliasing = 2;

        matcapCam.targetTexture = matcapTexture;
        Shader.SetGlobalTexture("_SceneMatcap", matcapTexture);


        matcapCam.transform.position = mainCam.transform.position;
        matcapCam.transform.rotation = mainCam.transform.rotation;
        matcapCam.orthographic = true;
        matcapCam.orthographicSize = oSize;
    }

    private void LateUpdate()
    {
        if (mainCam == null || matcapCam == null || target == null)
        {
            return;
        }
        matcapCam.transform.rotation = mainCam.transform.rotation;
        matcapCam.transform.position = mainCam.transform.forward * -1 + target.position;

    }

    private void OnDestroy()
    {
        if (matcapTexture)
        {
            RenderTexture.ReleaseTemporary(matcapTexture);
            matcapTexture = null;
        }

        target = null;
        mainCam = null;
    }
}
