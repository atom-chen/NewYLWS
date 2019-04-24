using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class GetForward : MonoBehaviour 
{
    public Vector3 forward = Vector3.zero;

	void Update () {

        if (Application.isEditor)
        {
            forward = transform.forward;
        }

        
	}
}
