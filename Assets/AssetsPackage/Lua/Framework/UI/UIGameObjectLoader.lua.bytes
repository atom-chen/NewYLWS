local GameObjectPoolInstance = GameObjectPoolInst

local UIGameObjectLoader = BaseClass("UIGameObjectLoader", Singleton)

function UIGameObjectLoader:__init()
    self.m_seq = 0
    self.m_reqDic = {}
end

function UIGameObjectLoader:Clear()
    self.m_seq = 0
    self.m_reqDic = {}
end

function UIGameObjectLoader:CancelLoad(seq)
    if seq > 0 then
        self.m_reqDic[seq] = nil
    end
end

function UIGameObjectLoader:PrepareOneSeq()
    self.m_seq = self.m_seq + 1
    return self.m_seq
end

function UIGameObjectLoader:LoadAsset(path, assetType, callback, ...)
    self.m_seq = self.m_seq + 1
    self.m_reqDic[self.m_seq] = true

    GameObjectPoolInstance:LoadAssetAsync(path, assetType, 
        function(asset, seq, callback, ...)
            if not IsNull(asset) then
                if self.m_reqDic[seq] then
                    self.m_reqDic[seq] = nil

                    if callback then
                        callback(asset, ...)
                    end
                end
            end
        end, self.m_seq, callback, ...)
end

function UIGameObjectLoader:GetGameObject(loadingSeq, path, callback, ...)
   
    self.m_reqDic[loadingSeq] = true
    local args = SafePack(...)

    GameObjectPoolInstance:GetGameObjectAsync(path, 
        function(go, seq, callback)
            if not IsNull(go) then
                if self.m_reqDic[seq] then
                    self.m_reqDic[seq] = nil

                    if callback then
                        callback(go, SafeUnpack(args))
                    end
                else
                    GameObjectPoolInstance:RecycleGameObject(path, go)
                end
            end
        end, loadingSeq, callback)
end

function UIGameObjectLoader:GetGameObjects(loadingSeq, path, instCount, callback, ...)
    self.m_reqDic[loadingSeq] = true
    local args = SafePack(...)

    GameObjectPoolInstance:GetGameObjectAsync2(path, instCount,
        function(objs, seq, callback)
            if not objs then
                return
            end

            if self.m_reqDic[seq] then
                self.m_reqDic[seq] = nil

                if callback then
                    callback(objs, SafeUnpack(args))
                end
            else
                for i = 1, #objs do
                    GameObjectPoolInstance:RecycleGameObject(path, objs[i])
                end
            end
        end, loadingSeq, callback)
end

function UIGameObjectLoader:RecycleGameObject(path, obj)
    if not path or not obj then
        return
    end
    
    GameObjectPoolInstance:RecycleGameObject(path, obj)
end

function UIGameObjectLoader:RecycleGameObjects(path, objs)
    if not path or not objs then
        return
    end

    for i = 1, #objs do
        GameObjectPoolInstance:RecycleGameObject(path, objs[i])
    end
end


return UIGameObjectLoader

