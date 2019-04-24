local Vector3 = Vector3
local Vector2 = Vector2
local IsNull = IsNull
local Quaternion = CS.UnityEngine.Quaternion
local BattleEnum = BattleEnum
local Time = Time
local GameUtility = CS.GameUtility
local NewCloseUpEffect = CS.NewCloseUpEffect
local ScreenShotEffect = CS.ScreenShotEffect
local Type_Material = typeof(CS.UnityEngine.Material)
local BaseSkillCameraFX = require "GameLogic.Battle.Camera.fx.BaseSkillCameraFX"
local ClientSkillCameraFX = BaseClass("ClientSkillCameraFX", BaseSkillCameraFX)
local table_insert = table.insert
local Layers = Layers
local SKILL_RANGE_TYPE = SKILL_RANGE_TYPE
local ResourcesManagerInst = ResourcesManagerInst
local UIManagerInst = UIManagerInst
local UIMessageNames = UIMessageNames

function ClientSkillCameraFX:__init()
    self.m_sourceActorID = -1
    self.m_isPlaying = false
end

function ClientSkillCameraFX:PlayWaitForInputFX(skillSelector, performer, candidateTargets)
    if not performer then
        return
    end

    self.m_isPlaying = true
    self.m_sourceActorID = performer:GetActorID()

    BattleCameraMgr:HideLayer(Layers.EFFECT)
    BattleCameraMgr:HideLayer(Layers.MEDIUM)

    ActorManagerInst:Walk(
        function(tmpTarget)
            tmpTarget:SetLayerState(BattleEnum.LAYER_STATE_HIDE)

            if tmpTarget:IsLive() then
                local actorColor = tmpTarget:GetActorColor()
                if actorColor then
                    actorColor:ClearColorPowerFactor()
                end
                tmpTarget:HideBloodUI(BattleEnum.ACTOR_BLOOD_REASON_ALL)
            end
        end
    )

    performer:SetLayerState(BattleEnum.LAYER_STATE_FOCUS)
    local gos = {performer:GetGameObject()}

    for _, tmpTarget in pairs(candidateTargets) do 
        if tmpTarget:IsLive() then
            tmpTarget:SetLayerState(BattleEnum.LAYER_STATE_SECONDARY)
            tmpTarget:ShowBloodUI(BattleEnum.ACTOR_BLOOD_REASON_DAZHAO_PREPARE)
            table_insert(gos, tmpTarget:GetGameObject())
        end
    end

    if skillSelector then
        local selectorRoot = skillSelector:GetRoot()
        if not IsNull(selectorRoot) then
            table_insert(gos, selectorRoot.gameObject)
        end
    end

    local mat = ResourcesManagerInst:LoadSync("EffectCommonMat/DynamicMaterials/SE_CloseUp.mat", Type_Material)
    if mat then
        NewCloseUpEffect.ApplyCloseUpEffect(mat, gos, Layers.Skill_Fx_1, Layers.Skill_Fx_2)
    end
end

function ClientSkillCameraFX:PlaySelectTargetFX(skillSelector, performer, candidateTargets, targets)
    if not performer then
        return
    end

    self.m_isPlaying = true
    self.m_sourceActorID = performer:GetActorID()

    BattleCameraMgr:HideLayer(Layers.EFFECT)
    BattleCameraMgr:HideLayer(Layers.MEDIUM)

    ActorManagerInst:Walk(
        function(tmpTarget)
            tmpTarget:SetLayerState(BattleEnum.LAYER_STATE_HIDE)

            if tmpTarget:IsLive() then
                local actorColor = tmpTarget:GetActorColor()
                if actorColor then
                    actorColor:ClearColorPowerFactor()
                end
                tmpTarget:HideBloodUI(BattleEnum.ACTOR_BLOOD_REASON_ALL)
            end
        end
    )

    performer:SetLayerState(BattleEnum.LAYER_STATE_FOCUS)
    local gos = {performer:GetGameObject()}

    local lowerObjs = {}
    for _, tmpTarget in pairs(candidateTargets) do 
        if tmpTarget:IsLive() then
            tmpTarget:SetLayerState(BattleEnum.LAYER_STATE_SECONDARY)
            tmpTarget:ShowBloodUI(BattleEnum.ACTOR_BLOOD_REASON_DAZHAO_PREPARE)
            table_insert(gos, tmpTarget:GetGameObject())
        end
    end

    for _, tmpTarget in pairs(targets) do
        if tmpTarget:IsLive() then
            tmpTarget:SetLayerState(BattleEnum.LAYER_STATE_FOCUS)
            tmpTarget:SetPower(1.5, 999999)
            tmpTarget:ShowBloodUI(BattleEnum.ACTOR_BLOOD_REASON_DAZHAO_PREPARE)
            table_insert(gos, tmpTarget:GetGameObject())
                  
            if skillSelector and skillSelector:GetSkillRangeType() == SKILL_RANGE_TYPE.SINGLE_TARGET then
                UIManagerInst:Broadcast(UIMessageNames.MN_BATTLE_SHOW_SELECTOR_TARGET, true, tmpTarget)
            end
        end
    end

    if skillSelector then
        local selectorRoot = skillSelector:GetRoot()
        if not IsNull(selectorRoot) then
            table_insert(gos, selectorRoot.gameObject)
        end

        if skillSelector:GetSkillRangeType() == SKILL_RANGE_TYPE.SINGLE_TARGET and #targets == 0 then
            UIManagerInst:Broadcast(UIMessageNames.MN_BATTLE_SHOW_SELECTOR_TARGET, false)
        end
    end

    local mat = ResourcesManagerInst:LoadSync("EffectCommonMat/DynamicMaterials/SE_CloseUp.mat", Type_Material)
    if mat then
        NewCloseUpEffect.ApplyCloseUpEffect(mat, gos, Layers.Skill_Fx_1, Layers.Skill_Fx_2)
    end
