using UnityEngine;
using System.Collections;
using System;
using XLua;
using DG.Tweening;

[Hotfix]
[LuaCallCSharp]
public class FlyCurve : MonoBehaviour {

    Transform mTran;
    Bezier bezier;
    
    void Start () {
        mTran = transform;
    }

    void UpdatePosition(float value)
    {
        if(mTran != null && bezier != null)
        {
            mTran.position = bezier.GetPointAtTime(value);
        }
    }
    
    void MoveComplete()
    {
        GameObject.DestroyImmediate(this);
    }

    static public FlyCurve Begin(GameObject go, Vector3 startPosition, Vector3 point, Vector3 targetPosition, float duration)
    {
        go.transform.DOKill(true);
        go.transform.position = startPosition;

        FlyCurve curve = go.GetComponent<FlyCurve>();
        if (curve == null) curve = go.AddComponent<FlyCurve>();
        curve.bezier = new Bezier(startPosition, point, Vector3.zero, targetPosition);

        Tweener t = DG.Tweening.DOTween.To((float value) =>
        {
            curve.UpdatePosition(value);

        }, 0, 1, duration);

        t.OnComplete(() => {
            curve.MoveComplete();
        });

        return curve;
    }
}
