local ABAsyncLoaderClass = require("Framework.AssetBundle.ResourceLoader.ABAsyncLoader")
local ABSyncLoaderClass = require("Framework.AssetBundle.ResourceLoader.ABSyncLoader")
local ABAsyncLoaderEditorClass = require("Framework.AssetBundle.ResourceLoader.ABAsyncLoaderEditor")
local table_insert = table.insert
local table_remove = table.remove

local ABLoaderFactory = BaseClass("ABLoaderFactory", Singleton)

function ABLoaderFactory:__init()
    self.m_pool = {}
    self.m_syncPool = {}
    self.m_seq = 0
    self.m_poolForEditor = {}
end

function ABLoaderFactory:CleanUp()
    self.m_pool = {}
    self.m_syncPool = {}
    self.m_seq = 0
    self.m_poolForEditor = {}
end

function ABLoaderFactory:GetLoader()
    if #self.m_pool > 0 then
        return table_remove(self.m_pool)
    end

    self.m_seq = self.m_seq + 1
    return ABAsyncLoaderClass.New(self.m_seq)
end

function ABLoaderFactory:GetSyncLoader()
    if #self.m_syncPool > 0 then
        return table_remove(self.m_syncPool)
    end

    self.m_seq = self.m_seq + 1
    return ABSyncLoaderClass.New(self.m_seq)
end

function ABLoaderFactory:RecycleLoader(loader)
    table_insert(self.m_pool, loader)
end

function ABLoaderFactory:RecycleSyncLoader(loader)
    table_insert(self.m_syncPool, loader)
end

function ABLoaderFactory:GetEditorLoader()
    if #self.m_poolForEditor > 0 then
        return table_remove(self.m_poolForEditor)
    end

    return ABAsyncLoaderEditorClass.New()
end

function ABLoaderFactory:RecycleEditorLoader(loader)
    table_insert(self.m_poolForEditor, loader)
end

return ABLoaderFactory