end

function ClientSkillCameraFX:PlayPerformPrepareFX(performer)
    if not performer then
        return
    end

    self.m_isPlaying = true
    self.m_sourceActorID = performer:GetActorID()

    BattleCameraMgr:ShowLayer(Layers.EFFECT)
    BattleCameraMgr:ShowLayer(Layers.MEDIUM)

    ActorManagerInst:Walk(
        function(tmpTarget)
            tmpTarget:SetLayerState(BattleEnum.LAYER_STATE_NORMAL)

            if tmpTarget:IsLive() then
                local actorColor = tmpTarget:GetActorColor()
                if actorColor then
                    actorColor:ClearColorPowerFactor()
                end
                tmpTarget:HideBloodUI(BattleEnum.ACTOR_BLOOD_REASON_ALL)
            end
        end
    )

    performer:SetLayerState(BattleEnum.LAYER_STATE_FOCUS)
    -- todo UICamera culling
    
    -- local mat = ResourcesManagerInst:LoadSync("EffectCommonMat/DynamicMaterials/SE_ScreenShot.mat", Type_Material)
    -- if mat then
    --     ScreenShotEffect.ApplyScreenShotEffect(mat, 0.8)
    -- end
end

function ClientSkillCameraFX:PlayPrepareScreenEffect(actorID, isBlur)
    local actor = ActorManagerInst:GetActor(actorID)
    if not actor then
        return 
    end

    local gos = {actor:GetGameObject()}
    local mat = ResourcesManagerInst:LoadSync("EffectCommonMat/DynamicMaterials/SE_CloseUp.mat", Type_Material)
    if mat then
        if isBlur then
            local blurMat = ResourcesManagerInst:LoadSync("EffectCommonMat/DynamicMaterials/SE_GaussianBlur.mat", Type_Material)
            NewCloseUpEffect.ApplyCloseUpEffect(mat, gos, Layers.Skill_Fx_1, Layers.Skill_Fx_2, 1, blurMat)
        else
            NewCloseUpEffect.ApplyCloseUpEffect(mat, gos, Layers.Skill_Fx_1, Layers.Skill_Fx_2)
        end
    end
end

function ClientSkillCameraFX:Stop(sourceActorID)
    if not sourceActorID or sourceActorID == -1 or sourceActorID == self.m_sourceActorID then
        if self.m_isPlaying then
            self.m_isPlaying = false

            BattleCameraMgr:ShowLayer(Layers.EFFECT)
            BattleCameraMgr:ShowLayer(Layers.MEDIUM)
                    
            ActorManagerInst:Walk(
                function(tmpTarget)
                    tmpTarget:SetLayerState(BattleEnum.LAYER_STATE_NORMAL)
                end
            )

            MediumManagerInst:SetAllLayerState(BattleEnum.LAYER_STATE_NORMAL)
            
    -- todo UICamera reverse culling

-- print('6666666666666666 CameraFX stop')
            NewCloseUpEffect.StopCloseUpEffect()
        end
    end
end

return ClientSkillCameraFX