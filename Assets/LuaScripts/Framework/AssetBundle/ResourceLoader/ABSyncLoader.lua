local AssetBundle = CS.UnityEngine.AssetBundle
local WWW = CS.UnityEngine.WWW
local GameUtility = CS.GameUtility

local ABSyncLoader = BaseClass("ABSyncLoader")

function ABSyncLoader:__init(sequence)
    self.m_seq = sequence
    self.m_delayUnload = 0
    self.m_abName = nil
end

function ABSyncLoader:GetABName()
    return self.m_abName
end

function ABSyncLoader:SyncLoad(url, abName)
    self.m_abName = abName
    local assetbundle = nil

    local www = WWW(url)
    if www then
        while not www.isDone do end

        if www.error and www.error ~= '' then
            Logger.LogError(www.error .. " for " .. url)
        else
            assetbundle = GameUtility.LoadABFromMemory(www)
        end
    end

    -- ab延时10帧销毁，在iOS和mac editor下加载assetbundle会报错
    self.m_delayUnload = 10
    return assetbundle, www
end

function ABSyncLoader:CanUnload()
    return self.m_delayUnload <= 0
end

function ABSyncLoader:Update()
    self.m_delayUnload = self.m_delayUnload - 1
end

function ABSyncLoader:Dispose()
    self.m_abName = nil
    self.m_delayUnload = 10
    ABLoaderFactory:GetInstance():RecycleSyncLoader(self)
end

return ABSyncLoader