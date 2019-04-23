using UnityEngine;
using System.Collections;
using XLua;

[Hotfix]
[LuaCallCSharp]

public class Ghosting : MonoBehaviour
{
    GhostingEffect m_ghostingEffect;
    bool m_ignoreTimeScale = true;
    float m_ghostingLife = 2f;
    Material m_ghostingMaterial;
    MeshFilter m_meshFilter;
    MeshRenderer m_meshRenderer;
    Mesh m_frameMesh;
    float m_leftLife = 0f;

    Vector3 m_pos;
    Quaternion m_rotation;

    private bool isPause = false;
    
	// Use this for initialization
	void Start ()
    {
	}

    void OnDestroy()
    {
        m_meshRenderer.material = null;
        if (m_ghostingMaterial)
        {
            Destroy(m_ghostingMaterial);
        }
        m_meshFilter.sharedMesh = null;
        if (m_frameMesh)
        {
            Destroy(m_frameMesh);
        }
        if(m_ghostingEffect)
        {
            m_ghostingEffect.RemoveGhosting(this);
        }
    }

    public void Pause()
    {
        isPause = true;
    }

    public void Resume()
    {
        isPause = false;
    }
	
	// Update is called once per frame
	void LateUpdate () 
    {
        if (isPause)
        {
            return;
        }

        if (m_leftLife <= 0)
        {
            gameObject.SetActive(false);
            if (m_frameMesh)
            {
                Destroy(m_frameMesh);
            }
            Destroy(gameObject);
        }
        else
        {
            transform.position = m_pos;
            transform.rotation = m_rotation;
            transform.localScale = Vector3.one;

            m_ghostingMaterial.SetFloat("_Alpha", Mathf.Clamp01(m_leftLife / m_ghostingLife));
            m_leftLife -= m_ignoreTimeScale ? Time.unscaledDeltaTime : Time.deltaTime;
        }
	}

    public void InitGhosting(GhostingEffect ghostingEffect, Renderer affectRender, MeshFilter affectMeshFilter, Color ghostingColor, float ghostingLife, bool ignoreTimeScale)
    {
        this.m_ignoreTimeScale = ignoreTimeScale;
        this.m_ghostingEffect = ghostingEffect;
        this.m_ghostingLife =ghostingLife;
        m_leftLife = ghostingLife;
                

        m_ghostingMaterial.SetColor("_Color", ghostingColor);
        m_ghostingMaterial.SetFloat("_Alpha", 1f);
        m_ghostingMaterial.renderQueue = affectRender.material.renderQueue - 1;

        transform.parent = ghostingEffect.transform;
        transform.position = affectRender.transform.position;
        transform.rotation = affectRender.transform.rotation;
        m_pos = transform.position;
        m_rotation = transform.rotation;

        if (affectRender is SkinnedMeshRenderer)
        {
            (affectRender as SkinnedMeshRenderer).BakeMesh(m_frameMesh);
            m_meshFilter.sharedMesh = m_frameMesh;
        }
        else if (affectRender is MeshRenderer)
        {
            transform.localScale = affectRender.transform.lossyScale;
            m_meshFilter.sharedMesh = affectMeshFilter.sharedMesh;
        }
    }

    public void MeshCreate(Material mat)
    {
        m_ghostingMaterial = mat;   

        m_meshRenderer = gameObject.AddComponent<MeshRenderer>();
        m_meshFilter = gameObject.AddComponent<MeshFilter>();
        m_meshRenderer.material = m_ghostingMaterial;
        m_frameMesh = new Mesh();
    }

    public static Ghosting CreateGhosting(Material mat, GhostingEffect ghostingEffect, Renderer affectRender, MeshFilter affectMeshFilter, Color ghostingColor, float ghostingLife, bool ignoreTimeScale, bool ignorePause = true)
    {
        GameObject frameGO = new GameObject("Ghosting");
        if(affectRender != null)
        {
            frameGO.layer = affectRender.gameObject.layer;
        }
        
        Ghosting ghosting = frameGO.AddComponent<Ghosting>();
        ghosting.MeshCreate(mat);
        ghosting.InitGhosting(ghostingEffect, affectRender, affectMeshFilter, ghostingColor, ghostingLife, ignoreTimeScale);
        return ghosting;
    }
}
