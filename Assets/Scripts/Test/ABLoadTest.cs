using UnityEngine;
using System.Collections;
using AssetBundles;
using System;
using System.Collections.Generic;

public class ABLoadTest : MonoBehaviour
{
    private GameObject m_wujiangRoot = null;
    private List<BaseAssetAsyncLoader> m_loadList = new List<BaseAssetAsyncLoader>();
    private Queue<int> posQueue = new Queue<int>();
    void Awake()
    {
        Application.targetFrameRate = 30;
        posQueue.Enqueue(2);
        posQueue.Enqueue(1);
        posQueue.Enqueue(0);
        posQueue.Enqueue(-1);
        posQueue.Enqueue(-2);
    }
    IEnumerator Start()
    {
        LoggerHelper.Instance.Startup();
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
        var streamingAppVersion = appVersionRequest.text;
        appVersionRequest.Dispose();

        var appVersionPath = AssetBundleUtility.GetPersistentDataPath(BuildUtils.AppVersionFileName);
        var persistentAppVersion = GameUtility.SafeReadAllText(appVersionPath);
        Logger.Log(string.Format("streamingAppVersion = {0}, persistentAppVersion = {1}", streamingAppVersion, persistentAppVersion));

        // 如果persistent目录版本比streamingAssets目录app版本低，说明是大版本覆盖安装，清理过时的缓存
        if (!string.IsNullOrEmpty(persistentAppVersion) && BuildUtils.CheckIsNewVersion(persistentAppVersion, streamingAppVersion))
        {
            var path = AssetBundleUtility.GetPersistentDataPath();
            GameUtility.SafeDeleteDir(path);
        }
        GameUtility.SafeWriteAllText(appVersionPath, streamingAppVersion);
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
        var packageName = packageNameRequest.text;
        AssetBundleMgr.ManifestBundleName = packageName;
        packageNameRequest.Dispose();
        Logger.Log(string.Format("packageName = {0}", packageName));
        yield break;
    }

    IEnumerator CoLoadShader()
    {
        string abName = "shaders.assetbundle";
        ResourceWebRequester shaderLoader = AssetBundleMgr.Instance.RequestAssetBundleAsync(abName);
        yield return shaderLoader;
        AssetBundle ab = shaderLoader.assetbundle;
        AssetBundleMgr.Instance.AddAssetBundleCache(abName, ab);
        AssetBundleMgr.Instance.AddAssetbundleAssetsCache(abName);
    }

    IEnumerator CoLoadModel(int wujiangID, int x)
    {
        DateTime start = DateTime.Now;

        ResourceWebRequester m1001Loader = AssetBundleMgr.Instance.RequestAssetBundleAsync("models/" + wujiangID + ".assetbundle");
        yield return m1001Loader;
        AssetBundle assetBundle = m1001Loader.assetbundle;
        GameObject goPrefab = assetBundle.LoadAsset("assets/assetspackage/models/" + wujiangID + "/" + wujiangID + "_1.prefab") as GameObject;

        GameObject go = GameObject.Instantiate(goPrefab);
        if (m_wujiangRoot == null)
        {
            m_wujiangRoot = new GameObject("WujiangRoot");
        }
        go.transform.parent = m_wujiangRoot.transform;
        go.transform.localPosition = new Vector3(x, 0, -1);
        Logger.Log(string.Format(wujiangID + " Load wujiangPrefab use {0}ms", (DateTime.Now - start).Milliseconds));
    }

    void OnGUI()
    {
        GUILayout.Space(100);
        if (GUILayout.Button("Create1001", GUILayout.Width(150), GUILayout.Height(60)))
        {
            LoadModel(1001);
            LoadModel(1003);
            LoadModel(1004);
            LoadModel(1042);
            LoadModel(1048);
        }
        GUILayout.Space(100);
        if (GUILayout.Button("UITest", GUILayout.Width(150), GUILayout.Height(60)))
        {
            StartCoroutine(TestUIABLoadOrder());
        }
        GUILayout.Space(100);
        if (GUILayout.Button("LoadShader", GUILayout.Width(150), GUILayout.Height(60)))
        {
            StartCoroutine(CoLoadShader());
        }
        if (GUILayout.Button("ModelTest", GUILayout.Width(150), GUILayout.Height(60)))
        {
            StartCoroutine(CoLoadModel(1001, posQueue.Dequeue()));
            StartCoroutine(CoLoadModel(1003, posQueue.Dequeue()));
            StartCoroutine(CoLoadModel(1004, posQueue.Dequeue()));
            StartCoroutine(CoLoadModel(1042, posQueue.Dequeue()));
            StartCoroutine(CoLoadModel(1048, posQueue.Dequeue()));
        }
    }

