using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateY : MonoBehaviour {

    Transform m_tran;
    Animator m_animator;

    public bool isPause;
    public float rotationSpeedZ = 45;
    public float dir = -1;

    private void OnEnable()
    {
        if (m_animator == null)
        {
            m_animator = gameObject.GetComponentInParent<Animator>();
        }
    }

    private void OnDisable()
    {
        m_animator = null;
    }

    void Update () {

        if(isPause)
        {
            return;
        }
       

        if (m_animator != null)
        {
            AnimatorStateInfo stateInfo = m_animator.GetCurrentAnimatorStateInfo(0);
            if (stateInfo.IsName("Base Layer.idle"))
            {
                transform.Rotate(new Vector3(0, 0, dir * rotationSpeedZ) * Time.deltaTime);
            }
        }
	}

    void OnDestroy()
    {
        m_animator = null;
    }
}
