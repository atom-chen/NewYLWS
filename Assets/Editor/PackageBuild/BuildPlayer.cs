using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using AssetBundles;
using System;
using System.Text;

public class BuildPlayer : Editor
{
    public const string ApkOutputPath = "vAPK";
    public const string XCodeOutputPath = "vXCode";

    public static void WritePackageNameFile(BuildTarget buildTarget, string platformName)
    {
        var outputPath = PackageUtils.GetBuildPlatformOutputPath(buildTarget, platformName);
        GameUtility.SafeWriteAllText(Path.Combine(outputPath, BuildUtils.PackageNameFileName), platformName);
    }

    public static void WriteUpdateNoticeFile(BuildTarget buildTarget, string platformName)
    {
        var outputPath = PackageUtils.GetBuildPlatformOutputPath(buildTarget, platformName);
        GameUtility.SafeWriteAllText(Path.Combine(outputPath, BuildUtils.UpdateNoticeFileName), "");
    }

    public static void WriteAssetBundleSize(BuildTarget buildTarget, string platformName)
    {
        var outputPath = PackageUtils.GetBuildPlatformOutputPath(buildTarget, platformName);
        var allAssetbundles = GameUtility.GetSpecifyFilesInFolder(outputPath, new string[] { ".assetbundle" });
        StringBuilder sb = new StringBuilder();
        if (allAssetbundles != null && allAssetbundles.Length > 0)
        {
            foreach (var assetbundle in allAssetbundles)
            {
                FileInfo fileInfo = new FileInfo(assetbundle);
                int size = (int)(fileInfo.Length / 1024) + 1;
                var path = assetbundle.Substring(outputPath.Length + 1);
                sb.AppendFormat("{0}{1}{2}\n", GameUtility.FormatToUnityPath(path), AssetBundleConfig.CommonMapPattren, size);
            }
        }
        string content = sb.ToString().Trim();
        GameUtility.SafeWriteAllText(Path.Combine(outputPath, BuildUtils.AssetBundlesSizeFileName), content);
    }

    public static void WriteAssetBundleVersion(BuildTarget buildTarget, string platformName)
    {
        var outputPath = PackageUtils.GetBuildPlatformOutputPath(buildTarget, platformName);
        var allAssetbundles = GameUtility.GetSpecifyFilesInFolder(outputPath, new string[] { ".assetbundle" });
        StringBuilder sb = new StringBuilder();
        if (allAssetbundles != null && allAssetbundles.Length > 0)
        {
            foreach (var assetbundle in allAssetbundles)
            {
                var path = assetbundle.Substring(outputPath.Length + 1);
                sb.AppendFormat("{0}{1}{2}\n", GameUtility.FormatToUnityPath(path), AssetBundleConfig.CommonMapPattren, 1);
            }
        }
        string content = sb.ToString().Trim();
        GameUtility.SafeWriteAllText(Path.Combine(outputPath, AssetBundleConfig.AssetBundlesVersionFileName), content);
    }

    private static void InnerBuildAssetBundles(BuildTarget buildTarget, string platformName, bool writeConfig)
    {
        BuildAssetBundleOptions buildOption = BuildAssetBundleOptions.IgnoreTypeTreeChanges | BuildAssetBundleOptions.DeterministicAssetBundle;
        var outputPath = PackageUtils.GetBuildPlatformOutputPath(buildTarget, platformName);
        AssetBundleManifest manifest = BuildPipeline.BuildAssetBundles(outputPath, buildOption, buildTarget);
        if (manifest != null && writeConfig)
        {
            AssetsPathMappingEditor.BuildPathMapping(manifest);
            VariantMappingEditor.BuildVariantMapping(manifest);
            BuildPipeline.BuildAssetBundles(outputPath, buildOption, buildTarget);
        }
        WritePackageNameFile(buildTarget, platformName);
        WriteAssetBundleSize(buildTarget, platformName);
        WriteUpdateNoticeFile(buildTarget, platformName);
        WriteAssetBundleVersion(buildTarget, platformName);
        CheckAssetBundles.WriteCheckUpdateMappingFile(buildTarget, platformName);
        CheckAssetBundles.WriteExcludeFormAPKFile(buildTarget, platformName);
        AssetDatabase.Refresh();
    }

