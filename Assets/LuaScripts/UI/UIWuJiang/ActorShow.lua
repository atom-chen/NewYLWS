

local BattleEnum = BattleEnum
local EffectEnum = EffectEnum
local ActorUtil = ActorUtil
local ConfigUtil = ConfigUtil
local Space = CS.UnityEngine.Space
local table_insert = table.insert
local Time = Time
local Quaternion = CS.UnityEngine.Quaternion
local GameObject = CS.UnityEngine.GameObject
local GameUtility = CS.GameUtility
local Animator = CS.UnityEngine.Animator
local Type_Animator = typeof(Animator)
local Type_Renderer = typeof(CS.UnityEngine.Renderer)
local Type_ParticleSystem = typeof(CS.UnityEngine.ParticleSystem)
local Layers = Layers
local PreloadHelper = PreloadHelper
local HorseShowClass = require "UI.UIWuJiang.HorseShow" 
local CommonDefine = CommonDefine
local IdleAnimHash = Animator.StringToHash("Base Layer.idle")

local ActorShow = BaseClass("ActorShow", Updatable)

local MultiWuqiEffect = {
    [1047] = true,
    [1048] = true,
    [1043] = true,
    [1042] = true,
    [1029] = true,
    [1002] = true,
    [1022] = true,
    [1214] = true,
}

function ActorShow:__init(actor_go, wuqi_go, wuqi_go2, wujiangID, wuqiLevel)
    self.m_gameObject = actor_go
    self.m_wuqiGo = wuqi_go
    self.m_wuqiGo2 = wuqi_go2
    self.m_exWuqiGo = nil
    self.m_petGo = nil
    self.m_petID = 0
    self.m_petAnimator = nil
    self.m_transform = actor_go.transform
    self.m_animator = actor_go:GetComponentInChildren(Type_Animator)

    self.m_showEffectList = {}
    self.m_effectTimeDic = {}

    self.m_effectPointTransDict = {}
    self.m_wujiangID = wujiangID
    self.m_wuqiLevel = wuqiLevel
    self.m_prepareLeftTime = 0
    self.m_skillLeftTime = 0
    self.m_bodyEffectRotation = false
    
    self.m_wujiangCfg = ConfigUtil.GetWujiangCfgByID(wujiangID)
    self.m_weaponShowTime = 0

    self.m_dummyTr = self.m_transform:Find('Dummy')

    if self.m_animator then
        self.m_animator.cullingMode = 0
    end

    self.m_horseShow = nil

    self.m_stageAudioKey = 0
    self.m_stageAskKey = 0

    -- self:GetSkillList()
    self:SetLayer(Layers.IGNORE_RAYCAST)
end

function ActorShow:__delete()
    self:Dismount()

    self:RecycleActorObj()
    self:ClearEffect()

    if self.m_stageAudioKey > 0 then
        AudioMgr:RemoveAudio(self.m_stageAudioKey)
        self.m_stageAudioKey = 0
    end
    
    if self.m_stageAskKey > 0 then
        AudioMgr:RemoveAudio(self.m_stageAskKey)
        self.m_stageAskKey = 0
    end

    self.m_gameObject = nil
    self.m_transform = nil
    self.m_animator = nil
    self.m_petAnimator = nil
    
    self.m_dummyTr = nil

    self.m_effectTimeDic = nil
    self.m_showEffectList = nil
    self.m_effectPointTransDict = nil

    self.m_wujiangCfg = nil
    self.m_renderList = nil
    self.m_petRenderList = nil
end

function ActorShow:RecycleActorObj()
    
    local resPath = PreloadHelper.GetShowOffWuJiangPath(self.m_wujiangID)
    local resPath2, resPath3, exPath = PreloadHelper.GetWeaponPath(self.m_wujiangID, self.m_wuqiLevel)

    if not IsNull(self.m_gameObject) then
        GameObjectPoolInst:RecycleGameObject(resPath, self.m_gameObject)
        self.m_gameObject = nil
        self.m_transform = nil
    end

    if not IsNull(self.m_wuqiGo) then
        GameObjectPoolInst:RecycleGameObject(resPath2, self.m_wuqiGo)
        self.m_wuqiGo = nil
    end

    if not IsNull(self.m_wuqiGo2) then
        GameObjectPoolInst:RecycleGameObject(resPath3, self.m_wuqiGo2)
        self.m_wuqiGo2 = nil
    end

    if not IsNull(self.m_petGo) then
        local petPath = PreloadHelper.GetShowOffWuJiangPath(self.m_petID)
        GameObjectPoolInst:RecycleGameObject(petPath, self.m_petGo)
        self.m_petGo = nil
    end

    if not IsNull(self.m_exWuqiGo) then
        GameObjectPoolInst:RecycleGameObject(exPath, self.m_exWuqiGo)
        self.m_exWuqiGo = nil
    end
