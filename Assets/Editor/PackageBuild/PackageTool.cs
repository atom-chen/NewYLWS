using UnityEditor;
using UnityEngine;
using System.IO;
using AssetBundles;
using System;
using System.Collections.Generic;
using System.Text;
using System.Diagnostics;
using System.Text.RegularExpressions;

/// <summary>
/// added by wsh @ 2018.01.03
/// 说明：打包工具
/// TODO：
/// 1、安装打包可以不用区分渠道，没有IOS那样的机器审核难以通过的问题
/// </summary>

public class PackageTool : EditorWindow
{
    private BuildTarget buildTarget = BuildTarget.Android;
    private GAME_PLATFORM platformType = GAME_PLATFORM.TEST;
    private string resVersion = "1.0.0";
    private LocalServerType localServerType = LocalServerType.CurrentMachine;
    private string localServerIP = "127.0.0.1";
    private bool dynamicVersionLuaFinished = false;

    [MenuItem("Tools/Package", false, 0)]
    static void Init() {
        PackageTool packageTool = (PackageTool)EditorWindow.GetWindow(typeof(PackageTool));
        packageTool.buildTarget = EditorUserBuildSettings.activeBuildTarget;
        packageTool.platformType = PackageUtils.GetCurSelectedChannel();
        packageTool.localServerType = PackageUtils.GetLocalServerType();
        packageTool.localServerIP = PackageUtils.GetLocalServerIP();
    }

    void Update()
    {
        if (dynamicVersionLuaFinished)
        {
            dynamicVersionLuaFinished = false;


            AssetDatabase.Refresh();
            EditorUtility.DisplayDialog("Succeed", "DynamicRevision.lua Gen!", "Conform");
        }
    }

    void DrawConfigGUI()
    {
        GUILayout.Space(3);
        GUILayout.Label("-------------[Config]-------------");

        GUILayout.Space(3);
        GUILayout.BeginHorizontal();
        GUILayout.Label("res_version", GUILayout.Width(100));
        resVersion = GUILayout.TextField(resVersion, GUILayout.Width(100));
        GUILayout.EndHorizontal();

        GUILayout.Space(3);
        GUILayout.BeginHorizontal();
        GUILayout.Label("notice_version", GUILayout.Width(100));
        GUILayout.Label("1.0.0", GUILayout.Width(100));
        GUILayout.EndHorizontal();

        GUILayout.Space(3);
        GUILayout.BeginHorizontal();
        GUILayout.Label("app_version", GUILayout.Width(100));
        GUILayout.Label(PlayerSettings.bundleVersion, GUILayout.Width(100));
        GUILayout.EndHorizontal();

        GUILayout.Space(3);
        GUILayout.BeginHorizontal();
        if (GUILayout.Button("Load Current", GUILayout.Width(100)))
        {
            LoadCurrentVersionFile();
        }
        if (GUILayout.Button("Save Current", GUILayout.Width(100)))
        {
            SaveCurrentVersionFile();
        }
        if (GUILayout.Button("Validate All", GUILayout.Width(100)))
        {
            ValidateAllVersionFile();
        }
        if (GUILayout.Button("Save For All", GUILayout.Width(100)))
        {
            SaveAllVersionFile();
        }
        if (GUILayout.Button("Save Dynamic Version", GUILayout.Width(150)))
        {
            GenVersionLuaFile();
        }
        GUILayout.EndHorizontal();
    }

    void DrawLocalServerGUI()
    {
        GUILayout.Space(3);
        GUILayout.Label("-------------[AssetBundles Local Server]-------------");
        GUILayout.Space(3);

        GUILayout.BeginHorizontal();
        var curSelected = (LocalServerType)EditorGUILayout.EnumPopup("Local Server Type : ", localServerType, GUILayout.Width(300));
        bool typeChanged = curSelected != localServerType;
        if (typeChanged)
        {
            PackageUtils.SaveLocalServerType(curSelected);

            localServerType = curSelected;
            localServerIP = PackageUtils.GetLocalServerIP();
        }
        if (localServerType == LocalServerType.CurrentMachine)
        {
            GUILayout.Label(localServerIP);
        }
        else
        {
            localServerIP = GUILayout.TextField(localServerIP, GUILayout.Width(100));
            if (GUILayout.Button("Save", GUILayout.Width(200)))
            {
                PackageUtils.SaveLocalServerIP(localServerIP);
            }
        }
        GUILayout.EndHorizontal();
    }

