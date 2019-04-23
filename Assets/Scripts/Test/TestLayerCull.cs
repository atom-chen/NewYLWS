using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestLayerCull : MonoBehaviour {

    public float distance = 60;

	void Start () {

        CameraCull();
    }

    private void CameraCull()
    {
        Camera mainCam = Camera.main;
        if (mainCam != null)
        {
            float[] distances = new float[32];
            distances[16] = distance;

            mainCam.layerCullDistances = distances;
        }
    }
}
