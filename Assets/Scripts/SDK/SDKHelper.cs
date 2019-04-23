using UnityEngine;
using XLua;
using System;
using System.Runtime.InteropServices;

[Hotfix]
[LuaCallCSharp]
public class SDKHelper : MonoSingleton<SDKHelper>
{
    private Action<string> m_luaListener = null;

    public void SDKCallLua(string msg)
    {
        if (m_luaListener == null)
        {
            m_luaListener = XLuaManager.Instance.GetLuaEnv().Global.Get<Action<string>>("HandleSDKCallback");
        }
        if (m_luaListener != null)
        {
            m_luaListener(msg);
        }
    }

    public void LuaCallSDK(string msg)
    {
#if UNITY_ANDROID
        LuaCallAndroid(msg);
#elif UNITY_IOS
        LuaCallIOS(msg);
#endif
    }

#if UNITY_ANDROID
    private static void LuaCallAndroid(params object[] param)
    {
        try
        {
            AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
            AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity");
            if (jo != null)
            {
                jo.Call("HandleUnityCall", param);
            }
        }
        catch (Exception ex)
        {
            Logger.Log("call sdk get exception message: " + ex.Message);
        }
    }
#endif

#if UNITY_IOS
    [DllImport("__Internal")]
    private static extern void LuaCallIOS(string msg);
#endif

    public override void Dispose()
    {
        m_luaListener = null;
    }
}
