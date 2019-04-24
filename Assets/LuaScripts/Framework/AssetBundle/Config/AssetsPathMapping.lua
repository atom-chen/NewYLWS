-- /// <summary>
-- /// added by wsh @ 2017.12.26
-- /// 功能： Assetbundle相关的Asset路径映射解析，每次在构建Assetbunlde完成自动生成，每次有资源更新时需要强行下载一次
-- /// 说明： 映射规则：
-- /// 1）对于Asset：Asset加载路径（相对于Assets文件夹）到Assetbundle名与Asset名的映射
-- /// 2）对于带有Variant的Assetbundle，做通用替换处理
-- /// 注意：Assets路径带文件类型后缀，且区分大小写
-- /// 使用说明：
-- /// 1）asset加载：
-- ///     假定AssetBundleConfig设置为AssetsFolderName = "AssetsPackage"，且：
-- ///         A）assetbundle名称：assetspackage/ui/prefabs/view/uiloading_prefab.assetbundle
-- ///         B）assetbundle中资源：UILoading.prefab
-- ///         C）Assets路径为：Assets/AssetsPackage/UI/Prefabs/View/UILoading.prefab
-- ///     则代码中需要的加载路径为：UI/Prefabs/View/UILoading.prefab
-- /// 2）带variant的Assetbundle资源加载：
-- ///     假定设置为：
-- ///         A）assetbundle名称：assetspackage/ui/prefabs/language，定义在以下两个子路径
-- ///             Assets/AssetsPackage/UI/Prefabs/Language/[Chinese]，variant = chinese
-- ///             Assets/AssetsPackage/UI/Prefabs/Language/[English]，variant = english
-- ///         B）assetbundle中资源：
-- ///             Assets/AssetsPackage/UI/Prefabs/Language/[Chinese]/TestVariant.prefab
-- ///             Assets/AssetsPackage/UI/Prefabs/Language/[English]/TestVariant.prefab
-- ///         C）使用时设置激活的Variant为chinese或者english，则代码中需要的加载路径统一为：
-- ///             Assets/AssetsPackage/UI/Prefabs/TestVariant.prefab===>即variant目录（[Chinese]、[English]）将被忽略，使逻辑层代码不需要关注variant带来的路径差异
-- /// TODO：
-- /// 1、后续看是否有必要全部把路径处理为小写，因为ToLower有GC分配，暂时不做这方面工作
-- /// </summary>
local AssetBundleUtility = CS.AssetBundles.AssetBundleUtility
local table_keyof = table.keyof
local table_insert = table.insert
local ABConfig = ABConfig
local SplitString = CUtil.SplitString

local AssetsPathMapping = BaseClass("AssetsPathMapping")

function AssetsPathMapping:__init()
    self.m_pathLookup = {}
    self.m_assetsLookup = {}
    self.m_assetbundleLookup = {}
    self.m_assetName = ABConfig.PackagePathToAssetsPath(ABConfig.AssetsPathMapFileName)
    self.m_abName = AssetBundleUtility.AssetBundlePathToAssetBundleName(self.m_assetName)
end

function AssetsPathMapping:GetABName()
    return self.m_abName
end

function AssetsPathMapping:GetAssetName()
    return self.m_assetName
end

function AssetsPathMapping:Initialize(content)
    if not content or content == "" then
        Logger.LogError("ResourceNameMap empty!!")
        return
    end

    content = string.gsub(content, "\r\n", "\n")
    local mapList = SplitString(content, '\n')
    for _, map in pairs(mapList) do
        if map and map ~= "" then
            local splitArr = SplitString(map, ABConfig.CommonMapPattren)
            if #splitArr < 2 then
                Logger.LogError("splitArr length < 2 : " .. map)
            else
                local item = {
                    -- 如：ui/prefab/assetbundleupdaterpanel_prefab.assetbundle
                    assetbundleName = splitArr[1],
                    -- 如：UI/Prefab/AssetbundleUpdaterPanel.prefab
                    assetName = splitArr[2],
                }
                self.m_pathLookup[item.assetName] = item

                local assetsList = self.m_assetsLookup[item.assetbundleName]
                if not assetsList then
                    assetsList = {}
                end

                -- if not table_keyof(assetsList, item.assetName) then
                --     table_insert(assetsList, item.assetName)
                -- end

                assetsList[item.assetName] = true

                self.m_assetsLookup[item.assetbundleName] = assetsList
                self.m_assetbundleLookup[item.assetName] = item.assetbundleName
            end
        end
    end
end

function AssetsPathMapping:MapAssetPath(assetPath)
    local item = self.m_pathLookup[assetPath]
    if item then
        return true, item.assetbundleName, item.assetName
    end
    return false
end
        
function AssetsPathMapping:GetAllAssetNames(assetbundleName)
    local allAssets = self.m_assetsLookup[assetbundleName]
    if not allAssets then
        allAssets = {}
    end

    return allAssets
end

function AssetsPathMapping:GetAssetBundleName(assetName)
    return self.m_assetbundleLookup[assetName]
end

return AssetsPathMapping