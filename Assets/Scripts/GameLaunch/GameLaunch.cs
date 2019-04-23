using UnityEngine;
using System.Collections;
using AssetBundles;
using System;
using XLua;

[Hotfix]
[LuaCallCSharp]
public class GameLaunch : MonoBehaviour
{
    private const string noticeTipPrefabPath = "UI/Prefabs/NoticeTip/UINoticeTip.prefab";
    private GameObject noticeTipPrefab = null;
    private LuaAssetbundleUpdater luaUpdater = null;
    private string m_streamingAppVersion = string.Empty;
    private string m_packageName = string.Empty;

    IEnumerator Start ()
    {
        LoggerHelper.Instance.Startup();
#if UNITY_IPHONE
        UnityEngine.iOS.NotificationServices.RegisterForNotifications(UnityEngine.iOS.NotificationType.Alert | UnityEngine.iOS.NotificationType.Badge | UnityEngine.iOS.NotificationType.Sound);
        UnityEngine.iOS.Device.SetNoBackupFlag(Application.persistentDataPath);
#endif

        // 初始化App版本
        var start = DateTime.Now;
        yield return InitAppVersion();
        Logger.Log(string.Format("InitAppVersion use {0}ms", (DateTime.Now - start).Milliseconds));

        // 初始化包名
        start = DateTime.Now;
        yield return InitPackageName();
        Logger.Log(string.Format("InitPackageName use {0}ms", (DateTime.Now - start).Milliseconds));

        // 启动资源管理模块
        start = DateTime.Now;
        yield return AssetBundleMgr.Instance.Initialize();
        Logger.Log(string.Format("AssetBundleManager Initialize use {0}ms", (DateTime.Now - start).Milliseconds));

        // 启动xlua热修复模块
        start = DateTime.Now;
        XLuaManager.Instance.Startup();
        yield return XLuaManager.Instance.InitLuaAB();
        XLuaManager.Instance.OnInit();
        XLuaManager.Instance.StartHotfix();
        Logger.Log(string.Format("XLuaManager StartHotfix use {0}ms", (DateTime.Now - start).Milliseconds));

        // 初始化UI界面
        yield return InitLaunchPrefab();
        yield return null;
        yield return InitNoticeTipPrefab();
        SDKHelper.Instance.Startup();

        // 开始更新
        if (luaUpdater != null)
        {
            luaUpdater.StartCheckUpdate(m_packageName, m_streamingAppVersion);
        }
        yield break;
	}

    IEnumerator InitAppVersion()
    {
#if UNITY_EDITOR
        if (AssetBundleConfig.IsEditorMode)
        {
            yield break;
        }
#endif
        var appVersionRequest = AssetBundleMgr.Instance.RequestAssetFileAsync(BuildUtils.AppVersionFileName);
        yield return appVersionRequest;
        m_streamingAppVersion = appVersionRequest.text;
        appVersionRequest.Dispose();
        yield break;
    }

    IEnumerator InitPackageName()
    {
#if UNITY_EDITOR
        if (AssetBundleConfig.IsEditorMode)
        {
            yield break;
        }
#endif
        var packageNameRequest = AssetBundleMgr.Instance.RequestAssetFileAsync(BuildUtils.PackageNameFileName);
        yield return packageNameRequest;
        m_packageName = packageNameRequest.text;
        AssetBundleMgr.ManifestBundleName = m_packageName;
        packageNameRequest.Dispose();
        Logger.Log(string.Format("packageName = {0}", m_packageName));
        yield break;
    }

    GameObject InstantiateGameObject(GameObject prefab)
    {
        var start = DateTime.Now;
        GameObject go = GameObject.Instantiate(prefab);
        Logger.Log(string.Format("Instantiate use {0}ms", (DateTime.Now - start).Milliseconds));

        var luanchLayer = GameObject.Find("UIRoot/LuanchLayer");
        go.transform.SetParent(luanchLayer.transform);
        var rectTransform = go.GetComponent<RectTransform>();
        rectTransform.offsetMax = Vector2.zero;
        rectTransform.offsetMin = Vector2.zero;
        rectTransform.localScale = Vector3.one;
        rectTransform.localPosition = Vector3.zero;

        return go;
    }

    IEnumerator InitNoticeTipPrefab()
    {
        var start = DateTime.Now;
        var loader = AssetBundleMgr.Instance.LoadAssetAsync(noticeTipPrefabPath, typeof(GameObject));
        yield return loader;
        noticeTipPrefab = loader.asset as GameObject;
        Logger.Log(string.Format("Load noticeTipPrefab use {0}ms", (DateTime.Now - start).Milliseconds));
        loader.Dispose();
        if (noticeTipPrefab == null)
        {
            Logger.LogError("LoadAssetAsync noticeTipPrefab err : " + noticeTipPrefabPath);
            yield break;
        }
        var go = InstantiateGameObject(noticeTipPrefab);
        UINoticeTip.Instance.UIGameObject = go;
        yield break;
    }

    IEnumerator InitLaunchPrefab()
    {
        var go = GameObject.Find("UIRoot/LuanchLayer/UILoading");
        luaUpdater = go.AddComponent<LuaAssetbundleUpdater>();
        yield break;
    }
}
