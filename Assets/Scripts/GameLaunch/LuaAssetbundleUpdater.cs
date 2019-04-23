using UnityEngine;
using UnityEngine.UI;
using System.Collections;
using System.Collections.Generic;
using AssetBundles;
using XLua;
using System;

/// <summary>
/// added by wsh @ 2017.12.29
/// 功能：Assetbundle更新器
/// </summary>

[Hotfix]
[LuaCallCSharp]
public class LuaAssetbundleUpdater : MonoBehaviour
{
    private string clientResVersion = string.Empty;
    private bool needDownloadLua = false;
    private string downloadUrl = string.Empty;
    private int startupConnectTimes = 0; //启动地址三次切换
    private string m_streamingAppVersion = string.Empty;
    private string m_packageName = string.Empty;
    private string m_noticeVersion = string.Empty;
    private string m_startupUrl = string.Empty;

    public string START_UP_URL
    {
        get
        {
            if (startupConnectTimes > 9)
            {
                startupConnectTimes = 0;
            }
            else if (startupConnectTimes > 6)
            {
                if (string.IsNullOrEmpty(m_startupUrl))
                {
                    startupConnectTimes = 0;
                }
            }

            startupConnectTimes++;
            if (startupConnectTimes <= 3)
            {
                return "https://nylws.haoxingame.com/startup";
            }
            else if (startupConnectTimes <= 6)
            {
                return "https://nylws2.haoxingame.com/startup";
            }
            else
            {
                return m_startupUrl;
            }
        }
    }

    void Start ()
    {
        Text statusText = transform.Find("ContentRoot/LoadingDesc").GetComponent<Text>();
        statusText.text = "正在准备资源...";
    }

    public void StartCheckUpdate(string packageName, string streamingAppVersion)
    {
        m_packageName = packageName;
        m_streamingAppVersion = streamingAppVersion;
        StartCoroutine(CheckUpdateOrDownloadGame());
    }

    IEnumerator CheckUpdateOrDownloadGame()
    {
#if UNITY_EDITOR
        // EditorMode总是跳过资源更新
        if (AssetBundleConfig.IsEditorMode)
        {
            yield return StartGame();
            yield break;
        }
#endif
        yield return null;
        
        var start = DateTime.Now;
        yield return InitLocalVersion();
        Logger.Log(string.Format("InitLocalVersion use {0}ms", (DateTime.Now - start).Milliseconds));

        if (IsInternalVersion())
        {
            yield return InternalGetUrlList();
        }
        else
        {
            // 外部版本检查lua更新
            yield return GetUrlList();
        }

        if (needDownloadLua)
        {
            yield return CheckGameUpdate();
        }
        else
        {
            yield return StartGame();
        }

        yield break;
    }

    private bool IsInternalVersion()
    {
        return m_packageName == "TEST" || m_packageName == "TESTIOS";
    }

    IEnumerator InitLocalVersion()
    {
        var resVersionRequest = AssetBundleMgr.Instance.RequestAssetFileAsync(BuildUtils.ResVersionFileName);
        yield return resVersionRequest;
        var streamingResVersion = resVersionRequest.text;
        resVersionRequest.Dispose();

        string resVersionPath = AssetBundleUtility.GetPersistentDataPath(BuildUtils.ResVersionFileName);
        var persistentResVersion = GameUtility.SafeReadAllText(resVersionPath);
        string startupUrlPath = AssetBundleUtility.GetPersistentDataPath(BuildUtils.StartUpFileName);
        m_startupUrl = GameUtility.SafeReadAllText(startupUrlPath);
        
        if (string.IsNullOrEmpty(persistentResVersion))
        {
            clientResVersion = streamingResVersion;
        }
        else
        {
            clientResVersion = BuildUtils.CheckIsNewVersion(streamingResVersion, persistentResVersion) ? persistentResVersion : streamingResVersion;
        }

        string noticeVersionPath = AssetBundleUtility.GetPersistentDataPath(BuildUtils.NoticeVersionFileName);
        var persistentNoticeVersion = GameUtility.SafeReadAllText(noticeVersionPath);
        if (!string.IsNullOrEmpty(persistentNoticeVersion))
        {
            m_noticeVersion = persistentNoticeVersion;
        }
        else
        {
            m_noticeVersion = "1.0.0";
        }
        Logger.Log(string.Format("streamingResVersion = {0}, persistentResVersion = {1}, persistentNoticeVersion = {2}", streamingResVersion, persistentResVersion, persistentNoticeVersion));
        yield break;
    }

    IEnumerator InternalGetUrlList()
    {
        needDownloadLua = true;
        var resUrlRequest = AssetBundleMgr.Instance.RequestAssetFileAsync(AssetBundleConfig.AssetBundleServerUrlFileName);
        yield return resUrlRequest;
        downloadUrl = resUrlRequest.text;
        AssetBundleMgr.Instance.DownloadUrl = downloadUrl;
        resUrlRequest.Dispose();
        yield break;
    }

