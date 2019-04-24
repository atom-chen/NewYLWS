local ResourceAsyncLoaderClass = require("Framework.AssetBundle.ResourceLoader.ResourceAsyncLoader")
local table_insert = table.insert
local table_remove = table.remove

local ResourceAsyncLoaderFactory = BaseClass("ResourceAsyncLoaderFactory", Singleton)

function ResourceAsyncLoaderFactory:__init()
    self.m_pool = {}
    self.m_seq = 0
end

function ResourceAsyncLoaderFactory:CleanUp()
    self.m_pool = {}
    self.m_seq = 0
end

function ResourceAsyncLoaderFactory:GetLoader()
    if #self.m_pool > 0 then
        return table_remove(self.m_pool)
    end

    self.m_seq = self.m_seq + 1
    return ResourceAsyncLoaderClass.New(self.m_seq)
end

function ResourceAsyncLoaderFactory:RecycleLoader(loader)
    table_insert(self.m_pool, loader)
end

return ResourceAsyncLoaderFactory