using UnityEngine;
using System.Collections;

public class AnimationScrollTextureX : ResScriptBase
{
    public float Speed = 0.25f;
    public float tmpTime = 0f;
    private float delayTime = 0.0f;
    private float startTime = 0f;
    private Renderer m_renderer;
    //private bool isPause = false;

    //void Start()
    //{
    //    //Messenger.Broadcast<Pausable>(PauseMessage.ADD_PAUSE_LISTNER, this);
    //}

    void Awake()
    {
        m_renderer = gameObject.GetComponentInChildren<Renderer>(true);
    }

    void OnDestroy()
    {
        m_renderer = null;
    }

    void OnEnable()
    {
        delayTime = tmpTime;
        startTime = Time.time;
    }

    //void OnDestroy()
    //{
    //    //Messenger.Broadcast<Pausable>(PauseMessage.REMOVE_PAUSE_LISTNER, this);
    //}

    void FixedUpdate()
    {
        if (m_isPause)
        {
            return;
        }

        if(m_renderer != null && m_renderer.material != null && m_renderer.material.HasProperty("_MainTex"))
        {
            delayTime -= Time.deltaTime;
            if (delayTime < 0)
            {
                float offset = (Time.time - startTime) * (-Speed);
                m_renderer.material.mainTextureOffset = new Vector2(offset, 0);
            }
        }
    }

    //public void Pause(PAUSABLE_REASON reason)
    //{
    //    isPause = true;
    //}

    //public void Resume(PAUSABLE_REASON reason)
    //{
    //    isPause = false;
    //}
}
