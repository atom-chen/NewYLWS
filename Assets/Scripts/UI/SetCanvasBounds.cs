using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

[ExecuteInEditMode()]
[Hotfix]
[LuaCallCSharp]
public class SetCanvasBounds : MonoBehaviour {

    public RectTransform panel;
    public bool DoAwake = false;

    Rect lastSafeArea = new Rect(0, 0, 0, 0);
   
    void ApplySafeArea(Rect area)
    {
        panel.anchoredPosition = Vector2.zero;
        panel.sizeDelta = Vector2.zero;

        var anchorMin = area.position;
        var anchorMax = area.position + area.size;
        anchorMin.x /= Screen.width;
        anchorMin.y /= Screen.height;
        anchorMax.x /= Screen.width;
        anchorMax.y /= Screen.height;
        panel.anchorMin = anchorMin;
        panel.anchorMax = anchorMax;

        lastSafeArea = area;
    }

    void Update()
    {
        DoAdjust();
    }

    void DoAdjust()
    {
        if (panel == null) { return; }

        Rect safeArea = SetSafeArea(Screen.safeArea);

#if UNITY_EDITOR
        Vector2 screen = screenSize;
        if (screen.x == 1125 && screen.y == 2436)
        {
            safeArea.y = 102;
            safeArea.height = 2202;
        }
        if (screen.x == 2436 && screen.y == 1125)
        {
            safeArea.x = 132;
            safeArea.y = 63;
            safeArea.height = 1062;
            safeArea.width = 2172;
        }
#endif
        if (safeArea != lastSafeArea)
        {
            ApplySafeArea(safeArea);
        }
    }

    void Awake()
    {
        if(DoAwake)
        {
            DoAdjust();
        }
    }

    public Rect SetSafeArea(Rect safeArea)
    {
        return safeArea;
    }


#if UNITY_EDITOR
    static int mSizeFrame = -1;
    static System.Reflection.MethodInfo s_GetSizeOfMainGameView;
    static Vector2 mGameSize = Vector2.one;

    static public Vector2 screenSize
    {
        get
        {
            int frame = Time.frameCount;

            if (mSizeFrame != frame || !Application.isPlaying)
            {
                mSizeFrame = frame;

                if (s_GetSizeOfMainGameView == null)
                {
                    System.Type type = System.Type.GetType("UnityEditor.GameView,UnityEditor");
                    s_GetSizeOfMainGameView = type.GetMethod("GetSizeOfMainGameView",
                        System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static);
                }
                mGameSize = (Vector2)s_GetSizeOfMainGameView.Invoke(null, null);
            }
            return mGameSize;
        }
    }
#else
	static public Vector2 screenSize { get { return new Vector2(Screen.width, Screen.height); } }
#endif
}
