local AssetAsyncLoaderClass = require("Framework.AssetBundle.ResourceLoader.AssetAsyncLoader")
local AssetAsyncLoaderEditorClass = require("Framework.AssetBundle.ResourceLoader.AssetAsyncLoaderEditor")
local table_insert = table.insert
local table_remove = table.remove

local AssetLoaderFactory = BaseClass("AssetLoaderFactory", Singleton)

function AssetLoaderFactory:__init()
    self.m_asyncPool = {}
    self.m_seq = 0
    self.m_poolForEditor = {}
end

function AssetLoaderFactory:CleanUp()
    self.m_asyncPool = {}
    self.m_seq = 0
    self.m_poolForEditor = {}
end

function AssetLoaderFactory:GetAsyncLoader()
    if #self.m_asyncPool > 0 then
        return table_remove(self.m_asyncPool)
    end

    self.m_seq = self.m_seq + 1
    return AssetAsyncLoaderClass.New(self.m_seq)
end

function AssetLoaderFactory:RecycleLoader(loader)
    table_insert(self.m_asyncPool, loader)
end

function AssetLoaderFactory:GetEditorLoader()
    if #self.m_poolForEditor > 0 then
        return table_remove(self.m_poolForEditor)
    end

    return AssetAsyncLoaderEditorClass.New()
end

function AssetLoaderFactory:RecycleEditorLoader(loader)
    table_insert(self.m_poolForEditor, loader)
end

return AssetLoaderFactory