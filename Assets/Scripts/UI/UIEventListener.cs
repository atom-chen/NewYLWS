using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using XLua;

[Hotfix]
[LuaCallCSharp]
public class UIEventListener : UnityEngine.EventSystems.EventTrigger
{
    [CSharpCallLua]
    public delegate void VoidDelegate(GameObject go, float x, float y);

    public VoidDelegate onClick;
    public VoidDelegate onDown;
    public VoidDelegate onEnter;
    public VoidDelegate onExit;
    public VoidDelegate onUp;
    //public VoidDelegate onSelect;
    //public VoidDelegate onUpdateSelect;
    public VoidDelegate onDrag;
    public VoidDelegate onDragBegin;
    public VoidDelegate onDragEnd;
    public VoidDelegate onDrop;

    static public UIEventListener Get(GameObject go)
    {
        UIEventListener listener = go.GetComponent<UIEventListener>();
        if(listener == null)
        {
            listener = go.AddComponent<UIEventListener>();
        }
        return listener;
    }

    static public void Remove(GameObject go)
    {
        UIEventListener listener = go.GetComponent<UIEventListener>();
        if (listener != null)
        {
            GameObject.DestroyImmediate(listener);
        }
    }

    public override void OnPointerClick(PointerEventData eventData)
    {
        if (onClick != null)
        {
            onClick(gameObject, eventData.position.x, eventData.position.y);
        }
    }
    public override void OnPointerDown(PointerEventData eventData)
    {
        if (onDown != null)
        {
            onDown(gameObject, eventData.position.x, eventData.position.y);
        }
    }
    public override void OnPointerEnter(PointerEventData eventData)
    {
        if (onEnter != null)
        {
            onEnter(gameObject, eventData.position.x, eventData.position.y);
        }
    }

    public override void OnPointerExit(PointerEventData eventData)
    {
        if (onExit != null)
        {
            onExit(gameObject, eventData.position.x, eventData.position.y);
        }
    }

    public override void OnPointerUp(PointerEventData eventData)
    {
        if (onUp != null)
        {
            onUp(gameObject, eventData.position.x, eventData.position.y);
        }
    }

    public override void OnDrag(PointerEventData eventData)
    {
        if (onDrag != null)
        {
            onDrag(gameObject, eventData.position.x, eventData.position.y);
        }
    }

    public override void OnBeginDrag(PointerEventData eventData)
    {
        if (onDragBegin != null)
        {
            onDragBegin(gameObject, eventData.position.x, eventData.position.y);
        }
    }

    public override void OnEndDrag(PointerEventData eventData)
    {
        if (onDragEnd != null)
        {
            onDragEnd(gameObject, eventData.position.x, eventData.position.y);
        }
    }

    public override void OnDrop(PointerEventData eventData)
    {
        if (onDrop != null)
        {
            onDrop(gameObject, eventData.position.x, eventData.position.y);
        }
    }

    private void OnDestroy()
    {
        onClick = null;
        onDown = null;
        onEnter = null;
        onExit = null;
        onUp = null;
        onDrag = null;
        onDragBegin = null;
        onDragEnd = null;
        onDrop = null;
    }
}


