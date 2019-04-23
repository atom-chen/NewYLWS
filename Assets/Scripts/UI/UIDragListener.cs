using UnityEngine;
using System.Collections;
using UnityEngine.EventSystems;
using System;
using XLua;

[Hotfix]
[LuaCallCSharp]
public class UIDragListener : MonoBehaviour, IBeginDragHandler, IDragHandler, IEndDragHandler
{
    public delegate void VoidDelegate(GameObject go, float x, float y, PointerEventData eventData);
    public VoidDelegate onDrag;
    public VoidDelegate onDragBegin;
    public VoidDelegate onDragEnd;
    static public UIDragListener Get(GameObject go)
    {
        UIDragListener listener = go.GetComponent<UIDragListener>();
        if (listener == null)
        {
            listener = go.AddComponent<UIDragListener>();
        }
        return listener;
    }

    public void OnBeginDrag(PointerEventData eventData)
    {
        if (onDragBegin != null)
        {
            onDragBegin(gameObject, eventData.position.x, eventData.position.y, eventData);
        }
    }

    public void OnDrag(PointerEventData eventData)
    {
        if (onDrag != null)
        {
            onDrag(gameObject, eventData.position.x, eventData.position.y, eventData);
        }
    }

    public void OnEndDrag(PointerEventData eventData)
    {
        if (onDragEnd != null)
        {
            onDragEnd(gameObject, eventData.position.x, eventData.position.y, eventData);
        }
    }

    static public void Remove(GameObject go)
    {
        UIDragListener listener = go.GetComponent<UIDragListener>();
        if (listener != null)
        {
            GameObject.DestroyImmediate(listener);
        }
    }

    private void OnDestroy()
    {
        onDrag = null;
        onDragBegin = null;
        onDragEnd = null;
    }
}