end

function ActorShow:SetExWuqi(exObj)
    self.m_exWuqiGo = exObj
end

function ActorShow:SetPetGo(petGo, petID)
    self.m_petGo = petGo
    self.m_petID = petID
    
    if not IsNull(self.m_petGo) then
        self.m_petAnimator = self.m_petGo:GetComponentInChildren(Type_Animator)

        GameUtility.SetLayer(self.m_petGo, Layers.IGNORE_RAYCAST)
    end
end

function ActorShow:RolateUp(rotate)
    if self.m_transform then
        self.m_transform:Rotate(Vector3.up, rotate, Space.World)
    end
end

function ActorShow:PlayAnim(animName)
    if self.m_animator then
        if animName == BattleEnum.ANIM_RIDE_IDLE then
            if self.m_horseShow then
                animName = PreloadHelper.GetRideIdleAnim(self.m_horseShow:GetHorseID())
            end
        end
        self.m_animator:Play(animName, 0, 0)
    end

    if self.m_petAnimator then
        if animName == BattleEnum.ANIM_SHOWOFF then
            self.m_petAnimator:Play(BattleEnum.ANIM_SHOWOFF, 0, 0)
        else
            self.m_petAnimator:Play(BattleEnum.ANIM_IDLE, 0, 0)
        end
    end

    if self.m_horseShow then
        self.m_horseShow:PlayAnim(animName, 0, 0)
    end
end

function ActorShow:ShowShowoffEffect(callback)
    local effectID = self.m_wujiangID * 100 + 20
    if MultiWuqiEffect[self.m_wujiangID] then
        effectID = effectID + PreloadHelper.WuqiLevelToResLevel(self.m_wuqiLevel)
    end

    local effectCfg = ConfigUtil.GetActorEffectCfgByID(effectID)
    if not effectCfg then 
        if callback then
            callback(false)
        end
        return
    end

    
    local effectAttachPoint = effectCfg.attachpoint
    local parentTrans = self:GetEffectTransform(effectAttachPoint)

    self:ShowEffect(effectID, parentTrans, function(isSuccess, effectGo)
        self:SetActive(false)
        self:SetActive(true)
       
        if not IsNull(effectGo) then
            GameUtility.SetLayer(effectGo, Layers.IGNORE_RAYCAST)
            GameUtility.SetWeaponTrailLayer(effectGo, Layers.IGNORE_RAYCAST)
        end

        if callback then
            callback(isSuccess, effectGo)
        end

        --跟showoff配合
        if self.m_wujiangID == 1048 then
            self:DelayShowWeapon(3.167)
        elseif self.m_wujiangID == 1043 then
            self:DelayShowWeapon(1.866)
        elseif self.m_wujiangID == 1002 then
            self:DelayShowWeapon(1.75)
        elseif self.m_wujiangID == 1022 then
            self:DelayShowWeapon(6.08)
        elseif self.m_wujiangID == 1214 then
            self:DelayShowWeapon(7.19)
        end
    end)

    if not IsNull(self.m_petGo) then
        if self.m_wujiangID == 1038 then
            self:ShowEffect(320820, self.m_petGo.transform)
        end
    end
end

function ActorShow:ShowEffect(effectID, parentTrans, callBack, showScale)
    if effectID <= 0 then
        return
    end

    local effectCfg = ConfigUtil.GetActorEffectCfgByID(effectID)
    if not effectCfg then 
        if callBack then
            callBack(false)
        end
        return
    end

    local effectGo = self.m_showEffectList[effectID]
    if effectGo ~= true and not IsNull(effectGo) then
        if showScale then
            effectGo.transform.localScale = showScale
        end
        self:PlayEffectGo(effectGo)
        return
    end
    
    if self.m_showEffectList[effectID] then
        return
    end

    self.m_showEffectList[effectID] = true

    local res_path = PreloadHelper.GetEffectPath(effectCfg.path)
    GameObjectPoolInst:GetGameObjectAsync(res_path, 
        function(go, effectID)

            if not IsNull(go) then
                if self.m_showEffectList and self.m_showEffectList[effectID] then

                    -- go:SetActive(false)
                    -- go:SetActive(true)

                    local trans = go.transform

                    if showScale then
                        go.transform.localScale = showScale
                    end

                    local pos = Vector3.zero
                    local effectRotation = Quaternion.identity
                    
                    if not parentTrans then
                        parentTrans = self:GetEffectTransform(effectCfg.attachpoint)
                    end

                    if parentTrans then
                        trans:SetParent(parentTrans)
                        effectRotation = parentTrans.rotation
                        if effectCfg.attachpoint == EffectEnum.ATTACH_POINT_BODY then
                            if self.m_bodyEffectRotation then
                                effectRotation = effectRotation * self.m_bodyEffectRotation
                            end
                        end
                    end
    
                    trans.localPosition = pos
                    trans.rotation = effectRotation
                    self.m_showEffectList[effectID] = go

                    self.m_effectTimeDic[effectID] = 20

                    GameUtility.SetLayer(go, Layers.IGNORE_RAYCAST)
	                GameUtility.SetWeaponTrailLayer(go, Layers.IGNORE_RAYCAST)
                                      
                    if callBack then
                        callBack(true, go)
                    end
                else
                    GameObjectPoolInst:RecycleGameObject(res_path, go)
                end
            end
        end, effectID)
