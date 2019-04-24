local ABAsyncLoaderBase = require("Framework.AssetBundle.ResourceLoader.ABAsyncLoaderBase")
local ABAsyncLoaderEditor = BaseClass("ABAsyncLoaderEditor", ABAsyncLoaderBase)

function ABAsyncLoaderEditor:Init(assetbundleName)
    self.m_abName = assetbundleName
end

function ABAsyncLoaderEditor:IsDone()
    return true
end

function ABAsyncLoaderEditor:Progress()
    return 1
end

function ABAsyncLoaderEditor:Update()

end

function ABAsyncLoaderEditor:Dispose()
    self.m_abName = nil
    ABLoaderFactory:GetInstance():RecycleEditorLoader(self)
end

return ABAsyncLoaderEditor