    public static void BuildAssetBundles(BuildTarget buildTarget, string platformName, bool abCheck = true)
    {
        var start = DateTime.Now;
        CheckAssetBundles.Run(abCheck);
        Debug.Log("Finished CheckAssetBundles.Run! use " + (DateTime.Now - start).TotalSeconds + "s");

        start = DateTime.Now;
        CheckAssetBundles.SwitchChannel(platformName.ToString());
        Debug.Log("Finished CheckAssetBundles.SwitchChannel! use " + (DateTime.Now - start).TotalSeconds + "s");

        start = DateTime.Now;
        InnerBuildAssetBundles(buildTarget, platformName, true);
        Debug.Log("Finished InnerBuildAssetBundles! use " + (DateTime.Now - start).TotalSeconds + "s");

        var targetName = PackageUtils.GetPlatformName(buildTarget);
        Debug.Log(string.Format("Build assetbundles for platform : {0} and channel : {1} done!", targetName, platformName));

        // 这里清掉assetbundle名字和删除channel文件夹可以保持打包后工程没有任何改动，但是会增加打包时间。 先按之前的处理全部提交。
        //CheckAssetBundles.ClearAllAssetBundles();
        //var channelFolderPath = AssetBundleUtility.PackagePathToDataPath(AssetBundleConfig.ChannelFolderName);
        //GameUtility.SafeDeleteDir(channelFolderPath);
        //AssetDatabase.Refresh();

        // IOS测试包资源拷贝，简化IOS上的操作步骤
        if (buildTarget == BuildTarget.iOS && platformName == "TESTIOS")
        {
            PackageUtils.CopyAssetBundlesToLocalServerPath(buildTarget, platformName);
        }
    }

    public static void BuildAssetBundlesForAllChannels(BuildTarget buildTarget)
    {
        var targetName = PackageUtils.GetPlatformName(buildTarget);

        var start = DateTime.Now;
        CheckAssetBundles.Run();
        Debug.Log("Finished CheckAssetBundles.Run! use " + (DateTime.Now - start).TotalSeconds + "s");

        int index = 0;
        double switchChannel = 0;
        double buildAssetbundles = 0;
        foreach (var current in (GAME_PLATFORM[])Enum.GetValues(typeof(GAME_PLATFORM)))
        {
            start = DateTime.Now;
            var platformName = current.ToString();
            CheckAssetBundles.SwitchChannel(platformName);
            switchChannel = (DateTime.Now - start).TotalSeconds;

            start = DateTime.Now;
            InnerBuildAssetBundles(buildTarget, platformName, index == 0);
            buildAssetbundles = (DateTime.Now - start).TotalSeconds;

            index++;
            Debug.Log(string.Format("{0}.Build assetbundles for platform : {1} and channel : {2} done! use time : switchChannel = {3}s , build assetbundls = {4} s", index, targetName, platformName, switchChannel, buildAssetbundles));
        }

        Debug.Log(string.Format("Build assetbundles for platform : {0} for all {1} channels done!", targetName, index));
    }

    public static void BuildAssetBundlesForCurSetting()
    {
        var buildTarget = EditorUserBuildSettings.activeBuildTarget;
        var outputPath = PackageUtils.GetCurBuildSettingOutputPath();
        BuildAssetBundles(buildTarget, outputPath);
    }

    public static void BuildAndroid(string platformName, bool isTest)
    {
        BuildTarget buildTarget = BuildTarget.Android;
        PackageUtils.CopyAssetBundlesToStreamingAssets(buildTarget, platformName);
        if (!isTest)
        {
            CopyAndroidRes(platformName);
            LaunchAssetBundleServer.ClearAssetBundleServerURL();
        }
        else
        {
            LaunchAssetBundleServer.WriteAssetBundleServerURL();
        }

        string buildFolder = Path.Combine(System.Environment.CurrentDirectory, ApkOutputPath);
        GameUtility.CheckDirAndCreateWhenNeeded(buildFolder);
        PlayerSettings.applicationIdentifier = PlatformConfig.GetPackageName(platformName);
        PlayerSettings.productName = PlatformConfig.GetProductName(platformName);

        string savePath = null;
        if (PlatformConfig.IsGooglePlay(platformName))
        {
            savePath = Path.Combine(buildFolder, platformName);
            GameUtility.SafeDeleteDir(savePath);
            BuildPipeline.BuildPlayer(GetBuildScenes(), savePath, buildTarget, BuildOptions.AcceptExternalModificationsToPlayer);
        }
        else
        {
            savePath = Path.Combine(buildFolder, PlatformConfig.GetProductName(platformName) + ".apk");
            BuildPipeline.BuildPlayer(GetBuildScenes(), savePath, buildTarget, BuildOptions.None);
        }
        Debug.Log(string.Format("Build android player for : {0} done! output ：{1}", platformName, savePath));
    }
    