end

function ActorShow:ClearEffect()
    if self.m_showEffectList then
        for k, v in pairs(self.m_showEffectList) do
           
            if v ~= true and not IsNull(v) then
                local effectCfg = ConfigUtil.GetActorEffectCfgByID(k)
                local res_path = PreloadHelper.GetEffectPath(effectCfg.path)
                GameObjectPoolInst:RecycleGameObject(res_path, v)
            end
        end

        self.m_showEffectList = nil
    end
end

function ActorShow:GetEffectTransform(effectPoint)
    local trans = self.m_effectPointTransDict[effectPoint]
    if trans then
        return trans
    end
    
    local path = self:GetBonePath(effectPoint)
    trans = self.m_transform:Find(path)
    self.m_effectPointTransDict[effectPoint] = trans
    return trans
end

function ActorShow:GetBonePath(effectPoint)
    return ActorUtil.GetDefaultBonePath(effectPoint, self.m_wujiangID)
end

function ActorShow:Update()
    for k, v in pairs(self.m_effectTimeDic) do
        local go = self.m_showEffectList[k]
        if go ~= true and not IsNull(go) then
            local leftS = v - Time.deltaTime
            self.m_effectTimeDic[k] = leftS

            if leftS <= 0 then
                local effectCfg = ConfigUtil.GetActorEffectCfgByID(k)
                local res_path = PreloadHelper.GetEffectPath(effectCfg.path)
                GameObjectPoolInst:RecycleGameObject(res_path, go)

                self.m_showEffectList[k] = nil
            end
        end
    end

    if not self.m_bodyEffectRotation and self.m_animator then 
        local stateInfo = self.m_animator:GetCurrentAnimatorStateInfo(0)
        if stateInfo.fullPathHash == IdleAnimHash then
            if self.m_transform then
                local trans = self:GetEffectTransform(EffectEnum.ATTACH_POINT_BODY)
                if trans then
                    local rotation = trans.rotation
                    rotation = Quaternion.New(rotation.x, rotation.y, rotation.z , rotation.w)
                    self.m_bodyEffectRotation = rotation:Inverse()
                end
            end
        end
    end

    if self.m_weaponShowTime > 0 then
        self.m_weaponShowTime = self.m_weaponShowTime - Time.deltaTime
        if self.m_weaponShowTime <= 0 then

            if not IsNull(self.m_wuqiGo) then
                self.m_wuqiGo:SetActive(true)
            end
        end
    end
  
end


function ActorShow:SetPosition(pos, pet_x_offset)
    if self.m_transform then
        self.m_transform.localPosition = pos

        if self.m_petGo then
            local petTrans = self.m_petGo.transform
            pet_x_offset = pet_x_offset or 0.2
            petTrans.localPosition = pos + Vector3.New(pet_x_offset, 0, 0)
        end
        
        local y = self.m_transform.position.y
        self:SetActorShadowHeight(y + 0.01)
    end
end

function ActorShow:GetPosition()
    if self.m_transform then
        return self.m_transform.localPosition
    end
end

function ActorShow:SetEulerAngles(v3)
    if self.m_transform then
        self.m_transform.localEulerAngles = v3
        
        if self.m_petGo then
            local petTrans = self.m_petGo.transform
            petTrans.localEulerAngles = v3
        end
        
    end
end

function ActorShow:SetLocalScale(scale)
    if self.m_transform then
        self.m_transform.localScale = scale
        
        if self.m_petGo then
            local petTrans = self.m_petGo.transform
            petTrans.localScale = scale
        end
    end
