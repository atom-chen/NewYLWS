using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GetDepthCameraPosition : MonoBehaviour
{
    
    public Vector3 Pos;
	public Vector3 rolePos = Vector3.zero;
    public float away = 10;

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update ()
    {


		Vector3 dir = transform.forward * -1;


        Pos = rolePos + dir * away;
	}
}