    void DrawAssetBundlesGUI()
    {
        GUILayout.Space(3);
        GUILayout.Label("-------------[Build AssetBundles]-------------");
        GUILayout.Space(3);

        GUILayout.BeginHorizontal();
        if (GUILayout.Button("Current Channel Only", GUILayout.Width(200)))
        {
            BuildAssetBundlesForCurrentChannel();
        }
        if (GUILayout.Button("For All Channels", GUILayout.Width(200)))
        {
            BuildAssetBundlesForAllChannels();
        }
        if (GUILayout.Button("Open Current Output", GUILayout.Width(200)))
        {
            AssetBundleMenuItems.ToolsToolsOpenOutput();
        }
        if (GUILayout.Button("Copy To StreamingAsset", GUILayout.Width(200)))
        {
            AssetBundleMenuItems.ToolsToolsCopyAssetbundles();
        }
        GUILayout.EndHorizontal();
        GUILayout.BeginHorizontal();
        if (GUILayout.Button("Current Channel Only(fast)", GUILayout.Width(200)))
        {
            BuildAssetBundlesForCurrentChannel(false);
        }
        GUILayout.EndHorizontal();
    }

    void DrawXLuaGUI()
    {
        GUILayout.Space(3);
        GUILayout.Label("-------------[Gen XLua Code]-------------");
        GUILayout.Space(3);

        GUILayout.BeginHorizontal();
        if (GUILayout.Button("Generate Code", GUILayout.Width(200)))
        {
            GenXLuaCode(buildTarget);
        }
        GUILayout.EndHorizontal();
    }

    void DrawBuildAndroidPlayerGUI()
    {
        GUILayout.Space(3);
        GUILayout.Label("-------------[Build Android Player]-------------");
        GUILayout.Space(3);

        GUILayout.BeginHorizontal();
        if (GUILayout.Button("Current Channel Only", GUILayout.Width(200)))
        {
            EditorApplication.delayCall += BuildAndroidPlayerForCurrentChannel;
        }
        if (GUILayout.Button("For All Channels", GUILayout.Width(200)))
        {
            EditorApplication.delayCall += BuildAndroidPlayerForAllChannels;
        }
        if (GUILayout.Button("Open Current Output", GUILayout.Width(200)))
        {
            var folder = Path.Combine(System.Environment.CurrentDirectory, BuildPlayer.ApkOutputPath);
            EditorUtils.ExplorerFolder(folder);
        }

        if (GUILayout.Button("OpenPersistentPath", GUILayout.Width(200)))
        {
            EditorUtils.ExplorerFolder(Application.persistentDataPath);
        }
        GUILayout.EndHorizontal();
    }

    void DrawBuildIOSPlayerGUI()
    {
        GUILayout.Space(3);
        GUILayout.Label("-------------[Build IOS Player]-------------");
        GUILayout.Space(3);
        GUILayout.BeginHorizontal();
        if (GUILayout.Button("Current Channel Only", GUILayout.Width(200)))
        {
            EditorApplication.delayCall += BuildIOSPlayerForCurrentChannel;
        }
        if (GUILayout.Button("For All Channels", GUILayout.Width(200)))
        {
            EditorApplication.delayCall += BuildIOSPlayerForAllChannels;
        }
        if (GUILayout.Button("Open Current Output", GUILayout.Width(200)))
        {
            var folder = Path.Combine(System.Environment.CurrentDirectory, BuildPlayer.XCodeOutputPath);
            EditorUtils.ExplorerFolder(folder);
        }
        GUILayout.EndHorizontal();
    }

