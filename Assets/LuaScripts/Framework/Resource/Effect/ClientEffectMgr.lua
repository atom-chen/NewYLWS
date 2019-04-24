local EffectEnum = EffectEnum
local Time = Time
local table_remove = table.remove
local table_insert = table.insert
local BaseEffectMgr = require "Framework.Resource.Effect.BaseEffectMgr"
local actorEffectClass = require("Framework.Resource.Effect.ActorEffect")
local sceneEffectClass = require("Framework.Resource.Effect.SceneEffect")

local ClientEffectMgr = BaseClass("ClientEffectMgr", BaseEffectMgr)

function ClientEffectMgr:__init()
    self.m_effectDict = {}
    --self.m_countDict = {}  暂时注释
    self.m_updateInterval = 0
    self.m_isPause = false
    self.m_delayAddBuffArray = {}
    self.m_delayAddInterval = 0
    self.m_maxKey = 0
end

function ClientEffectMgr:RemoveAllEffect()
    for k,v in pairs(self.m_effectDict) do
        if v then
            v:Delete()
        end
    end

    self.m_effectDict = {}
    --self.m_countDict = {}
    self.m_updateInterval = 0
    self.m_isPause = false
    self.m_delayAddBuffArray = {}
    self.m_delayAddInterval = 0
    self.m_maxKey = 0
end

function ClientEffectMgr:LateUpdate(deltaTime)

    if self.m_isPause then
        return
    end

    self:CheckEffect(deltaTime)
    self:CheckPlaySpeed()

    self.m_updateInterval = self.m_updateInterval + deltaTime
    if self.m_updateInterval < 0.1 then
        return
    end
    self.m_updateInterval = 0
    
    self:CheckDelayAddBuff(deltaTime)
end

function ClientEffectMgr:CheckPlaySpeed()
    if self.m_isPause then
        return 
    end

    for k,v in pairs(self.m_effectDict) do
        if v and not v:IsPause() then
            v:CheckEffectSpeed()
        end
    end
end

function ClientEffectMgr:CheckEffect(deltaTime)

    for k,v in pairs(self.m_effectDict) do
        if v and not v:IsPause() then
            v:LateUpdate(deltaTime)
            if not v:IsLive() then
                self:RemoveEffect(v)
            end
        end
    end
end

function ClientEffectMgr:RemoveEffect(effect)
    if not effect then
        return
    end

    self.m_effectDict[effect:GetEffectKey()] = nil

    --[[ 
    local effectID = effect:GetEffectID()
    local count = self.m_countDict[effectID]
    if count then
        count = count -1
        count = count > 0 and count or 0
        self.m_countDict[effectID] = count
    end ]]

    effect:Delete()
end

function ClientEffectMgr:CheckDelayAddBuff(deltaTime)
    if #self.m_delayAddBuffArray <= 0 then
        return
    end

    if self.m_delayAddInterval > 0 then
        self.m_delayAddInterval = self.m_delayAddInterval - deltaTime
    end

    if self.m_delayAddInterval <= 0 then
        self.m_delayAddInterval = 1
        self:AddEffect(table_remove(self.m_delayAddBuffArray, 1))
    end
end

function ClientEffectMgr:AddEffect(actorParam, effectID, maxCount, delfun, effectAttachPoint, posOffset, rotation)
    
    effectAttachPoint = effectAttachPoint or EffectEnum.ATTACH_POINT_NONE
    maxCount = maxCount or 0
   
    local effectCfg = ConfigUtil.GetActorEffectCfgByID(effectID)
    if not effectCfg then 
        return -1
    end

   --[[  local curCount = self.m_countDict[effectID]
    maxCount = effectCfg.accType == EffectEnum.EFFECT_TYPE_BE_HIT and 3 or maxCount
    if maxCount > 0 and curCount and curCount >= maxCount then
        return -2
    end ]]

    local effect = self:CreateEffect(actorParam, effectID, delfun, effectAttachPoint, posOffset, rotation)

    --[[ if curCount then
        curCount = curCount + 1
    else 
        curCount = 1
    end 
    self.m_countDict[effectID] = curCount
    ]]
    return effect:GetEffectKey()
end

function ClientEffectMgr:CreateEffect(actorParam, effectID, delfun, effectAttachPoint, posOffset, rotation)
    local effect = actorEffectClass.New()
    local key = self:GenerateKey()
    self.m_effectDict[key] = effect

    effect:OnInit(effectID, actorParam, key, delfun, effectAttachPoint, posOffset, rotation)
    return effect
end

function ClientEffectMgr:GenerateKey()
    self.m_maxKey = self.m_maxKey + 1
    return self.m_maxKey
end

function ClientEffectMgr:DelayAddBuffEffect(buffType)
    if CtlBattleInst:IsInFight() then
        table_insert(self.m_delayAddBuffArray, buffType)
    end
end

function ClientEffectMgr:ClearBuffEffect()
    self.m_delayAddBuffArray = {}
end

function ClientEffectMgr:HideEffect()
    for k,v in pairs(self.m_effectDict) do
        if v then
            v:HideEffect()
        end
    end
end

function ClientEffectMgr:ShowEffect()
    for k,v in pairs(self.m_effectDict) do
        if v then
            v:ShowEffect()
        end
    end
end

function ClientEffectMgr:RemoveByKey(key)
   
    local effect = self.m_effectDict[key]
    local effectID = 0
    if effect then
        effectID = effect:GetEffectID()
        self:RemoveEffect(effect)
    end
end

function ClientEffectMgr:GetEffect(key)
    return self.m_effectDict[key]
end

function ClientEffectMgr:Pause(reason)
    self.m_isPause = true 
    PlayOrStopALLEffect(true, reason)
end

function ClientEffectMgr:Resume(reason)
    self.m_isPause = false
    PlayOrStopALLEffect(false, reason)
end

function ClientEffectMgr:PlayOrStopALLEffect(isStop, reason)
    -- TODO 
end

function ClientEffectMgr:PauseEffectByKey(key, reason)
    local effect = self.m_effectDict[key]
    if effect then
        effect:Pause(reason)
    end
end

function ClientEffectMgr:ResumeEffectByKey(key, reason)
    local effect = self.m_effectDict[key]
    if effect then
        effect:Resume(reason)
    end
end

function ClientEffectMgr:ClearEffect(effectList)
    for _,v in pairs(effectList) do 
        self:RemoveByKey(v)
    end
end

function ClientEffectMgr:AddSceneEffect(effectID, pos, quat, delfun)

    local effectCfg = ConfigUtil.GetActorEffectCfgByID(effectID)
    if not effectCfg then 
        return -1
    end

    local key = self:GenerateKey()
    local effect = sceneEffectClass.New()
    self.m_effectDict[key] = effect

    effect:OnInit(effectID, key, pos, quat, delfun)
    return key
end

function ClientEffectMgr:LoadEffect(effect, effectPath)
    -- 资源加载
    local res_path = PreloadHelper.GetEffectPath(effectPath)
    
    GameObjectPoolInst:GetGameObjectAsync(res_path, 
        function(go, effectKey)
            if not IsNull(go) then
                local effect = self.m_effectDict[effectKey]
                if effect then
                    effect:InitEffect(go)
                else
                    GameObjectPoolInst:RecycleGameObject(res_path, go)
                end
            end
        end, effect:GetEffectKey())

end

return ClientEffectMgr