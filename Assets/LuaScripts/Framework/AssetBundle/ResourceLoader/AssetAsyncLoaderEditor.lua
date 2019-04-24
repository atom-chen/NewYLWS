local AssetLoaderBase = require("Framework.AssetBundle.ResourceLoader.AssetLoaderBase")
local AssetAsyncLoaderEditor = BaseClass("AssetAsyncLoaderEditor", AssetLoaderBase)

function AssetAsyncLoaderEditor:InitWithAsset(asset, callback)
    self.m_asset = asset
    if callback then callback(self, asset) end
end

function AssetAsyncLoaderEditor:IsDone()
    return true
end

function AssetAsyncLoaderEditor:Progress()
    return 1
end

function AssetAsyncLoaderEditor:Update()

end

function AssetAsyncLoaderEditor:Dispose()
    AssetLoaderFactory:GetInstance():RecycleEditorLoader(self)
end

return AssetAsyncLoaderEditor