    void DrawBuildPlayerGUI()
    {
        if (buildTarget == BuildTarget.Android)
        {
            DrawBuildAndroidPlayerGUI();
        }
        else if (buildTarget == BuildTarget.iOS)
        {
            DrawBuildIOSPlayerGUI();
        }
    }

    void OnGUI()
    {
        GUILayout.BeginVertical();
        GUILayout.Space(10);
        buildTarget = (BuildTarget)EditorGUILayout.EnumPopup("Build Target : ", buildTarget);
        GUILayout.Space(5);
        platformType = (GAME_PLATFORM)EditorGUILayout.EnumPopup("Build Channel : ", platformType);
        GUILayout.EndVertical();

        if (GUI.changed)
        {
            PackageUtils.SaveCurSelectedChannel(platformType);
        }

        DrawConfigGUI();
        DrawLocalServerGUI();
        DrawAssetBundlesGUI();
        DrawXLuaGUI();
        DrawBuildPlayerGUI();
    }

    public string ReadVersionFile(BuildTarget target, GAME_PLATFORM platform)
    {
        string rootPath = PackageUtils.GetBuildPlatformOutputPath(target, platform.ToString());
        return GameUtility.SafeReadAllText(Path.Combine(rootPath, BuildUtils.ResVersionFileName));
    }

    public void SaveVersionFile(BuildTarget target, GAME_PLATFORM platform)
    {
        string rootPath = PackageUtils.GetBuildPlatformOutputPath(target, platform.ToString());
        GameUtility.SafeWriteAllText(Path.Combine(rootPath, BuildUtils.ResVersionFileName), resVersion);
        GameUtility.SafeWriteAllText(Path.Combine(rootPath, BuildUtils.NoticeVersionFileName), resVersion);
        GameUtility.SafeWriteAllText(Path.Combine(rootPath, BuildUtils.AppVersionFileName), PlayerSettings.bundleVersion);  
    }

    public void LoadCurrentVersionFile()
    {
        string readVersion = ReadVersionFile(buildTarget, platformType);
        if (string.IsNullOrEmpty(readVersion))
        {
            var buildTargetName = PackageUtils.GetPlatformName(buildTarget);
            EditorUtility.DisplayDialog("Error", string.Format("No version file  for : \n\nplatform : {0} \nchannel : {1} \n\n", buildTargetName, platformType.ToString()), "Confirm");
        }
        else
        {
            resVersion = readVersion;
            EditorUtility.DisplayDialog("Success", "Load cur version file done!", "Confirm");
        }
    }

    public void SaveCurrentVersionFile()
    {
        SaveVersionFile(buildTarget, platformType);
        EditorUtility.DisplayDialog("Success", "Save version file done!", "Confirm");
    }

    public void ValidateAllVersionFile()
    {
        Dictionary<string, List<GAME_PLATFORM>> versionMap = new Dictionary<string, List<GAME_PLATFORM>>();
        List<GAME_PLATFORM> platformList = null;
        foreach (var current in (GAME_PLATFORM[])Enum.GetValues(typeof(GAME_PLATFORM)))
        {
            string readVersion = ReadVersionFile(buildTarget, current);
            if (readVersion == null)
            {
                readVersion = "";
            }
            versionMap.TryGetValue(readVersion, out platformList);
            if (platformList == null)
            {
                platformList = new List<GAME_PLATFORM>();
            }
            platformList.Add(current);
            versionMap[readVersion] = platformList;
        }

        StringBuilder sb = new StringBuilder();
        foreach (var current in versionMap)
        {
            var version = current.Key;
            var platforms = current.Value;
            sb.AppendFormat("Version : {0}\n", version);
            sb.AppendFormat("{0} Platforms : ", platforms.Count);
            foreach (var platform in platforms)
            {
                sb.AppendFormat("{0}, ", platform.ToString());
            }
            sb.AppendLine("\n-------------------------------------\n");
        }
        EditorUtility.DisplayDialog("Result", sb.ToString(), "Confirm");
    }