    void LoadModel(int wujiangID)
    {
        var start = DateTime.Now;
        string wujiangPath = string.Format("Models/{0}/{0}_1.prefab", wujiangID);
        var loader = AssetBundleMgr.Instance.LoadAssetAsync(wujiangPath, typeof(GameObject));
        m_loadList.Add(loader);
    }

    void Update()
    {
        for (int i = m_loadList.Count - 1; i >= 0; i--)
        {
            if (m_loadList[i].IsDone())
            {
                LoadModelComplete(m_loadList[i].asset as GameObject, posQueue.Dequeue());
                m_loadList[i].Dispose();
                m_loadList.RemoveAt(i);
            }
        }
    }

    void LoadModelComplete(GameObject wujiangPrefab, int x)
    {
        GameObject go = GameObject.Instantiate(wujiangPrefab);
        if (m_wujiangRoot == null)
        {
            m_wujiangRoot = new GameObject("WujiangRoot");
        }
        go.transform.parent = m_wujiangRoot.transform;
        go.transform.localPosition = new Vector3(x, 0, -1);
        //Logger.Log(string.Format(wujiangID + " Load wujiangPrefab use {0}ms", (DateTime.Now - start).Milliseconds));
    }

    IEnumerator TestUIABLoadOrder()
    {
        ResourceWebRequester ty100Loader = AssetBundleMgr.Instance.RequestAssetBundleAsync("ui/image/packaged/common/ty55_png.assetbundle");
        yield return ty100Loader;
        AssetBundle ab = ty100Loader.assetbundle;
        UnityEngine.Object sprite = ab.LoadAsset("assets/assetspackage/ui/image/packaged/common/ty55.png");
        ab.Unload(false);
        ResourceWebRequester ty100Loader1 = AssetBundleMgr.Instance.RequestAssetBundleAsync("ui/image/packaged/common/ty55_png.assetbundle");
        yield return ty100Loader1;
        AssetBundle ab1 = ty100Loader.assetbundle;
         //sprite = ab1.LoadAsset("assets/assetspackage/ui/image/packaged/common/ty55.png");

        ResourceWebRequester uiLoader = AssetBundleMgr.Instance.RequestAssetBundleAsync("ui/prefabs/uitest.assetbundle");
        yield return uiLoader;
        AssetBundle uiAB = uiLoader.assetbundle;

        UnityEngine.Object goPrefab = uiAB.LoadAsset("assets/assetspackage/ui/prefabs/uitest/uitestab.prefab");

        uiAB.Unload(false);
        ab1.Unload(false);

        GameObject go = GameObject.Instantiate(goPrefab as GameObject);
        UnityEngine.UI.Image image = go.transform.Find("backBtn").GetComponent<UnityEngine.UI.Image>();
        Material mat = image.material;
        if (mat != null)
        {
            Shader shader = mat.shader;
            if (shader != null)
            {
                mat.shader = Shader.Find(shader.name);
            }
        }
        GameObject parentGo = GameObject.Find("UIRoot/LuanchLayer");
        go.transform.parent = parentGo.transform;
        go.transform.localScale = Vector3.one;
        go.transform.localPosition = Vector3.zero;

        yield break;
    }

    IEnumerator LoadUI()
    {
        string UIPath = "UI/Prefabs/UITest/UITestAB.prefab";
        var loader = AssetBundleMgr.Instance.LoadAssetAsync(UIPath, typeof(GameObject));
        yield return loader;

        GameObject go = GameObject.Instantiate(loader.asset as GameObject);
        UnityEngine.UI.Image image = go.transform.Find("backBtn").GetComponent<UnityEngine.UI.Image>();
        Material mat = image.material;
        if (mat != null)
        {
            Shader shader = mat.shader;
            if (shader != null)
            {
                Debug.LogError(1111);
                mat.shader = Shader.Find(shader.name);
            }
        }

        GameObject parentGo = GameObject.Find("UIRoot/LuanchLayer");
        go.transform.parent = parentGo.transform;
        go.transform.localScale = Vector3.one;
        go.transform.localPosition = Vector3.zero;

        yield break;
    }
}
