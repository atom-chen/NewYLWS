using UnityEngine;
using System.Collections;

public class AnimationSpriteSheet : ResScriptBase
{
    public int uvX = 4;
    public int uvY = 2;
    public int fps = 24;
    public float delay = 0f;

    private float timeSinceStart = 0f;
    private float timeAfterDelay = 0f;

    //private bool isPause = false;

    //void Start()
    //{
    //    //Messenger.Broadcast<Pausable>(PauseMessage.ADD_PAUSE_LISTNER, this);
    //}

    //void OnDestroy()
    //{
    //    //Messenger.Broadcast<Pausable>(PauseMessage.REMOVE_PAUSE_LISTNER, this);
    //}

	// Update is called once per frame
	void Update () 
    {
        if (m_isPause)
        {
            return;
        }

        timeSinceStart += Time.deltaTime;
        if (timeSinceStart < delay)
        {
            return;
        }

        timeAfterDelay += Time.deltaTime;
        int index = (int)(timeAfterDelay * fps);
        index = index % (uvX * uvY);

        Vector2 size = new Vector2(1.0f / uvX, 1.0f / uvY);

        int uIndex = index % uvX;
        int vIndex = index / uvX;
        Vector2 offset = new Vector2(uIndex * size.x, 1 - size.y - vIndex * size.y);

        GetComponent<Renderer>().material.SetTextureOffset("_MainTex", offset);
        GetComponent<Renderer>().material.SetTextureScale("_MainTex", size);
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
