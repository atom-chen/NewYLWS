-- /// <summary>
-- /// added by wsh @ 2017.12.22
-- /// 功能：Asset异步加载器，自动追踪依赖的ab加载进度
-- /// 说明：一定要所有ab都加载完毕以后再加载asset，所以这里分成两个加载步骤
-- /// </summary>

local AssetLoaderBase = require("Framework.AssetBundle.ResourceLoader.AssetLoaderBase")
local AssetAsyncLoader = BaseClass("AssetAsyncLoader", AssetLoaderBase)

function AssetAsyncLoader:__init(sequence)
    self.m_seq = sequence
    self.m_isOver = false
    self.m_assetbundleLoader = nil
    self.m_callback = nil
end

function AssetAsyncLoader:InitWithAsset(assetName, asset, callback)
    self.m_assetName = assetName
    self.m_asset = asset
    self.m_assetbundleLoader = nil
    self.m_isOver = true
    self.m_callback = callback
    self.m_callback(self, self.m_asset)
end

function AssetAsyncLoader:InitWithABLoader(assetName, loader, callback)
    self.m_assetName = assetName
    self.m_asset = nil
    self.m_isOver = false
    self.m_assetbundleLoader = loader
    self.m_callback = callback
end

function AssetAsyncLoader:GetAssetName()
    return self.m_assetName
end

function AssetAsyncLoader:IsDone()
    return self.m_isOver
end

function AssetAsyncLoader:Progress()
    if self:IsDone() then
        return 1
    end

    return self.m_assetbundleLoader:Progress()
end

function AssetAsyncLoader:Update()
    if self:IsDone() then
        return
    end

    self.m_isOver = self.m_assetbundleLoader:IsDone()
    if not self.m_isOver then
        return
    end

    local abMgr = AssetBundleMgrInst

    local assetPath = ABConfig.PackagePathToAssetsPath(self:GetAssetName())
    local curAssetbundle = abMgr:GetAssetBundleCache(self.m_assetbundleLoader:GetABName())
    if curAssetbundle then
        if not abMgr:IsAssetLoaded(self:GetAssetName()) then
            self.m_asset =  curAssetbundle:LoadAsset(assetPath)
            abMgr:AddAssetCache(self:GetAssetName(), self.m_asset)
        else
            self.m_asset = abMgr:GetAssetCache(self:GetAssetName())
        end
        self.m_callback(self, self.m_asset)
    else
        Logger.LogError("curAssetbundle is nil")
    end
end

function AssetAsyncLoader:Dispose()
    self.m_isOver = true
    self.m_assetName = nil
    self.m_asset = nil
    self.m_assetbundleLoader = nil
    self.m_callback = nil
    AssetLoaderFactory:GetInstance():RecycleLoader(self)
end

return AssetAsyncLoader