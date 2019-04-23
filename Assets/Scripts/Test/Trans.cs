using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Trans : MonoBehaviour {

	// Use this for initialization

    public Vector3 localpos = Vector3.zero;
    public Vector3 worldpos = Vector3.zero;
    public Vector3 worldpos2 = Vector3.zero;
    public Vector3 calcWorldpos = Vector3.zero;

    public Vector3 localDir = Vector3.right;
    public Vector3 worldDir = Vector3.zero;
    public Vector3 worldDir2 = Vector3.zero;
    public Vector3 calcWorldDir = Vector3.zero;

    //public Vector3 stand1WorldDir = Vector3.zero;
    //public Vector3 stand1WorldPos = Vector3.zero;

    public Matrix4x4 l2wM44 = Matrix4x4.zero;

    public Vector4 row0 = Vector4.zero;
    public Vector4 row1 = Vector4.zero;
    public Vector4 row2 = Vector4.zero;
    public Vector4 row3 = Vector4.zero;

    public Vector3 localRotate = Vector3.zero;
    public Vector3 worldRotate = Vector3.zero;

	void Start () {
        //stand1 = transform.Find("stand1");

        
	}
	
	// Update is called once per frame
	void Update () {
        worldpos = transform.TransformPoint(localpos);

        l2wM44 = transform.localToWorldMatrix;
        worldpos2 = l2wM44.MultiplyPoint(localpos);

        Vector4 v4LocalPos = new Vector4(localpos.x, localpos.y, localpos.z, 1);

        row0 = l2wM44.GetRow(0);
        row1 = l2wM44.GetRow(1);
        row2 = l2wM44.GetRow(2);
        row3 = l2wM44.GetRow(3);

        for (int i = 0; i < 4;++i )
        {
            Vector4 row = l2wM44.GetRow(i);

            float sum = 0;
            for (int j = 0; j < 4; ++j )
            {
                sum += row[j] * v4LocalPos[j];
            }

            if (i < 3)
            {
                calcWorldpos[i] = sum;
            }
        }

        worldDir = transform.TransformDirection(localDir);
        worldDir2 = l2wM44.MultiplyVector(localDir);

        Vector4 v4LocalDir = new Vector4(localDir.x, localDir.y, localDir.z, 0);
        for (int i = 0; i < 4; ++i)
        {
            Vector4 row = l2wM44.GetRow(i);

            float sum = 0;
            for (int j = 0; j < 4; ++j)
            {
                sum += row[j] * v4LocalDir[j];
            }

            if (i < 3)
            {
                calcWorldDir[i] = sum;
            }
        }

        //Debug.DrawRay(transform.position, worldDir, Color.green, 1000);

        //stand1WorldPos = transform.position;
        //stand1WorldDir = transform.rotation.ToEulerAngles();

        localRotate = transform.localEulerAngles;
        worldRotate = transform.eulerAngles;
	}
}