    IEnumerator GetUrlList()
    {
        var platform = string.Format("package={0}&app_version={1}&res_version={2}&notice_version={3}", m_packageName, m_streamingAppVersion, clientResVersion, m_noticeVersion);

        bool GetUrlListComplete = false;
        bool isFail = false;

        Dictionary<string, object> urlList = null;
        SimpleHttp.HttpPost(START_UP_URL, null, DataUtils.StringToBytes(platform), (WWW wwwInfo) => {
            if (wwwInfo == null || !string.IsNullOrEmpty(wwwInfo.error) || wwwInfo.bytes == null || wwwInfo.bytes.Length == 0)
            {
                Logger.LogError("Get url list for platform {0} with err : {1}", platform, wwwInfo == null ? "www null" : (!string.IsNullOrEmpty(wwwInfo.error) ? wwwInfo.error : "bytes length 0"));
                isFail = true;
            }
            else
            {
                urlList = (Dictionary<string, object>)MiniJSON.Json.Deserialize(DataUtils.BytesToString(wwwInfo.bytes));
            }
            GetUrlListComplete = true;
        });

        yield return new WaitUntil(() =>
        {
            return GetUrlListComplete;
        });

        if (isFail)
        {
            yield return GetUrlList();
        }
        else
        {
            Logger.Log("Get url list success");
            if (urlList.ContainsKey("need_download_lua"))
            {
                string need_download_lua = urlList["need_download_lua"].ToString();
                if (string.IsNullOrEmpty(need_download_lua))
                {
                    needDownloadLua = false;
                }
                else
                {
                    needDownloadLua = need_download_lua == "1" ? true : false;
                }
            }
            if (urlList.ContainsKey("lua_ab_url") && !string.IsNullOrEmpty(urlList["lua_ab_url"].ToString()))
            {
                downloadUrl = urlList["lua_ab_url"].ToString();
                AssetBundleMgr.Instance.DownloadUrl = downloadUrl + "/";
            }

#if UNITY_CLIENT || LOGGER_ON
            System.Text.StringBuilder sb = new System.Text.StringBuilder();
            sb.AppendFormat("needDownloadLua = {0}\n", needDownloadLua);
            sb.AppendFormat("downloadUrl = {0}\n", downloadUrl);
            Logger.Log(sb.ToString());
#endif
            yield break;
        }
    }

    IEnumerator CheckGameUpdate()
    {
        // 检测资源更新
        Logger.Log("lua download url : " + downloadUrl);
        if (string.IsNullOrEmpty(downloadUrl))
        {
            Logger.Log("lua downloadUrl is null");
            yield break;
        }

        DateTime start = DateTime.Now;
        yield return StartUpdate();
        Logger.Log(string.Format("Update use {0}ms", (DateTime.Now - start).Milliseconds));

        XLuaManager.Instance.Restart();

        yield break;
    }

    IEnumerator StartUpdate()
    {
        AssetBundleHelper.ClearAllCachedVersions(BuildUtils.AssetsMapFileName);
        var mapAssetLoader = AssetBundleMgr.Instance.DownloadAssetBundleAsync(BuildUtils.AssetsMapFileName);
        yield return mapAssetLoader;
        if (mapAssetLoader.error != null)
        {
            UINoticeTip.Instance.ShowOneButtonTip("网络错误", "游戏更新失败，请确认网络已经连接！", "重试", null);
            yield return UINoticeTip.Instance.WaitForResponse();
            yield return StartUpdate();
        }
        mapAssetLoader.Dispose();

        var request = AssetBundleMgr.Instance.DownloadAssetBundleAsync(BuildUtils.LuaABFileName);
        yield return request;
        if (request.error != null || request.bytes == null || request.bytes.Length == 0)
        {
            UINoticeTip.Instance.ShowOneButtonTip("网络错误", "游戏更新失败，请确认网络已经连接！", "重试", null);
            yield return UINoticeTip.Instance.WaitForResponse();
            yield return StartUpdate();
        }
        else
        {
            var filePath = AssetBundleUtility.GetPersistentDataPath(request.assetbundleName);
            GameUtility.SafeWriteAllBytes(filePath, request.bytes);
        }
        request.Dispose();

        yield break;
    }

    IEnumerator StartGame()
    {
        TestHotfix();
        AssetBundleMgr.Instance.TestHotfix();
        DateTime start = DateTime.Now;
        XLuaManager.Instance.StartGame();
        Logger.Log(string.Format("XLuaManager StartGame use {0}ms", (DateTime.Now - start).Milliseconds));
        CustomDataStruct.Helper.Startup();
        UINoticeTip.Instance.DestroySelf();
        yield break;
    }

    // Hotfix测试---用于侧测试资源模块的热修复
    public void TestHotfix()
    {
        Logger.Log("********** AssetBundleUpdater : Call TestHotfix in cs...");
    }
}
