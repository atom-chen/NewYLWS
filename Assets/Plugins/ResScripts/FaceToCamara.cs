using UnityEngine;
using System.Collections;

public class FaceToCamara : ResScriptBase
{

    public Camera _camera = null;

	// Use this for initialization
	void Start ()
	{
	    if (_camera == null)
	    {
            _camera = Camera.main;
        }
	}
	
	// Update is called once per frame
	void Update ()
	{
	    if (m_isPause) return;
	    if (_camera != null)
	    {
            transform.LookAt(_camera.transform);
        }
	}
}
