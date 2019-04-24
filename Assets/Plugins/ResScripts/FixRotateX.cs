using UnityEngine;
using System.Collections;

public class FixRotateX : MonoBehaviour {
    //Transform parent;
	// Use this for initialization
    //void Start () {
    //    parent = transform.parent;
    //}
	
	// Update is called once per frame
	void Update () {
		transform.rotation = Quaternion.Euler(new Vector3(0, 0, 0));
	}
}
