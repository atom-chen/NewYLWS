using UnityEngine;
using UnityEditor;

/// <summary>
/// added by wsh @ 2018.01.03
/// 说明：Assetbundle分发器，用于分发、管理某个目录下的各种Checker
/// 注意：
/// 1、一个分发器可以管理多个Checker，但是所有的这些Checker共享一套配置
/// TODO：
/// 1、提供一套可视化编辑界面，将Dispatcher配置化并展示到Inspector
/// </summary>

namespace AssetBundles
{
    public enum AssetBundleDispatcherFilterType
    {
        Root,
        Children,
        ChildrenFoldersOnly,
        ChildrenFilesOnlyTop,
        ChildrenFilesAll,
    }

    public enum ABCheckUpdateFilterType
    {
        Include,
        Exclude,
    }

    public class AssetBundleDispatcher
    {
        string assetsPath;
        AssetBundleImporter importer;
        AssetBundleDispatcherConfig config;

        public AssetBundleDispatcher(AssetBundleDispatcherConfig config)
        {
            this.config = config;
            assetsPath = AssetBundleUtility.PackagePathToAssetsPath(config.PackagePath);
            importer = AssetBundleImporter.GetAtPath(assetsPath);
            if (importer == null)
            {
                Debug.LogError("Asset path err : " + assetsPath + "," + config.PackagePath);
            }
        }

        public void RunCheckers()
        {
            switch (config.Type)
            {
                case AssetBundleDispatcherFilterType.Root:
                    CheckRoot();
                    break;
                case AssetBundleDispatcherFilterType.Children:
                case AssetBundleDispatcherFilterType.ChildrenFoldersOnly:
                case AssetBundleDispatcherFilterType.ChildrenFilesOnlyTop:
                    CheckChildren();
                    break;
                case AssetBundleDispatcherFilterType.ChildrenFilesAll:
                    CheckChildrenFilsAll(importer, new AssetBundleCheckerConfig());
                    break;
            }
        }

        void CheckRoot()
        {
            var checkerConfig = new AssetBundleCheckerConfig();
            checkerConfig.PackagePath = config.PackagePath;
            checkerConfig.CheckerFilters = config.CheckerFilters;
            checkerConfig.RootPath = config.PackagePath;
            checkerConfig.CheckUpdateAtStart = config.checkUpdateAtStart;
            checkerConfig.CheckUpdateFilters = config.checkUpdateFilters;
            checkerConfig.excludeFromAPKFiters = config.excludeFromAPKFiters;
            checkerConfig.CheckUpdateFilterType = config.checkUpdateFilterType;
            AssetBundleChecker.Run(checkerConfig);
        }

        void CheckChildren()
        {
            var childrenImporters = importer.GetChildren();
            var checkerConfig = new AssetBundleCheckerConfig();
            foreach (var childrenImport in childrenImporters)
            {
                if (config.Type == AssetBundleDispatcherFilterType.ChildrenFilesOnlyTop && !childrenImport.IsFile)
                {
                    continue;
                }
                else if (config.Type == AssetBundleDispatcherFilterType.ChildrenFoldersOnly && childrenImport.IsFile)
                {
                    continue;
                }

                checkerConfig.CheckerFilters = config.CheckerFilters;
                checkerConfig.PackagePath = childrenImport.packagePath;
                checkerConfig.RootPath = importer.packagePath;
                checkerConfig.CheckUpdateAtStart = config.checkUpdateAtStart;
                checkerConfig.CheckUpdateFilters = config.checkUpdateFilters;
                checkerConfig.excludeFromAPKFiters = config.excludeFromAPKFiters;
                checkerConfig.CheckUpdateFilterType = config.checkUpdateFilterType;

                AssetBundleChecker.Run(checkerConfig);
            }
        }

        void CheckChildrenFilsAll(AssetBundleImporter abImporter,AssetBundleCheckerConfig checkerConfig)
        {
            var childrenImporters = abImporter.GetChildren();
            foreach (var childrenImport in childrenImporters)
            {
                if (childrenImport.IsFile)
                {
                    checkerConfig.CheckerFilters = config.CheckerFilters;
                    checkerConfig.PackagePath = childrenImport.packagePath;
                    checkerConfig.RootPath = importer.packagePath;
                    checkerConfig.CheckUpdateAtStart = config.checkUpdateAtStart;
                    checkerConfig.CheckUpdateFilters = config.checkUpdateFilters;
                    checkerConfig.excludeFromAPKFiters = config.excludeFromAPKFiters;
                    checkerConfig.CheckUpdateFilterType = config.checkUpdateFilterType;
                    AssetBundleChecker.Run(checkerConfig);
                }
                else
                {
                    CheckChildrenFilsAll(childrenImport, checkerConfig);
                }
            }
        }

        public static void Run(AssetBundleDispatcherConfig config)
        {
            var dispatcher = new AssetBundleDispatcher(config);
            dispatcher.RunCheckers();
            AssetDatabase.Refresh();
        }
    }
}
