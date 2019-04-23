using UnityEngine;
using UnityEngine.Rendering;
using System.Collections;
using System.Collections.Generic;
using XLua;

[Hotfix]
[LuaCallCSharp]
[RequireComponent(typeof(Camera))]
public class NewCloseUpEffect : MonoBehaviour 
{
    public static Color MaskBGColor = new Color(0f, 0f, 0f, 0.5f);
    public static Color MaskFGColor = new Color(0f, 0f, 0f, 0.25f);

    public Color maskBGColor = new Color(0f, 0f, 0f,0.5f);
    public Color maskFGColor = new Color(0f, 0f, 0f, 0.25f);

    private Camera mCacheCamera;                                    // 主摄像机
    private Material m_maskMat;
    
    private float chgShaderLeftS = 0;

    private static NewCloseUpEffect instance = null;

    //private List<GameObject> m_lowerGos = new List<GameObject>(2);
    //private List<GameObject> m_higherGos = new List<GameObject>(8);

    private List<GameObject> m_gos = new List<GameObject>(16);
    private int m_lowLayer = 20;
    private int m_highLayer = 21;
    private bool m_isPrepareDazhao = false;
    [Range(0, 4)]
    public int iterations = 3;
    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;
    [Range(1, 8)]
    public int downSample = 2;
    private Material m_blurMat = null;

    private GameObject m_maskGo = null;
    private CommandBuffer m_cmdBuf = null;
    private Dictionary<int, List<Renderer>> m_renderDic = new Dictionary<int, List<Renderer>>();

    public static void ApplyCloseUpEffect(Material mat, GameObject[] gos, int lowLayer, int highLayer, int isPrepareDazhao, Material blurMat)
    {
        if (mat == null)
        {
            return;
        }
        
        if (instance != null)
        {
            instance.SetParam(mat, gos, lowLayer, highLayer, isPrepareDazhao == 1, blurMat);
            instance.DoEffect();
        }
        else
        {
            GameObject cameraGO = GameObject.Find("Main Camera");
            if (cameraGO == null)
            {
                return;
            }

            instance = cameraGO.AddComponent<NewCloseUpEffect>();

            instance.SetParam(mat, gos, lowLayer, highLayer, isPrepareDazhao == 1, blurMat);
            instance.DoEffect();
        }

        //SetCloseUpEffectColor(MaskBGColor);
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
        //m_cmdBuf = new CommandBuffer();
        //m_cmdBuf.name = "NewCloseUp";
    }

    public void DoEffect()
    {
        if (m_cmdBuf == null)
        {
            m_cmdBuf = new CommandBuffer();
            m_cmdBuf.name = "NewCloseUp";

            MakeCommand();
            mCacheCamera.AddCommandBuffer(CameraEvent.AfterImageEffects, m_cmdBuf);
        }
        else
        {
            m_cmdBuf.Clear();
            MakeCommand();
        }
    }

    private List<Renderer> GetRenderers(GameObject go)
    {
        int id = go.GetInstanceID();
        List<Renderer> list = null;

        if (m_renderDic.TryGetValue(id, out list))
        {
            return list;
        }

        list = new List<Renderer>();
        Renderer[] rs = go.GetComponentsInChildren<Renderer>(false);
        if (rs != null)
        {
            for (int j = 0; j < rs.Length; j++)
            {
                Renderer r = rs[j];
                list.Add(r);
            }
        }

        m_renderDic[id] = list;
        return list;
    }

    private void SetParam(Material mat, GameObject[] gos, int lowLayer, int highLayer, bool isPrepareDazhao, Material blurMat)
    {

        //Debug.Log(" +++++++++++++++++++++++++ SetParam ");
        m_maskMat = new Material(mat);

        m_gos.Clear();
        for (int i = 0; i < gos.Length; i++)
        {
            m_gos.Add(gos[i]);
        }
        
        m_lowLayer = lowLayer;
        m_highLayer = highLayer;
        m_isPrepareDazhao = isPrepareDazhao;
        if (blurMat)
        {
            m_blurMat = new Material(blurMat);
        }

        if (m_maskGo == null)
        {
            m_maskGo = GameObject.CreatePrimitive(PrimitiveType.Plane);
            m_maskGo.transform.parent = transform;
            m_maskGo.transform.localPosition = new Vector3(0, 0, 12);
            m_maskGo.transform.localEulerAngles = new Vector3(90, 0, 0);
            m_maskGo.transform.localScale = new Vector3(50, 1, 50);
            m_maskGo.layer = 30;
        }

    }

