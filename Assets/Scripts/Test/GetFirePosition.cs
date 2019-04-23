using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GetFirePosition : MonoBehaviour {

    public Transform targetTransform;

    public Vector3 Pos;

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
        Pos = targetTransform.position;
	}
}
