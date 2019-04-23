using UnityEngine;
using System.Collections;
using UnityEngine.EventSystems;
using System;
using XLua;

[Hotfix]
[LuaCallCSharp]
public class UIClickListener : MonoBehaviour, IPointerClickHandler
{
    public static bool canClick = true;
    public delegate void VoidDelegate(GameObject go, float x, float y);
    public VoidDelegate onClick;
    static public UIClickListener Get(GameObject go)
    {
        UIClickListener listener = go.GetComponent<UIClickListener>();
        if (listener == null) listener = go.AddComponent<UIClickListener>();
        return listener;
    }
    public void OnPointerClick(PointerEventData eventData)
    {
        if (canClick && onClick != null)
        {
            //Debug.Log("OnPointerClick : " + gameObject.name);
            onClick(gameObject, eventData.position.x, eventData.position.y);
        }
    }

    static public void Remove(GameObject go)
    {
        UIClickListener listener = go.GetComponent<UIClickListener>();
        if (listener != null)
        {
            GameObject.DestroyImmediate(listener);
        }
    }

    private void OnDestroy()
    {
        onClick = null;
    }
}