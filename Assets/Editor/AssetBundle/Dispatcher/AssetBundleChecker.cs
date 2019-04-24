using UnityEngine;
using System.IO;
using UnityEditor;
using System.Collections.Generic;

/// <summary>
/// added by wsh @ 2018.01.03
/// 说明：Assetbundle检测器，由于Unity中的AssetBundle名字标签很不好管理，这里做一层检测以防漏
/// 注意：
/// 1、每个Assetbundle对应配置一个Checker，Checker对应的PackagePath及为Assetbundle所在路径
/// 2、每个Checker可以检测多个目录或者文件，这些目录或者文件被打入一个Assetbundle包
/// TODO：
/// 1、提供自动化的Checker，每次检测到有Asset变动（移动、新增、删除）时自动Check
/// 2、提供一套可视化编辑界面，将Checker配置化并展示到Inspector，从而新增/删除Checker不需要写代码
/// 3、支持Variant
/// </summary>

namespace AssetBundles
{
    public class AssetBundleCheckerFilter
    {
        public string RelativePath;
        public string ObjectFilter;
        
        public AssetBundleCheckerFilter(string relativePath, string objectFilter)
        {
            RelativePath = relativePath;
            ObjectFilter = objectFilter;
        }
    }

    public class AssetBundleCheckerConfig
    {
        public string PackagePath = string.Empty;
        public List<AssetBundleCheckerFilter> CheckerFilters = null;
        public string RootPath = string.Empty;
        public bool CheckUpdateAtStart = true;
        public List<string> CheckUpdateFilters = new List<string>();
        public List<string> excludeFromAPKFiters = new List<string>();
        public ABCheckUpdateFilterType CheckUpdateFilterType = ABCheckUpdateFilterType.Include;
    }

    public class AssetBundleChecker
    {
        string assetsPath;
        string assetsRootPath;
        bool isCreateChannelFile;
        AssetBundleImporter importer;
        AssetBundleCheckerConfig config;

        public AssetBundleChecker(AssetBundleCheckerConfig config)
        {
            this.config = config;
            isCreateChannelFile = false;
            assetsPath = AssetBundleUtility.PackagePathToAssetsPath(config.PackagePath);
            assetsRootPath = AssetBundleUtility.PackagePathToAssetsPath(config.RootPath);
            importer = AssetBundleImporter.GetAtPath(assetsPath);
        }

        public void CheckAssetBundleName()
        {
            if (importer == null)
            {
                Debug.LogError("CheckAssetBundleName failed no importer " + assetsPath);
            }
            if (!importer.IsValid)
            {
                return;
            }

            var checkerFilters = config.CheckerFilters;
            if (checkerFilters == null || checkerFilters.Count == 0)
            {
                isCreateChannelFile = true;
                importer.assetBundleName = config.PackagePath;
                CheckStartUpdate(assetsPath, importer.assetPath);
                return;
            }

            foreach (var checkerFilter in checkerFilters)
            {
                var relativePath = assetsPath;
                if (!string.IsNullOrEmpty(checkerFilter.RelativePath))
                {
                    relativePath = Path.Combine(assetsPath, checkerFilter.RelativePath);
                }
                var imp = AssetBundleImporter.GetAtPath(relativePath);
                if (imp == null)
                {
                    continue;
                }
                if (imp.IsFile)
                {
                    string assetGuid = AssetDatabase.AssetPathToGUID(relativePath);
                    string folderPath = relativePath.Substring(0, relativePath.LastIndexOf('/'));
                    string[] guids = AssetDatabase.FindAssets(checkerFilter.ObjectFilter, new string[] { folderPath });
                    foreach (var guid in guids)
                    {
                        if (assetGuid == guid)
                        {
                            isCreateChannelFile = true;
                            importer.assetBundleName = config.PackagePath;
                            CheckStartUpdate(assetsPath, importer.assetPath);
                        }
                    }
                }
                else
                {
                    string[] objGuids = AssetDatabase.FindAssets(checkerFilter.ObjectFilter, new string[] { relativePath });
                    foreach (var guid in objGuids)
                    {
                        var path = AssetDatabase.GUIDToAssetPath(guid);
                        imp = AssetBundleImporter.GetAtPath(path);
                        isCreateChannelFile = true;
                        imp.assetBundleName = config.PackagePath;
                        CheckStartUpdate(assetsPath, importer.assetPath);
                    }
                }
            }
        }

