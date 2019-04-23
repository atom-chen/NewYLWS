using AssetBundles;
using System.IO;
using UnityEngine;
using XLua;
using LuaAPI = XLua.LuaDLL.Lua;
using System;
using System.Text;
using System.Collections;

/// <summary>
/// 说明：xLua管理类
/// 注意：
/// 1、整个Lua虚拟机执行的脚本分成3个模块：热修复、公共模块、逻辑模块
/// 2、公共模块：提供Lua语言级别的工具类支持，和游戏逻辑无关，最先被启动
/// 3、热修复模块：脚本全部放Lua/XLua目录下，随着游戏的启动而启动
/// 4、逻辑模块：资源热更完毕后启动
/// 5、资源热更以后，理论上所有被加载的Lua脚本都要重新执行加载，如果热更某个模块被删除，则可能导致Lua加载异常，这里的方案是释放掉旧的虚拟器另起一个
/// @by wsh 2017-12-28
/// </summary>

[Hotfix]
[LuaCallCSharp]
public class XLuaManager : MonoSingleton<XLuaManager>
{
    public const string luaAssetbundleAssetName = "Lua";
    public const string luaScriptsFolder = "LuaScripts";
    const string commonMainScriptName = "Common.Main";
    const string gameMainScriptName = "GameMain";
    const string hotfixMainScriptName = "XLua.HotfixMain";
    const string PUBLIC_KEY = "BgIAAACkAABSU0ExAAQAAAEAAQBhji64AKEzRxfg3l8Yjk7ZazMSmU31BwKfJ5rkNZp8UfTJHj+bRGdtF+3P7XA6XS+SdIGt0DZORwY43vaJ8wLLdEUDiMxdwaH6uxlczH2qpEi287NBEoyVCmi1wzhwCFHVmgYfoJbzMjuAu0+DJN0xGfo21KoUZ/gbcLndTpaYlg==";
    const bool signAndDecode = false;
    LuaEnv luaEnv = null;
    LuaUpdater luaUpdater = null;
    private bool isRestart = false;

    protected override void Init()
    {
        base.Init();
        string path = AssetBundleUtility.PackagePathToAssetsPath(luaAssetbundleAssetName);
        AssetbundleName = AssetBundleUtility.AssetBundlePathToAssetBundleName(path);
        InitLuaEnv();
    }

    public bool HasGameStart
    {
        get;
        protected set;
    }

    public LuaEnv GetLuaEnv()
    {
        return luaEnv;
    }

    void InitLuaEnv()
    {
        luaEnv = new LuaEnv();
        HasGameStart = false;
        if (luaEnv != null)
        {
#if UNITY_EDITOR
            if (AssetBundleConfig.IsEditorMode)
            {
                luaEnv.AddLoader(CustomLoader);
            }
            else
            {
                if (signAndDecode)
                {
                    luaEnv.AddLoader(new SignatureLoader(PUBLIC_KEY,CustomLoader));
                }
                else
                {
                    luaEnv.AddLoader(CustomLoader);
                }
            }
#else
            if (signAndDecode)
            {
                luaEnv.AddLoader(new SignatureLoader(PUBLIC_KEY,CustomLoader));
            }
            else
            {
                luaEnv.AddLoader(CustomLoader);
            }
#endif
            luaEnv.AddBuildin("pb", XLua.LuaDLL.Lua.LoadPb);
            luaEnv.AddBuildin("fixmath", XLua.LuaDLL.Lua.LoadFixMath);
            luaEnv.AddBuildin("pathing", XLua.LuaDLL.Lua.LoadPathing);
            luaEnv.AddBuildin("cutil", XLua.LuaDLL.Lua.LoadCUtil);
            luaEnv.AddBuildin("rapidjson", XLua.LuaDLL.Lua.LoadRapidJson);
        }
        else
        {
            Logger.LogError("InitLuaEnv null!!!");
        }
    }

    public IEnumerator InitLuaAB()
    {
        AssetBundleMgr.Instance.SetAssetBundleResident(AssetbundleName, true);
        var abloader = AssetBundleMgr.Instance.LoadAssetBundleAsync(AssetbundleName);
        yield return abloader;
        yield break;
    }

    // 这里必须要等待资源管理模块加载Lua AB包以后才能初始化
    public void OnInit()
    {
        if (luaEnv != null)
        {
            LoadScript(commonMainScriptName);
            luaUpdater = gameObject.GetComponent<LuaUpdater>();
            if (luaUpdater == null)
            {
                luaUpdater = gameObject.AddComponent<LuaUpdater>();
            }
            luaUpdater.OnInit(luaEnv);
        }
    }

    public string AssetbundleName
    {
        get;
        protected set;
    }

    // 重启虚拟机：热更资源以后被加载的lua脚本可能已经过时，需要重新加载
    // 最简单和安全的方式是另外创建一个虚拟器，所有东西一概重启
    public void Restart()
    {
        Debug.Log("Restart");
        isRestart = true;
    }

