using UnityEngine;
using System.Collections;
using UnityEngine.EventSystems;
using System;
using XLua;

[Hotfix]
[LuaCallCSharp]
public class SpringContent : MonoBehaviour
{
    public delegate void OnFinished();

    public Vector3 target = Vector3.zero;
    public float strength = 10f;
    public OnFinished onFinished;

    static public SpringContent current;
    private RectTransform rectTran;

    void Start()
    {
        rectTran = GetComponent<RectTransform>();
    }

    void Update()
    {
        AdvanceTowardsPosition();
    }

    protected virtual void AdvanceTowardsPosition()
    {
        float delta = Time.unscaledDeltaTime;
        if (delta >= 1)
        {
            return;
        }

        bool trigger = false;
     
        Vector3 after = SpringLerp(rectTran.anchoredPosition3D, target, strength, delta);
        if ((after - target).sqrMagnitude < 0.01f)
        {
            after = target;
            enabled = false;
            trigger = true;
        }
        rectTran.anchoredPosition3D = after;

        if (trigger && onFinished != null)
        {
            current = this;
            onFinished();
            current = null;
        }
    }

    static Vector3 SpringLerp(Vector3 from, Vector3 to, float strength, float deltaTime)
    {
        return Vector3.Lerp(from, to, SpringLerp(strength, deltaTime));
    }

    static float SpringLerp(float strength, float deltaTime)
    {
        if (deltaTime > 1f) deltaTime = 1f;
        int ms = Mathf.RoundToInt(deltaTime * 1000f);
        deltaTime = 0.001f * strength;
        float cumulative = 0f;
        for (int i = 0; i < ms; ++i) cumulative = Mathf.Lerp(cumulative, 1f, deltaTime);
        return cumulative;
    }

    static public SpringContent Begin(GameObject go, Vector3 pos, float strength, OnFinished onFinished = null)
    {
        SpringContent sc = go.GetComponent<SpringContent>();
        if (sc == null) sc = go.AddComponent<SpringContent>();
        sc.target = pos;
        sc.strength = strength;
        sc.onFinished = onFinished;
        sc.enabled = true;
        return sc;
    }
}