end

--显示武器的时长(特殊逻辑)
function ActorShow:DelayShowWeapon(showTime)
    
    if not IsNull(self.m_wuqiGo) then
        self.m_wuqiGo:SetActive(false)
    end
   
    self.m_weaponShowTime = showTime
end

function ActorShow:IsIdle()
    if self.m_animator then
        local stateInfo = self.m_animator:GetCurrentAnimatorStateInfo(0)
        if stateInfo.fullPathHash == IdleAnimHash then
            return true
        end
    end
    return false
end

function ActorShow:Mount(horseObj, horseID, horseLevel)
    if IsNull(horseObj) then
        return
    end
    
    if not self.m_horseShow then
        self.m_horseShow = HorseShowClass.New(horseObj, horseID, horseLevel, true)
    end
    self.m_horseShow:MountOn(self.m_transform, self.m_dummyTr)
end

function ActorShow:Dismount()
    if self.m_horseShow then
        self.m_horseShow:MountOff(self.m_transform, self.m_dummyTr)
        self.m_horseShow:Delete()
        self.m_horseShow = nil
    end
end

function ActorShow:SetLayer(layer)
    if not IsNull(self.m_gameObject) then
        GameUtility.SetLayer(self.m_gameObject, layer)
    end

    if not IsNull(self.m_wuqiGo) then
        GameUtility.SetLayer(self.m_wuqiGo, layer)
    end
    
    if not IsNull(self.m_wuqiGo2) then
        GameUtility.SetLayer(self.m_wuqiGo2, layer)
    end

    if not IsNull(self.m_exWuqiGo) then
        GameUtility.SetLayer(self.m_exWuqiGo, layer)
    end

    if not IsNull(self.m_petGo) then
        GameUtility.SetLayer(self.m_petGo, layer)
    end
end

function ActorShow:PlayEffectGo(effectGO)
    if not IsNull(effectGO) then
        effectGO:SetActive(true)
        local tmp = effectGO:GetComponentsInChildren(Type_ParticleSystem)
        for i = 0, tmp.Length - 1 do
            tmp[i]:Play()
        end
    end
end

function ActorShow:StopEffectGo(effectGO)
    if not IsNull(effectGO) then
        local tmp = effectGO:GetComponentsInChildren(Type_ParticleSystem)
        for i = 0, tmp.Length - 1 do
            tmp[i]:Stop()
        end
    end
end

function ActorShow:SetActive(bShow)
    if not IsNull(self.m_gameObject) then
        self.m_gameObject:SetActive(bShow)
    end

    if not IsNull(self.m_petGo) then
        self.m_petGo:SetActive(bShow)
    end
end

function ActorShow:GetWuJiangID()
    return self.m_wujiangID
end

function ActorShow:GetWuQiLevel()
    return self.m_wuqiLevel
end

function ActorShow:GetWujiangTransform()
    return self.m_transform
end

function ActorShow:GetGameObject()
    return self.m_gameObject
end

function ActorShow:GetPetID()
    return self.m_petID
end

function ActorShow:SetActorShadowHeight(height)
    if not self.m_renderList then
        self.m_renderList = self.m_gameObject:GetComponentsInChildren(Type_Renderer)
    end
    for i = 0, self.m_renderList.Length - 1 do
        local mat = self.m_renderList[i].material
        if not IsNull(mat) then
            if mat:HasProperty('_ShadowHeight') then
                mat:SetFloat("_ShadowHeight", height)
            end
        end
    end

    if not IsNull(self.m_petGo) then 
        if not self.m_petRenderList then
            self.m_petRenderList = self.m_petGo:GetComponentsInChildren(Type_Renderer)
        end
        for i = 0, self.m_petRenderList.Length - 1 do
            local mat = self.m_petRenderList[i].material
            if not IsNull(mat) then
                if mat:HasProperty('_ShadowHeight') then
                    mat:SetFloat("_ShadowHeight", height)
                end
            end
        end
    end

    if self.m_horseShow then
        self.m_horseShow:SetShadowHeight(height)
    end
end

function ActorShow:PlayStageAudio()
    if self.m_wujiangCfg then
        if self.m_wujiangCfg.stageAudio > 0 then
            self.m_stageAudioKey = AudioMgr:PlayAudio(self.m_wujiangCfg.stageAudio)
        end

        if self.m_wujiangCfg.stageask > 0 then
            self.m_stageAskKey = AudioMgr:PlayAudio(self.m_wujiangCfg.stageask)
        end
    end
end

return ActorShow