        private void CheckStartUpdate(string fullAssetName, string abAssetName)
        {
            if (CheckAssetBundles.IsContainAB(fullAssetName) || CheckAssetBundles.IsContainABInExcludeList(fullAssetName))
            {
                return;
            }

            if (config.CheckUpdateAtStart)
            {
                List<string> checkUpdateFilters = config.CheckUpdateFilters;
                if (checkUpdateFilters == null || checkUpdateFilters.Count == 0) // 不设置过滤条件，全部检查更新
                {
                    CheckExcludeFromAPK(fullAssetName, abAssetName, config.excludeFromAPKFiters);
                    return;
                }

                bool dontCheckUpdateForInclude = true;
                bool dontCheckUpdateForExclude = false;
                for (int i = 0; i < checkUpdateFilters.Count; i++)
                {
                    string relativePath = checkUpdateFilters[i];
                    if (string.IsNullOrEmpty(relativePath))
                    {
                        continue;
                    }

                    string filterPath = assetsRootPath + "/" + relativePath;
                    if (config.CheckUpdateFilterType == ABCheckUpdateFilterType.Include)
                    {
                        if (abAssetName.Contains(filterPath))
                        {
                            dontCheckUpdateForInclude = false;
                            break;
                        }
                    }
                    else if (config.CheckUpdateFilterType == ABCheckUpdateFilterType.Exclude)
                    {
                        if (abAssetName.Contains(filterPath))
                        {
                            dontCheckUpdateForExclude = true;
                            dontCheckUpdateForInclude = false;
                            break;
                        }
                    }
                }

                if (dontCheckUpdateForInclude || dontCheckUpdateForExclude)
                {
                    CheckAssetBundles.AddDontCheckUpdateAB(fullAssetName);
                }
                else
                {
                    CheckExcludeFromAPK(fullAssetName, abAssetName, config.excludeFromAPKFiters);
                }
            }
            else // 启动时不需要检查更新
            {
                CheckAssetBundles.AddDontCheckUpdateAB(fullAssetName);
            }
        }

        public bool IsCreateChannelFile
        { 
            get
            {
                if (assetsPath.EndsWith(".unity")) // 打包场景文件时不创建
                {
                    return false;
                }
                return isCreateChannelFile;
            }
        }

        public void CheckChannelName()
        {
            if (IsCreateChannelFile)
            {
                string channelAssetPath = Path.Combine(AssetBundleConfig.ChannelFolderName, config.PackagePath);
                channelAssetPath = AssetBundleUtility.PackagePathToAssetsPath(channelAssetPath) + ".bytes";
                if (!File.Exists(channelAssetPath))
                {
                    GameUtility.SafeWriteAllText(channelAssetPath, "None");
                    AssetDatabase.Refresh();
                }

                var imp = AssetBundleImporter.GetAtPath(channelAssetPath);
                imp.assetBundleName = config.PackagePath;
            }
        }

        public static void Run(AssetBundleCheckerConfig config)
        {
            var checker = new AssetBundleChecker(config);
            checker.CheckAssetBundleName();
            checker.CheckChannelName();
            AssetDatabase.Refresh();
        }

        private void CheckExcludeFromAPK(string fullAssetName, string abAssetName, List<string> excludeFromAPKFiters)
        {
            if (excludeFromAPKFiters == null || excludeFromAPKFiters.Count == 0) // 不设置过滤条件，全部放到首包内
            {
                return;
            }

            for (int i = 0; i < excludeFromAPKFiters.Count; i++)
            {
                string relativePath = excludeFromAPKFiters[i];
                if (string.IsNullOrEmpty(relativePath))
                {
                    continue;
                }

                string filterPath = assetsRootPath + "/" + relativePath;
                if (abAssetName.Contains(filterPath))
                {
                    CheckAssetBundles.AddABToExcludeList(fullAssetName);
                    return;
                }
            }
        }
    }
}
