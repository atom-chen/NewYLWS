using UnityEngine;
using System.Collections;

public class ResScriptBase : MonoBehaviour 
{
    protected bool m_isPause = false;

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	
	}

    public void Pause()
    {
        m_isPause = true;
    }

    public void Resume()
    {
        m_isPause = false;
    }
}
