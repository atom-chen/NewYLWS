local ResourceLoaderBase = require("Framework.AssetBundle.ResourceLoader.ResourceLoaderBase")
local AssetLoaderBase = BaseClass("AssetLoaderBase", ResourceLoaderBase)

function AssetLoaderBase:__init()
    self.m_asset = nil
end

function AssetLoaderBase:GetAsset()
    return self.m_asset
end

function AssetLoaderBase:Dispose()
    self.m_asset = nil
end

return AssetLoaderBase