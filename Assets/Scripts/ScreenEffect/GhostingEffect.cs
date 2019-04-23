using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using XLua;

[Hotfix]
[LuaCallCSharp]

/// <summary>
/// 残影效果
/// </summary>
public class GhostingEffect : MonoBehaviour
{
    public float m_ghostingLife = 2f;                                   // 每个残影的持续时间
    public float m_triggerInterval = 1f;                                // 残影生成的时间间隔
    public float m_ghostingEffectTime = 1000f;                          // 残影效果的持续时间
    public bool m_ignoreTimeScale = true;                               // 各时间参数是否忽略TimeScale
    public int m_maxGhosting = 5;                                       // 同时存在的残影个数上限
    public Color m_ghostingColor = new Color(0f, 0f, 0f, 0.7f);         // 残影的颜色

    Renderer m_affectRender;
    MeshFilter m_affectMeshFilter;
    public Material m_mat;

    float m_nextLeftTime = 0f;
    List<Ghosting> m_ghostingList = new List<Ghosting>();
    
    static List<Renderer> m_renders = new List<Renderer>();
    static List<GameObject> m_gos = new List<GameObject>();

    private bool m_ignorePause = true;
    private bool m_isPause = false;


    void Awake()
    {
        m_affectRender = gameObject.GetComponent<Renderer>();
        m_affectMeshFilter = gameObject.GetComponent<MeshFilter>();
    }


    public void Pause()
    {
        m_isPause = true;

        foreach (var item in this.m_ghostingList)
        {
            if (item != null)
            {
                item.Pause();
            }
        }
    }

    public void Resume()
    {
        m_isPause = false;

        foreach (var item in this.m_ghostingList)
        {
            if (item != null)
            {
                item.Resume();
            }
        }
    }
	
	// Update is called once per frame
	//void Update () 
    void OnRenderObject()
    {
        if (m_isPause)
        {
            return;
        }

        if (m_ghostingEffectTime > 0)
        {
            if (m_affectRender != null)
            {
                if (m_nextLeftTime <= 0f)
                {
                    m_nextLeftTime += m_triggerInterval;

                    if (m_maxGhosting > 0 && m_ghostingList.Count >= m_maxGhosting)
                    {
                        Ghosting ghosting = m_ghostingList[0];
                        m_ghostingList.RemoveAt(0);
                        ghosting.InitGhosting(this, m_affectRender, m_affectMeshFilter, m_ghostingColor, m_ghostingLife, m_ignoreTimeScale);
                        m_ghostingList.Add(ghosting);

                        //Debug.Break();
                        Stop();
                    }
                    else
                    {
                        Ghosting ghosting = Ghosting.CreateGhosting(m_mat, this, m_affectRender, m_affectMeshFilter, m_ghostingColor, m_ghostingLife, m_ignoreTimeScale);
                        m_ghostingList.Add(ghosting);
                    }

                    //lastPos = cachedTrans.position;
                }
                m_nextLeftTime -= m_ignoreTimeScale ? Time.unscaledDeltaTime : Time.deltaTime;
            }
            m_ghostingEffectTime -= m_ignoreTimeScale ? Time.unscaledDeltaTime : Time.deltaTime;
        }
        else
        {
            Stop();
        }
	}

    public void Stop()
    {
        m_mat = null;
        m_isPause = false;
        Destroy(this);
    }

    public void RemoveGhosting(Ghosting ghosting)
    {
        m_ghostingList.Remove(ghosting);
    }

    public static void ApplyGhostingEffect(List<GameObject> gos, Material mat, float ghostingLife, float triggerInterval, int maxGhosting, Color ghostingColor, float ghostingEffectTime = 1000f, bool ignoreTimeScale = true, bool ignorePause = true)
    {
        if (gos == null || gos.Count == 0) return;
        if (mat == null)
        {
            return;
        }

        m_renders.Clear();

        for (int i = 0; i < gos.Count; ++i)
        {
            Renderer[] temp = gos[i].GetComponentsInChildren<Renderer>();
            if(temp!= null)
            {
                m_renders.AddRange(temp);
            }
        }
        
        for (int i = 0; i < m_renders.Count; ++i)
        {
            if(m_renders[i] is MeshRenderer || m_renders[i] is SkinnedMeshRenderer)
            {
                GhostingEffect ghostingEffect = m_renders[i].gameObject.AddComponent<GhostingEffect>();

                ghostingEffect.m_mat = mat;
                ghostingEffect.m_ghostingLife = ghostingLife;
                ghostingEffect.m_triggerInterval = triggerInterval;
                ghostingEffect.m_ghostingEffectTime = ghostingEffectTime;
                ghostingEffect.m_ignoreTimeScale = ignoreTimeScale;
                ghostingEffect.m_maxGhosting = maxGhosting;
                ghostingEffect.m_ghostingColor = ghostingColor;
                ghostingEffect.m_ignorePause = true;
            }
        }

        m_renders.Clear();
    }

    public static void ApplyGhostingEffect(GameObject go, Material mat, float ghostingLife, float triggerInterval, int maxGhosting, Color ghostingColor, float ghostingEffectTime = 1000f, bool ignoreTimeScale = true, bool ignorePause = true)
    {
        if (!go) return;

        m_gos.Clear();
        m_gos.Add(go);

        ApplyGhostingEffect(m_gos, mat, ghostingLife, triggerInterval, maxGhosting, ghostingColor, ghostingEffectTime, ignoreTimeScale);
        m_gos.Clear();
    }

}