    void SaveAllVersionFile()
    {
        foreach (var current in (GAME_PLATFORM[])Enum.GetValues(typeof(GAME_PLATFORM)))
        {
            SaveVersionFile(buildTarget, current);
        }
        EditorUtility.DisplayDialog("Success", "Save all version files done!", "Confirm");
    }
    
    void GenVersionLuaFile()
    {
        int luaRevision = 0;
        int excelRevision = 0;

        string RegexStr = @"^Revision:";


        string excelVerFile = Application.dataPath + "/LuaScripts/Config/Data/configsvninfo.txt";
        File.SetAttributes(excelVerFile, FileAttributes.Normal);
        string[] allLines = File.ReadAllLines(excelVerFile);
        for (int k = 0; k < allLines.Length; k++)
        {
            string aLine = allLines[k];

            if (Regex.IsMatch(aLine, RegexStr))
            {
                string[] ss = aLine.Split(':');
                for (int i = 0; i < ss.Length; i++)
                {
                    int v = 0;
                    if (int.TryParse(ss[i], out v))
                    {
                        //UnityEngine.Debug.Log(string.Format(" excelRevision {0} -------- {1} ", aLine, v));
                        excelRevision = v;
                        break;
                    }
                }

                break;
            }
        }

        string resultPath = Application.dataPath + "/LuaScripts/Global/DynamicRevision.lua";

        Process p = new Process();
        p.StartInfo.FileName = @"svn";
        p.StartInfo.Arguments = "info";
        p.StartInfo.UseShellExecute = false;
        p.StartInfo.RedirectStandardOutput = true;
        p.StartInfo.RedirectStandardInput = true;
        p.StartInfo.RedirectStandardError = true;
        p.StartInfo.CreateNoWindow = true;
        p.StartInfo.WorkingDirectory = Application.dataPath + "/LuaScripts";
        p.Start();
        p.BeginOutputReadLine();
        p.OutputDataReceived += new DataReceivedEventHandler((object sender, DataReceivedEventArgs e) =>
        {
            if (!string.IsNullOrEmpty(e.Data))
            {
                //UnityEngine.Debug.Log(e.Data);

                if (Regex.IsMatch(e.Data, RegexStr))
                {
                    string[] ss = e.Data.Split(':');
                    for (int i = 0; i < ss.Length; i++)
                    {
                        int v = 0;
                        if (int.TryParse(ss[i], out v))
                        {
                            //UnityEngine.Debug.Log(string.Format(" luaRevision {0} -------- {1} ", e.Data, v));
                            luaRevision = v;

                            string luaString = "local tbl = {\nluaRevision = " + luaRevision + ",\nexcelRevision = " + excelRevision + ",\n}\nreturn tbl";
                            UnityEngine.Debug.Log(luaString);

                            GameUtility.SafeWriteAllText(resultPath, luaString);

                            dynamicVersionLuaFinished = true;
                        }
                    }
                }

                Process pr = sender as Process;
                if (pr != null)
                {
                    pr.Close();
                }
            }
        });
    }

    public void BuildAssetBundlesForCurrentChannel(bool abCheck = true)
    {
        var start = DateTime.Now;
        BuildPlayer.BuildAssetBundles(buildTarget, platformType.ToString(), abCheck);

        var buildTargetName = PackageUtils.GetPlatformName(buildTarget);
        EditorUtility.DisplayDialog("Success", string.Format("Build AssetBundles for : \n\nplatform : {0} \nchannel : {1} \n\ndone! use {2}s", buildTargetName, platformType, (DateTime.Now - start).TotalSeconds), "Confirm");
    }

    public void BuildAssetBundlesForAllChannels()
    {
        var start = DateTime.Now;
        BuildPlayer.BuildAssetBundlesForAllChannels(buildTarget);

        var buildTargetName = PackageUtils.GetPlatformName(buildTarget);
        EditorUtility.DisplayDialog("Success", string.Format("Build AssetBundles for : \n\nplatform : {0} \nchannel : all \n\ndone! use {1}s", buildTargetName, (DateTime.Now - start).TotalSeconds), "Confirm");
    }