    private void MakeCommand()
    {
        if (m_maskGo)
        {
            m_maskMat.SetFloat("_R", maskBGColor.r);
            m_maskMat.SetFloat("_G", maskBGColor.g);
            m_maskMat.SetFloat("_B", maskBGColor.b);
            m_maskMat.SetFloat("_Alpha", maskBGColor.a);
            m_cmdBuf.DrawRenderer(m_maskGo.GetComponent<Renderer>(), m_maskMat);
        }

        for (int i = 0; i < m_gos.Count; i++)
        {
            Renderer[] rs = m_gos[i].GetComponentsInChildren<Renderer>(false);
            if (rs != null)
            {
                for (int j = 0; j < rs.Length; j++)
                {
                    Renderer r = rs[j];
                    if (m_lowLayer == r.gameObject.layer && r.sharedMaterial)
                    {
                        m_cmdBuf.DrawRenderer(r, r.sharedMaterial, 0, 0);
                    }
                }
            }
        }

        if (m_maskGo)
        {
            m_maskMat.SetFloat("_R", maskFGColor.r);
            m_maskMat.SetFloat("_G", maskFGColor.g);
            m_maskMat.SetFloat("_B", maskFGColor.b);
            m_maskMat.SetFloat("_Alpha", maskFGColor.a);
            m_cmdBuf.DrawRenderer(m_maskGo.GetComponent<Renderer>(), m_maskMat);
        }

        for (int i = 0; i < m_gos.Count; i++)
        {
            Renderer[] rs = m_gos[i].GetComponentsInChildren<Renderer>(false);
            if (rs != null)
            {
                for (int j = 0; j < rs.Length; j++)
                {
                    Renderer r = rs[j];
                    if (m_highLayer == r.gameObject.layer && r.sharedMaterial)
                    {
                        m_cmdBuf.DrawRenderer(r, r.sharedMaterial, 0, 0);
                    }
                }
            }
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
        Recover();
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
    
    void Recover()
    {
        m_renderDic.Clear();

        if (m_cmdBuf != null)
        {
            mCacheCamera.RemoveCommandBuffer(CameraEvent.AfterImageEffects, m_cmdBuf);
            m_cmdBuf.Clear();
            m_cmdBuf = null;
        }

        //m_higherGos.Clear();
        //m_lowerGos.Clear();
        m_gos.Clear();

        if (m_maskGo != null)
        {
            GameObject.DestroyImmediate(m_maskGo);
            m_maskGo = null;
        }

        if (m_maskMat != null)
        {
            Destroy(m_maskMat);
            m_maskMat = null;
        }

        m_isPrepareDazhao = false;
        if (m_blurMat != null)
        {
            Destroy(m_blurMat);
            m_blurMat = null;
        }
    }

    
    public static void SetCloseUpEffectColor(Color color)
    {
        if(instance)
        {
            instance.maskBGColor = color;
            instance.maskFGColor = color * 0.5f;
        }
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (m_isPrepareDazhao && m_blurMat != null)
        {
            int rtW = src.width / downSample;
            int rtH = src.height / downSample;

            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            buffer0.filterMode = FilterMode.Bilinear;

            Graphics.Blit(src, buffer0);

            for (int i = 0; i < iterations; i++)
            {
                m_blurMat.SetFloat("_BlurSize", 1.0f + i * blurSpread);

                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                // Render the vertical pass
                Graphics.Blit(buffer0, buffer1, m_blurMat, 0);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                // Render the horizontal pass
                Graphics.Blit(buffer0, buffer1, m_blurMat, 1);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }

            Graphics.Blit(buffer0, dest);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