    public static void BuildXCode(string platformName, bool isTest)
    {
        BuildTarget buildTarget = BuildTarget.iOS;
        PackageUtils.CopyAssetBundlesToStreamingAssets(buildTarget, platformName);
        if (!isTest)
        {
            LaunchAssetBundleServer.ClearAssetBundleServerURL();
        }
        else
        {
            LaunchAssetBundleServer.WriteAssetBundleServerURL();
        }

        string buildFolder = Path.Combine(System.Environment.CurrentDirectory, XCodeOutputPath);
        buildFolder = Path.Combine(buildFolder, platformName);
        GameUtility.CheckDirAndCreateWhenNeeded(buildFolder);

        string iconPath = "Assets/Editor/icon/ios/{0}/{1}.png";
        string[] iconSizes = new string[] { "180", "167","152", "144", "120", "114", "76", "72", "57" };
        List<Texture2D> iconList = new List<Texture2D>();
        for (int i = 0; i < iconSizes.Length; i++)
        {
            Texture2D texture = (Texture2D)AssetDatabase.LoadAssetAtPath(string.Format(iconPath, platformName, iconSizes[i]), typeof(Texture2D));
            iconList.Add(texture);
        }
        PlayerSettings.SetIconsForTargetGroup(BuildTargetGroup.iOS, iconList.ToArray());

        //PlatformBase platformBase = PlatformMgr.instance.CreatePlatform(platformName);
        //PlayerSettings.applicationIdentifier = platformBase.GetBundleID();
        //PlayerSettings.productName = platformBase.GetPackageName();
        PackageUtils.CheckAndAddSymbolIfNeeded(buildTarget, platformName);
        BuildPipeline.BuildPlayer(GetBuildScenes(), buildFolder, buildTarget, BuildOptions.None);
    }
	
	static string[] GetBuildScenes()
	{
		List<string> names = new List<string>();
		foreach (EditorBuildSettingsScene e in EditorBuildSettings.scenes)
        {
            if (e != null && e.enabled)
            {
                names.Add(e.path);
            }
        }
        return names.ToArray();
    }


    public static void CopyAndroidRes(string platName)
    {
        platName = platName.ToLower();
        string targetPath = Path.Combine(Application.dataPath, "Plugins/Android");
        GameUtility.SafeClearDir(targetPath);

        string resPath = Path.Combine(Environment.CurrentDirectory, "qudao/UnityCallAndroid/" + platName);

        EditorUtility.DisplayProgressBar("提示", "正在拷贝SDK资源，请稍等", 0f);
        PackageUtils.CopyJavaFolder(resPath + "/assets", targetPath + "/assets");
        EditorUtility.DisplayProgressBar("提示", "正在拷贝SDK资源，请稍等", 0.3f);
        PackageUtils.CopyJavaFolder(resPath + "/libs", targetPath + "/libs");
        EditorUtility.DisplayProgressBar("提示", "正在拷贝SDK资源，请稍等", 0.6f);
        PackageUtils.CopyJavaFolder(resPath + "/src/main/res", targetPath + "/res");
        if (File.Exists(resPath + "/build/libs/UnityCallAndroid.jar"))
        {
            File.Copy(resPath + "/build/libs/UnityCallAndroid.jar", targetPath + "/libs/UnityCallAndroid.jar", true);
        }
        if (File.Exists(resPath + "/src/main/AndroidManifest.xml"))
        {
            File.Copy(resPath + "/src/main/AndroidManifest.xml", targetPath + "/AndroidManifest.xml", true);
        }
        if (File.Exists(resPath + "/icon/icon.png"))
        {
            File.Copy(resPath + "/icon/icon.png", Application.dataPath + "/AssetsPackage/UI/Image/APK/icon.png", true);
        }

        EditorUtility.DisplayProgressBar("提示", "正在拷贝SDK资源，请稍等", 1f);
        EditorUtility.ClearProgressBar();
        AssetDatabase.Refresh();
    }
}
