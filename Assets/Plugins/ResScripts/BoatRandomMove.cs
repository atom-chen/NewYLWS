using UnityEngine;
using System.Collections;

public class BoatRandomMove : MonoBehaviour {

    float orgY = 0;
    float orgX = 0;
    float orgZ = 0;

    float rotateZ = 0;
    float rotateX = 0;
    public float waveSpeed = 1f;
    public float moveDis = 0.1f;
    public float moveAngle = 3f;
    public float moveDisX = 0.0f;
    public float moveDisZ = 0.0f;
    public float moveLoopDisX = 0f;

    Transform myTrans = null;
    float passedTime = 0;

    void Awake()
    {
        myTrans = transform;
    }

	// Use this for initialization
	void Start () {
        orgY = myTrans.localPosition.y;
        orgX = myTrans.localPosition.x;
        orgZ = myTrans.localPosition.z;
        rotateX = myTrans.localEulerAngles.x;
        rotateZ = myTrans.localEulerAngles.z;
	}
	
	// Update is called once per frame
	void Update () 
    {
        passedTime += Time.unscaledDeltaTime;

        float factor = Mathf.Sin(passedTime * waveSpeed);    

        myTrans.localPosition = new Vector3(orgX + moveDisX * factor, orgY + moveDis * factor, orgZ + moveDisZ * factor);
        myTrans.localEulerAngles = new Vector3(rotateX, myTrans.localEulerAngles.y, rotateZ + moveAngle * Mathf.Sin(passedTime * (waveSpeed) + 1.5f));

        if (moveLoopDisX > 0)
        {
            if (Mathf.Abs(myTrans.localPosition.x - orgX) >= moveLoopDisX)
            {
                myTrans.localPosition = new Vector3(orgX, orgY, orgZ);
                passedTime = 0;
            }
        }
	}
}