    public IEnumerator CoroutineRestart()
    {
        StopHotfix();
        Dispose();
        InitLuaEnv();

        // 清理资源管理模块
        yield return AssetBundleMgr.Instance.Cleanup();

        // 重新启动资源管理模块
        DateTime start = DateTime.Now;
        yield return AssetBundleMgr.Instance.Initialize();
        Logger.Log(string.Format("AssetBundleMgr Restart Initialize use {0}ms", (DateTime.Now - start).Milliseconds));

        // 重新加载lua
        yield return InitLuaAB();

        // 启动xlua热修复模块
        start = DateTime.Now;
        OnInit();
        StartHotfix();
        Logger.Log(string.Format("XLuaManager StartHotfix use {0}ms", (DateTime.Now - start).Milliseconds));

        StartGame();
    }

    public void SafeDoString(string scriptContent)
    {
        if (luaEnv != null)
        {
            try
            {
                luaEnv.DoString(scriptContent);
            }
            catch (System.Exception ex)
            {
                string msg = string.Format("xLua exception : {0}\n {1}", ex.Message, ex.StackTrace);
                Logger.LogError(msg, null);
            }
        }
    }

    public void StartHotfix(bool restart = false)
    {
        if (luaEnv == null)
        {
            return;
        }

        if (restart)
        {
            StopHotfix();
            ReloadScript(hotfixMainScriptName);
        }
        else
        {
            LoadScript(hotfixMainScriptName);
        }
        SafeDoString("HotfixMain.Start()");
    }

    public void StopHotfix()
    {
        SafeDoString("HotfixMain.Stop()");
    }

    public void StartGame()
    {
        Logger.Log("XluaManager StartGame");
        if (luaEnv != null)
        {
            Logger.Log("XluaManager StartGame luaEnv is right");
            LoadScript(gameMainScriptName);
            SafeDoString("GameMain.StartUpdater()");
            HasGameStart = true;
        }
        else
        {
            Logger.Log("XluaManager StartGame luaEnv is null");
        }
    }
    
    public void ReloadScript(string scriptName)
    {
        SafeDoString(string.Format("package.loaded['{0}'] = nil", scriptName));
        LoadScript(scriptName);
    }

    void LoadScript(string scriptName)
    {
        SafeDoString(string.Format("require('{0}')", scriptName));
    }

    public static byte[] CustomLoader(ref string filepath)
    {
        string scriptPath = string.Empty;
        filepath = filepath.Replace(".", "/") + ".lua";
        
#if UNITY_EDITOR
        if (AssetBundleConfig.IsEditorMode)
        {
            scriptPath = Path.Combine(Application.dataPath, luaScriptsFolder);
            scriptPath = Path.Combine(scriptPath, filepath);
            //Logger.Log("Load lua script : " + scriptPath);
            return GameUtility.SafeReadAllBytes(scriptPath);
        }
#endif

        scriptPath = string.Format("{0}/{1}.bytes", luaAssetbundleAssetName, filepath);


        string assetbundleName = null;
        string assetName = null;
        bool status = AssetBundleMgr.Instance.MapAssetPath(scriptPath, out assetbundleName, out assetName);
        if (!status)
        {
            Logger.LogError("MapAssetPath failed : " + scriptPath);
            return null;
        }

        var asset = AssetBundleMgr.Instance.GetAssetCache(assetName) as TextAsset;
        if (asset != null)
        {
            if (signAndDecode)
            {
                byte[] ret = (byte[])(asset.bytes).Clone();
                //Debug.Log(ret.Length + " -- " + scriptPath + ":" + Encoding.UTF8.GetString(ret));
                LuaAPI.xluaL_decode_encbuffer(ret, ret.Length);
                //Debug.Log(scriptPath + ":" + Encoding.UTF8.GetString(ret));
                return ret;
            }

            byte[] s = asset.bytes;

            //Debug.Log("--------- script path " + scriptPath + " , " + assetName + " : " + s.Length);

            return s;
        }
        Logger.LogError("Load lua script failed : " + scriptPath + ", You should preload lua assetbundle first!!!");
        return null;
    }

    private void Update()
    {
        if (luaEnv != null)
        {
            luaEnv.Tick();

            if (Time.frameCount % 100 == 0)
            {
                //luaEnv.FullGc();    // 这个频率做一次完整gc是不合适的  todo
                luaEnv.GcStep(300);
            }
        }
        if (isRestart)
        {
            StartCoroutine(CoroutineRestart());
            isRestart = false;
        }
    }

    private void OnLevelWasLoaded()
    {
        if (luaEnv != null && HasGameStart)
        {
            SafeDoString("GameMain.OnLevelWasLoaded()");
        }
    }

    private void OnApplicationQuit()
    {
        if (luaEnv != null && HasGameStart)
        {
            SafeDoString("GameMain.OnApplicationQuit()");
        }
    }

    private void OnApplicationPause(bool isPause)
    {
        if (luaEnv != null && HasGameStart)
        {
            if (isPause)
            {
                SafeDoString("GameMain.OnApplicationPause(true)");
            }
            else
            {
                SafeDoString("GameMain.OnApplicationPause(false)");
            }
        }
    }

    public override void Dispose()
    {
        if (luaUpdater != null)
        {
            luaUpdater.OnDispose();
        }
        SDKHelper.Instance.Dispose();
        if (luaEnv != null)
        {
            try
            {
                luaEnv.Dispose();
                luaEnv = null;
            }
            catch (System.Exception ex)
            {
                string msg = string.Format("xLua exception : {0}\n {1}", ex.Message, ex.StackTrace);
                Logger.LogError(msg, null);
            }
        }
    }
}
