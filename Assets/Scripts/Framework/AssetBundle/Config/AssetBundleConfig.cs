using UnityEngine;
using UnityEditor;
using System.IO;
using XLua;

/// <summary>
/// added by wsh @ 2017.12.25
/// 注意：
/// 1、所有ab路径中目录、文件名不能以下划线打头，否则出包时StreamingAssets中的资源不能打到真机上，很坑爹
/// </summary>

namespace AssetBundles
{
    [Hotfix]
    [LuaCallCSharp]
    public class AssetBundleConfig
    {
        public const string localSvrAppPath = "Editor/AssetBundle/LocalServer/AssetBundleServer.exe";
        public const string AssetBundlesFolderName = "AssetBundles";
        public const string AssetBundleSuffix = ".assetbundle";
        public const string AssetsFolderName = "AssetsPackage";
        public const string AssetsFolderPrefix = "Assets/AssetsPackage/";
        public const string ChannelFolderName = "Channel";
        public const string AssetsPathMapFileName = "AssetsMap.bytes";
        public const string VariantsMapFileName = "VariantsMap.bytes";
        public const string AssetBundleServerUrlFileName = "AssetBundleServerUrl.txt";
        public const string VariantMapParttren = "Variant";
        public const string CommonMapPattren = ",";
        public const string EditorModeFileName = "EditorMode.bytes";
        public const string SimulateModeFileName = "SimulateMode.bytes";
        public const string ABUpdateFileName = "ABUpdateMap.bytes";
        public const string ExcludeFormApkFileName = "ExcludeFormApk.bytes";
        public const string AssetBundlesVersionFileName = "assetbundle_version.bytes";

        public static string AssetBundlesBuildOutputPath
        {
            get
            {
                string outputPath = Path.Combine(System.Environment.CurrentDirectory, AssetBundlesFolderName);
                GameUtility.CheckDirAndCreateWhenNeeded(outputPath);
                return outputPath;
            }
        }

        public static string LocalSvrAppPath
        {
            get
            {
                return Path.Combine(Application.dataPath, localSvrAppPath);
            }
        }

        public static string LocalSvrAppWorkPath
        {
            get
            {
                return AssetBundlesBuildOutputPath;
            }
        }

        private static int mIsEditorMode = -1;
        private static int mIsSimulateMode = -1;

        public static bool IsEditorMode
        {
            get
            {
                if (mIsEditorMode == -1)
                {
                    string editorFileName = AssetBundleUtility.GetStreamingAssetsDataPath(EditorModeFileName);
                    string kIsEditorMode = GameUtility.SafeReadAllText(editorFileName);
                    if (kIsEditorMode == null)
                    {
                        GameUtility.SafeWriteAllText(editorFileName, "0");
                        mIsEditorMode = 0;
                    }
                    else
                    {
                        mIsEditorMode = kIsEditorMode == "1" ? 1 : 0;
                    }
                }

                return mIsEditorMode != 0;
            }
            set
            {
                int newValue = value ? 1 : 0;
                if (newValue != mIsEditorMode)
                {
                    mIsEditorMode = newValue;
                    string editorFileName = AssetBundleUtility.GetStreamingAssetsDataPath(EditorModeFileName);
                    GameUtility.SafeWriteAllText(editorFileName, newValue.ToString());

                    if (value)
                    {
                        IsSimulateMode = false;
                    }
                }
            }
        }

        public static bool IsSimulateMode
        {
            get
            {
                if (mIsSimulateMode == -1)
                {
                    string simulateFileName = AssetBundleUtility.GetStreamingAssetsDataPath(SimulateModeFileName);
                    string kIsSimulateMode = GameUtility.SafeReadAllText(simulateFileName);
                    if (kIsSimulateMode == null)
                    {
                        GameUtility.SafeWriteAllText(simulateFileName, "1");
                        mIsSimulateMode = 1;
                    }
                    else
                    {
                        mIsSimulateMode = kIsSimulateMode == "1" ? 1 : 0;
                    }
                }

                return mIsSimulateMode != 0;
            }
            set
            {
                int newValue = value ? 1 : 0;
                if (newValue != mIsSimulateMode)
                {
                    mIsSimulateMode = newValue;
                    string simulateFileName = AssetBundleUtility.GetStreamingAssetsDataPath(SimulateModeFileName);
                    GameUtility.SafeWriteAllText(simulateFileName, newValue.ToString());

                    if (value)
                    {
                        IsEditorMode = false;
                    }
                }
            }
        }
    }
}