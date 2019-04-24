using UnityEngine;
using System.Collections;

public class RotateThis : ResScriptBase
{
    public float rotationSpeedX = 90;
    public float rotationSpeedY = 0;
    public float rotationSpeedZ = 0;
	public float delay = 0f;
    public bool local = true;

	private float timeSinceStart = 0f;
    //private float timeAfterDelay = 0f;

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

        if (local == true) transform.Rotate(new Vector3(rotationSpeedX, rotationSpeedY, rotationSpeedZ) * Time.deltaTime);
        if (local == false) transform.Rotate(new Vector3(rotationSpeedX, rotationSpeedY, rotationSpeedZ) * Time.deltaTime, Space.World);
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
