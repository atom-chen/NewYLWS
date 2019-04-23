using UnityEngine;
using XLua;
using System.IO;
using System.Text;

/// <summary>
/// added by wsh @ 2017.12.25
/// 功能： Assetbundle相关的通用静态函数，提供运行时，或者Editor中使用到的有关Assetbundle操作和路径处理的函数
/// TODO：
/// 1、做路径处理时是否考虑引入BetterStringBuilder消除GC问题
/// 2、目前所有路径处理不支持variant，后续考虑是否支持
/// </summary>

namespace AssetBundles
{
    [Hotfix]
    [LuaCallCSharp]
    public class AssetBundleUtility
    {
        private static StringBuilder m_stringBuilder = new StringBuilder(128);
        private static string GetPlatformName(RuntimePlatform platform)
        {
            switch (platform)
            {
                case RuntimePlatform.Android:
                    return "Android";
                case RuntimePlatform.IPhonePlayer:
                    return "iOS";
                default:
                    Logger.LogError("Error platform!!!");
                    return null;
            }
        }
       
        public static string GetStreamingAssetsFilePath(string assetPath = null)
        {
#if UNITY_EDITOR
            string outputPath = Path.Combine("file://" + Application.streamingAssetsPath, AssetBundleConfig.AssetBundlesFolderName);
#else
#if UNITY_IPHONE || UNITY_IOS
            string outputPath = Path.Combine("file://" + Application.streamingAssetsPath, AssetBundleConfig.AssetBundlesFolderName);
#elif UNITY_ANDROID
            string outputPath = Path.Combine(Application.streamingAssetsPath, AssetBundleConfig.AssetBundlesFolderName);
#else
            Logger.LogError("Unsupported platform!!!");
#endif
#endif
            if (!string.IsNullOrEmpty(assetPath))
            {
                outputPath = Path.Combine(outputPath, assetPath);
            }
            return outputPath;
        }

        public static string GetStreamingAssetsDataPath(string assetPath = null)
        {
            string outputPath = Path.Combine(Application.streamingAssetsPath, AssetBundleConfig.AssetBundlesFolderName);
            if (!string.IsNullOrEmpty(assetPath))
            {
                outputPath = Path.Combine(outputPath, assetPath);
            }
            return outputPath;
        }

        public static string GetPersistentFilePath(string assetPath = null)
        {
            return "file://" + GetPersistentDataPath(assetPath);
        }

        public static string GetPersistentDataPath(string assetPath = null)
        {
            string outputPath = Path.Combine(Application.persistentDataPath, AssetBundleConfig.AssetBundlesFolderName);
            if (!string.IsNullOrEmpty(assetPath))
            {
                outputPath = Path.Combine(outputPath, assetPath);
            }
#if UNITY_EDITOR
            if (Application.platform == RuntimePlatform.WindowsEditor)
            {
                return GameUtility.FormatToSysFilePath(outputPath);
            }
            else if (Application.platform == RuntimePlatform.OSXEditor)
            {
                return outputPath;
            }
            return outputPath;
#else
            return outputPath;
#endif
        }

        public static bool CheckPersistentFileExsits(string filePath)
        {
            var path = GetPersistentDataPath(filePath);
            return File.Exists(path);
        }

        // 注意：这个路径是给WWW读文件使用的url，如果要直接磁盘写persistentDataPath，使用GetPlatformPersistentDataPath
        public static string GetAssetBundleFileUrl(string filePath)
        {
            if (CheckPersistentFileExsits(filePath))
            {
                return GetPersistentFilePath(filePath);
            }
            else
            {
                return GetStreamingAssetsFilePath(filePath);
            }
        }

        public static string AssetBundlePathToAssetBundleName(string assetPath, bool fixABName = true)
        {
            if (!string.IsNullOrEmpty(assetPath))
            {
                m_stringBuilder.Length = 0;
                m_stringBuilder.Append(assetPath);
                m_stringBuilder.Replace(AssetBundleConfig.AssetsFolderPrefix, "");
                m_stringBuilder.Replace(" ", "");
                m_stringBuilder.Replace(".", "_");
                if (fixABName)
                {
                    string fixSuffix = FinalFixABName(m_stringBuilder.ToString());
                    m_stringBuilder.Append(fixSuffix);
                } 
                m_stringBuilder.Append(AssetBundleConfig.AssetBundleSuffix);
                string abName = m_stringBuilder.ToString();
                m_stringBuilder.Length = 0;
                return abName.ToLower();
            }
            return null;
        }

        public static string FinalFixABName(string path)
        {
            string[] nameList = path.Split('/');
            if (nameList == null || nameList.Length <= 1)
            {
                return path;
            }

            return nameList[nameList.Length - 2];
        }

        public static string PackagePathToAssetsPath(string assetPath)
        {
            return AssetBundleConfig.AssetsFolderPrefix + assetPath;
        }

        public static bool IsPackagePath(string assetPath)
        {
            return assetPath.StartsWith(AssetBundleConfig.AssetsFolderPrefix);
        }
        
        public static string AssetsPathToPackagePath(string assetPath)
        {
            if (assetPath.StartsWith(AssetBundleConfig.AssetsFolderPrefix))
            {
                return assetPath.Substring(AssetBundleConfig.AssetsFolderPrefix.Length);
            }
            else
            {
                Debug.LogError("Asset path is not a package path!");
                return assetPath;
            }
        }

        public static string PackagePathToDataPath(string assetPath)
        {
            return Application.dataPath + "/" + AssetBundleConfig.AssetsFolderName + "/" + assetPath;
        }
    }
}