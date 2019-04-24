local ResourceLoaderBase = require("Framework.AssetBundle.ResourceLoader.ResourceLoaderBase")
local ABAsyncLoaderBase = BaseClass("ABAsyncLoaderBase", ResourceLoaderBase)

function ABAsyncLoaderBase:__init()
    self.m_abName = nil
    self.m_assetbundle = nil
end

function ABAsyncLoaderBase:GetABName()
    return self.m_abName
end

function ABAsyncLoaderBase:GetAssetBundle()
    return self.m_assetbundle
end

function ABAsyncLoaderBase:Dispose()
    self.m_abName = nil
    self.m_assetbundle = nil
end

return ABAsyncLoaderBase