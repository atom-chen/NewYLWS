using UnityEngine;
using UnityEngine.Rendering;
using System.Collections;
using System;
using System.Collections.Generic;


public class Mirror : MonoBehaviour
{

    public string ReflectionSample = "_ReflectionTex";
    public static bool s_InsideRendering = false;
    private int uniqueTextureID = -1;
    
   
    [HideInInspector]
    public int m_TextureSize = 512;
    [HideInInspector]
    public float m_ClipPlaneOffset = 0.01f;
   
    [Tooltip("The normal transform(transform.up as normal)")]
    public Transform normalTrans;
    

    private RenderTexture m_ReflectionTexture = null;


    [HideInInspector]
    public float[] layerCullingDistances = new float[32];
    [HideInInspector]
    public Renderer render;
    public Camera cam;
    private Camera reflectionCamera;
    private Transform refT;
    private Transform camT;
    private List<Material> allMats = new List<Material>();

    private float widthHeightRate;
    
    [Tooltip("Mirror mask")]
    public LayerMask m_ReflectLayers = -1;


    void Awake()
    {
        if (!cam)
        {
            Destroy(this);
            return;
        }

        uniqueTextureID = Shader.PropertyToID(ReflectionSample);
        if (!normalTrans)
        {
            normalTrans = new GameObject("Normal Trans").transform;
            normalTrans.position = transform.position;
            normalTrans.rotation = Quaternion.identity;
            normalTrans.SetParent(transform);
        }
        render = GetComponent<Renderer>();
        if (!render || !render.sharedMaterial)
        {
            Destroy(this);
            return;
        }

        for (int i = 0, length = render.sharedMaterials.Length; i < length; ++i)
        {
            Material m = render.sharedMaterials[i];
            if (!allMats.Contains(m))
                allMats.Add(m);
        }

        widthHeightRate = (float)Screen.height / (float)Screen.width;
        m_ReflectionTexture = new RenderTexture(m_TextureSize, (int)(m_TextureSize * widthHeightRate), 24, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Default);
        m_ReflectionTexture.name = "ReflectionTex " + GetInstanceID();
        m_ReflectionTexture.isPowerOfTwo = true;
        m_ReflectionTexture.filterMode = FilterMode.Trilinear;
        m_ReflectionTexture.antiAliasing = 1;
        GameObject go = new GameObject("MirrorCam", typeof(Camera), typeof(FlareLayer));
        //go.hideFlags = HideFlags.HideAndDontSave;
        reflectionCamera = go.GetComponent<Camera>();
        //mysky = go.AddComponent<Skybox> ();
        go.transform.SetParent(normalTrans);
        go.transform.localPosition = Vector3.zero;
        reflectionCamera.enabled = false;
        reflectionCamera.targetTexture = m_ReflectionTexture;
        reflectionCamera.clearFlags = CameraClearFlags.SolidColor;
        reflectionCamera.backgroundColor = Color.black;
        reflectionCamera.cullingMask = ~(1 << 4) & m_ReflectLayers.value;
        reflectionCamera.fieldOfView = cam.fieldOfView;
        reflectionCamera.aspect = cam.aspect;

        refT = reflectionCamera.transform;

        SetTexture(m_ReflectionTexture);        
    }

    public void SetTexture(RenderTexture target)
    {
        for (int i = 0, length = allMats.Count; i < length; ++i)
        {
            Material m = allMats[i];
            m.SetTexture(uniqueTextureID, target);
        }
    }

    private void OnEnable()
    {
        SetTexture(m_ReflectionTexture);
    }

    void OnDestroy()
    {
        if (m_ReflectionTexture)
        {
            DestroyImmediate(m_ReflectionTexture);
            m_ReflectionTexture = null;
        }

        if (reflectionCamera)
        {
            DestroyImmediate(reflectionCamera.gameObject);
            reflectionCamera = null;
        }
    }

    Vector4 reflectionPlane;
    Vector4 clipPlane;
    Matrix4x4 reflection = Matrix4x4.identity;
    Matrix4x4 ref_WorldToCam;


    static float Dot(ref Vector3 left, ref Vector3 right)
    {
        return left.x * right.x + left.y * right.y + left.z * right.z;
    }

    public void OnWillRenderObject()
    {
        if (s_InsideRendering || !render.enabled )
            return;
        s_InsideRendering = true;
        
        Vector3 localPos = normalTrans.worldToLocalMatrix.MultiplyPoint3x4(cam.transform.position);
        if (localPos.y < 0)
        {
            s_InsideRendering = false;
            return;
        }
        
        refT.eulerAngles = cam.transform.eulerAngles;
        Vector3 localEuler = refT.localEulerAngles;
        localEuler.x *= -1;
        localEuler.z *= -1;
        refT.localEulerAngles = localEuler;

        localPos.y *= -1;
        refT.localPosition = localPos;
        
        Vector3 normal = normalTrans.up;
        Vector3 pos = normalTrans.position;
        float d = -Dot(ref normal, ref pos) - m_ClipPlaneOffset;
        reflectionPlane = new Vector4(normal.x, normal.y, normal.z, d);
        CalculateReflectionMatrix(ref reflection, ref reflectionPlane);
        ref_WorldToCam = cam.worldToCameraMatrix * reflection;
        reflectionCamera.worldToCameraMatrix = ref_WorldToCam;
        clipPlane = CameraSpacePlane(ref ref_WorldToCam, ref pos, ref normal);
        reflectionCamera.projectionMatrix = cam.CalculateObliqueMatrix(clipPlane);

        GL.invertCulling = true;
        reflectionCamera.Render();
        GL.invertCulling = false;

        s_InsideRendering = false;
    }

    private Vector4 CameraSpacePlane(ref Matrix4x4 worldToCameraMatrix, ref Vector3 pos, ref Vector3 normal)
    {
        Vector3 offsetPos = pos + normal * m_ClipPlaneOffset;
        Vector3 cpos = worldToCameraMatrix.MultiplyPoint3x4(offsetPos);
        Vector3 cnormal = worldToCameraMatrix.MultiplyVector(normal).normalized;
        return new Vector4(cnormal.x, cnormal.y, cnormal.z, -Dot(ref cpos, ref cnormal));
    }

    private static void CalculateReflectionMatrix(ref Matrix4x4 reflectionMat, ref Vector4 plane)
    {
        reflectionMat.m00 = (1F - 2F * plane[0] * plane[0]);
        reflectionMat.m01 = (-2F * plane[0] * plane[1]);
        reflectionMat.m02 = (-2F * plane[0] * plane[2]);
        reflectionMat.m03 = (-2F * plane[3] * plane[0]);

        reflectionMat.m10 = (-2F * plane[1] * plane[0]);
        reflectionMat.m11 = (1F - 2F * plane[1] * plane[1]);
        reflectionMat.m12 = (-2F * plane[1] * plane[2]);
        reflectionMat.m13 = (-2F * plane[3] * plane[1]);

        reflectionMat.m20 = (-2F * plane[2] * plane[0]);
        reflectionMat.m21 = (-2F * plane[2] * plane[1]);
        reflectionMat.m22 = (1F - 2F * plane[2] * plane[2]);
        reflectionMat.m23 = (-2F * plane[3] * plane[2]);
    }
}
