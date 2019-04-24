using UnityEngine;
using System.Collections;

public class AnimationSpriteMove : MonoBehaviour
{
    public bool isLocal = true;
    public bool fadeIn = false;
    public bool fadeOut = false;

    public Vector3 direction = Vector3.zero;
    public float speed = 1f;
    public float distance = 10;

    private Vector3 orgPos = Vector3.zero;
    private float realDistance = 0f;
	// Use this for initialization
	void Start ()
	{
        orgPos = isLocal ? transform.localPosition : transform.position;
	    realDistance = (direction*distance).magnitude;
	}
	
	// Update is called once per frame
	void Update ()
	{
	    Vector3 moveVec = direction * Mathf.Repeat(Time.time, distance);
	    float movement = moveVec.magnitude;

	    float alpha = 0;
        if (fadeIn && movement < 0.1 * realDistance)
	    {
            alpha = movement / realDistance * 10;
	        SetAlpha(alpha);
	    }
        if (fadeOut && movement > 0.9 * realDistance)
	    {
            alpha = (1 - movement / realDistance) * 10;
            SetAlpha(alpha);
	    }

	    if (isLocal)
	    {
            transform.localPosition = orgPos + moveVec;   
	    }
	    else
	    {
            transform.position = orgPos + moveVec;
	    }
	}

    void SetAlpha(float alpha)
    {
        if (GetComponent<ParticleSystem>() != null)
        {
            if(GetComponent<ParticleSystem>().GetComponent<Renderer>().material.HasProperty("_Color"))
            {
                Color c = GetComponent<ParticleSystem>().GetComponent<Renderer>().material.color;
                c.a = alpha;
                GetComponent<ParticleSystem>().GetComponent<Renderer>().material.color = c;
            }
            
        }
    }
}
