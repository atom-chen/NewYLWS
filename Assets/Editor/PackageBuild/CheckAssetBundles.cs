using UnityEngine;
using System.Collections;
using AssetBundles;
using UnityEditor;
using System.Collections.Generic;

/// <summary>
/// added by wsh @ 2018.01.03
/// 功能：打包前的AB检测工作
/// </summary>

public static class CheckAssetBundles
{
    public static List<string> dontCheckUpdateList = new List<string>();
    public static List<string> excludeFromAPKList = new List<string>();

    public static void SwitchChannel(string platformName)
    {
        var channelFolderPath = AssetBundleUtility.PackagePathToAssetsPath(AssetBundleConfig.ChannelFolderName);
        var guids = AssetDatabase.FindAssets("t:textAsset", new string[] { channelFolderPath });
        foreach (var guid in guids)
        {
            var path = AssetDatabase.GUIDToAssetPath(guid);
            GameUtility.SafeWriteAllText(path, platformName);
        }
        AssetDatabase.Refresh();
    }

    public static void ClearAllAssetBundles()
    {
        var assebundleNames = AssetDatabase.GetAllAssetBundleNames();
        var length = assebundleNames.Length;
        var count = 0;
        foreach (var assetbundleName in assebundleNames)
        {
            count++;
            EditorUtility.DisplayProgressBar("Remove assetbundle name :", assetbundleName, (float)count / length);
            AssetDatabase.RemoveAssetBundleName(assetbundleName, true);
        }
        AssetDatabase.Refresh();
        EditorUtility.ClearProgressBar();

        assebundleNames = AssetDatabase.GetAllAssetBundleNames();
        if (assebundleNames.Length != 0)
        {
            Logger.LogError("Something wrong!!!");
        }
    }

    public static void RunAllCheckers()
    {
        var guids = AssetDatabase.FindAssets("t:AssetBundleDispatcherConfig", new string[] { AssetBundleInspectorUtils.DatabaseRoot });
        var length = guids.Length;
        var count = 0;
        foreach (var guid in guids)
        {
            count++;
            var assetPath = AssetDatabase.GUIDToAssetPath(guid);
            var config = AssetDatabase.LoadAssetAtPath<AssetBundleDispatcherConfig>(assetPath);
            config.Load();
            EditorUtility.DisplayProgressBar("Run checker :", config.PackagePath, (float)count / length);
            AssetBundleDispatcher.Run(config);
        }
        AssetDatabase.Refresh();
        EditorUtility.ClearProgressBar();
    }

    public static void Run(bool abCheck = true)
    {
        XLuaMenu.CopyLuaFilesToAssetsPackage();

        if (abCheck)
        {
            dontCheckUpdateList.Clear();
            excludeFromAPKList.Clear();

            ClearAllAssetBundles();

            RunAllCheckers();
        }
    }

    public static void WriteCheckUpdateMappingFile(BuildTarget buildTarget, string platformName)
    {
        if (dontCheckUpdateList == null || dontCheckUpdateList.Count == 0)
        {
            return;
        }
        dontCheckUpdateList.Sort();

        var outputPath = PackageUtils.GetBuildPlatformOutputPath(buildTarget, platformName);
        if (!GameUtility.SafeWriteAllLines(System.IO.Path.Combine(outputPath, AssetBundleConfig.ABUpdateFileName), dontCheckUpdateList.ToArray()))
        {
            Debug.LogError("BuildCheckUpdateMapping failed!!! try rebuild it again!");
        }
        else
        {
            AssetDatabase.Refresh();
            Debug.Log("BuildCheckUpdateMapping success...");
        }
        AssetDatabase.Refresh();
        dontCheckUpdateList.Clear();
    }

    public static void AddDontCheckUpdateAB(string fullAssetName)
    {
        string abName = AssetBundleUtility.AssetBundlePathToAssetBundleName(fullAssetName);
        dontCheckUpdateList.Add(abName);
    }

    public static bool IsContainAB(string fullAssetName)
    {
        string abName = AssetBundleUtility.AssetBundlePathToAssetBundleName(fullAssetName);
        return dontCheckUpdateList.Contains(abName);
    }


    public static void WriteExcludeFormAPKFile(BuildTarget buildTarget, string platformName)
    {
        if (excludeFromAPKList == null || excludeFromAPKList.Count == 0)
        {
            return;
        }
        excludeFromAPKList.Sort();

        var outputPath = PackageUtils.GetBuildPlatformOutputPath(buildTarget, platformName);
        if (!GameUtility.SafeWriteAllLines(System.IO.Path.Combine(outputPath, AssetBundleConfig.ExcludeFormApkFileName), excludeFromAPKList.ToArray()))
        {
            Debug.LogError("BuildCheckUpdateMapping failed!!! try rebuild it again!");
        }
        else
        {
            AssetDatabase.Refresh();
            Debug.Log("BuildCheckUpdateMapping success...");
        }
        AssetDatabase.Refresh();
        excludeFromAPKList.Clear();
    }

    public static void AddABToExcludeList(string fullAssetName)
    {
        string abName = AssetBundleUtility.AssetBundlePathToAssetBundleName(fullAssetName);
        excludeFromAPKList.Add(abName);
    }

    public static bool IsContainABInExcludeList(string fullAssetName)
    {
        string abName = AssetBundleUtility.AssetBundlePathToAssetBundleName(fullAssetName);
        return excludeFromAPKList.Contains(abName);
    }
}
