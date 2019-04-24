ABConfig = {
    AssetsPathMapFileName = "AssetsMap.bytes",
    AssetBundleServerUrlFileName = "AssetBundleServerUrl.txt",
    CommonMapPattren = ",",
    PackageNameFileName = "package_name.bytes",
    ResVersionFileName = "res_version.bytes",
    NoticeVersionFileName = "notice_version.bytes",
    AssetBundlesSizeFileName = "assetbundls_size.bytes",
    UpdateNoticeFileName = "updatenotice.txt",
    AssetsFolderName = "AssetsPackage",
    ABUpdateMapFileName = "ABUpdateMap.bytes",
    AppVersionFileName = "app_version.bytes",
    AssetsMapFileName = "assetsmap_bytesassetsmap_bytes.assetbundle",
    StartUpFileName = "startup_backup.bytes",
    LuaABFileName = "lualua.assetbundle",

    PackagePathToAssetsPath = function (assetPath)
        return "Assets/" .. ABConfig.AssetsFolderName .. "/" .. assetPath
    end,
}