    public static void GenXLuaCode(BuildTarget buildTarget)
    {
        PackageUtils.CheckAndAddSymbolIfNeeded(buildTarget, "HOTFIX_ENABLE");
        CSObjectWrapEditor.Generator.ClearAll();
        CSObjectWrapEditor.Generator.GenAll();
    }

    public bool CheckSymbolsToCancelBuild()
    {
        var buildTargetGroup = buildTarget == BuildTarget.Android ? BuildTargetGroup.Android : BuildTargetGroup.iOS;
        var symbols = PlayerSettings.GetScriptingDefineSymbolsForGroup(buildTargetGroup);
        var replace = symbols.Replace("HOTFIX_ENABLE", "");
        replace = symbols.Replace(";", "").Trim();
        if (!string.IsNullOrEmpty(replace))
        {
            int checkClear = EditorUtility.DisplayDialogComplex("Build Symbol Warning",
                string.Format("Now symbols : \n\n{0}\n\nClear all symbols except \"HOTFIX_ENABLE\" ?", symbols),
                "Yes", "No", "Cancel");
            if (checkClear == 0)
            {
                PlayerSettings.SetScriptingDefineSymbolsForGroup(buildTargetGroup, "HOTFIX_ENABLE");
            }
            return checkClear == 2;
        }
        return false;
    }

    public void BuildAndroidPlayerForCurrentChannel()
    {
        if (CheckSymbolsToCancelBuild())
        {
            return;
        }

        var start = DateTime.Now;
        BuildPlayer.BuildAndroid(platformType.ToString(), platformType == GAME_PLATFORM.TEST);

        var buildTargetName = PackageUtils.GetPlatformName(buildTarget);
        EditorUtility.DisplayDialog("Success", string.Format("Build player for : \n\nplatform : {0} \nchannel : {1} \n\ndone! use {2}s", buildTargetName, platformType, (DateTime.Now - start).TotalSeconds), "Confirm");
    }

    public void BuildAndroidPlayerForAllChannels()
    {
        if (CheckSymbolsToCancelBuild())
        {
            return;
        }

        var start = DateTime.Now;
        foreach (var current in (GAME_PLATFORM[])Enum.GetValues(typeof(GAME_PLATFORM)))
        {
            BuildPlayer.BuildAndroid(current.ToString(), current == GAME_PLATFORM.TEST);
        }

        var buildTargetName = PackageUtils.GetPlatformName(buildTarget);
        EditorUtility.DisplayDialog("Success", string.Format("Build player for : \n\nplatform : {0} \nchannel : all \n\ndone! use {2}s", buildTargetName, (DateTime.Now - start).TotalSeconds), "Confirm");
    }

    public void BuildIOSPlayerForCurrentChannel()
    {
        if (CheckSymbolsToCancelBuild())
        {
            return;
        }

        var start = DateTime.Now;
        BuildPlayer.BuildXCode(platformType.ToString(), platformType == GAME_PLATFORM.TEST || platformType == GAME_PLATFORM.TESTIOS);

        var buildTargetName = PackageUtils.GetPlatformName(buildTarget);
        EditorUtility.DisplayDialog("Success", string.Format("Build player for : \n\nplatform : {0} \nchannel : {1} \n\ndone! use {2}s", buildTargetName, platformType, (DateTime.Now - start).TotalSeconds), "Confirm");
    }

    public void BuildIOSPlayerForAllChannels()
    {
        if (CheckSymbolsToCancelBuild()) 
        {
            return;
        }

        var start = DateTime.Now;
        foreach (var current in (GAME_PLATFORM[])Enum.GetValues(typeof(GAME_PLATFORM)))
        {
            BuildPlayer.BuildXCode(current.ToString(), platformType == GAME_PLATFORM.TEST || platformType == GAME_PLATFORM.TESTIOS);
        }

        var buildTargetName = PackageUtils.GetPlatformName(buildTarget);
        EditorUtility.DisplayDialog("Success", string.Format("Build player for : \n\nplatform : {0} \nchannel : all \n\ndone! use {2}s", buildTargetName, (DateTime.Now - start).TotalSeconds), "Confirm");
    }
}
