

local BattleEnum = BattleEnum
local EffectEnum = EffectEnum
local ActorUtil = ActorUtil
local ConfigUtil = ConfigUtil
local Space = CS.UnityEngine.Space
local table_insert = table.insert
local Vector3 = Vector3
local Time = Time
local Quaternion = CS.UnityEngine.Quaternion
local GameObject = CS.UnityEngine.GameObject
local GameUtility = CS.GameUtility
local Shader = CS.UnityEngine.Shader
local Type_Animator = typeof(CS.UnityEngine.Animator)
local Type_Renderer = typeof(CS.UnityEngine.Renderer)
local Type_TextMesh = typeof(CS.UnityEngine.TextMesh)
local Layers = Layers
local PreloadHelper = PreloadHelper
local SmokeEffectPath = TheGameIds.saima_smoke

local HorseShow = BaseClass("HorseShow")

function HorseShow:__init(horseObj, horseID, horseLevel, isShowOff)
    self.m_horseGo = horseObj
    self.m_horseID = horseID
    self.m_horseLevel = horseLevel
    self.m_isShowoff = isShowOff or false
    self.m_transform = self.m_horseGo.transform
    self.m_animator = self.m_horseGo:GetComponentInChildren(Type_Animator)

    self.m_ridePoint = nil
    self.m_rideTransform = self.m_transform:Find('Dummy/Point001')

    self.m_nameText = self.m_transform:GetComponentInChildren(Type_TextMesh)
    self.m_renderList = self.m_horseGo:GetComponentsInChildren(Type_Renderer)
    self.m_actorDummyPostion = Vector3.zero
    self.m_actorDummyRotation = Quaternion.identity
    self.m_actorDummyScale = Vector3.one

    self:SetLayer(Layers.IGNORE_RAYCAST)

    self.m_shadowMatList = {}
    if self.m_renderList then
        self.m_ShaderShadowHeightID = Shader.PropertyToID("_ShadowHeight")
        for i = 0, self.m_renderList.Length - 1 do
            local r = self.m_renderList[i]
            local mat = r.material
            if not IsNull(mat) then
                if r.material:HasProperty('_ShadowHeight') then
                    table_insert(self.m_shadowMatList, mat)
                end
            end
        end
    end

    self.m_smokeEffect = nil
end

function HorseShow:__delete()
    self:RecycleActorObj()
    self:RecycleSmokeEffect()

    self.m_horseGo = nil
    self.m_transform = nil
    self.m_animator = nil
    self.m_rideTransform = nil
    self.m_renderList = nil
    self.m_shadowMatList = nil
    self.m_nameText = nil
end

function HorseShow:RecycleActorObj()    
    if not IsNull(self.m_horseGo) then
        local horsePath = ''
        
        if self.m_isShowoff then
            horsePath = PreloadHelper.GetShowoffHorsePath(self.m_horseID, self.m_horseLevel)
        else
            horsePath = PreloadHelper.GetHorsePath(self.m_horseID, self.m_horseLevel)
        end

        GameObjectPoolInst:RecycleGameObject(horsePath, self.m_horseGo)
        self.m_horseGo = nil
    end

    if not IsNull(self.m_ridePoint) then
        GameObject.Destroy(self.m_ridePoint)
        self.m_ridePoint = nil
    end
end

function HorseShow:SetLayer(layer)
    if not IsNull(self.m_horseGo) then
        GameUtility.SetLayer(self.m_horseGo, layer)
    end
end

function HorseShow:GetHorseID()
    return self.m_horseID
end

function HorseShow:GetHorseLV()
    return self.m_horseLevel
end

function HorseShow:MountOn(actorTr, actorDummyTr)
    if IsNull(actorTr) or IsNull(actorDummyTr) then
        return
    end

    self.m_horseGo:SetActive(true)

    -- 把Horse挂在Actor下
    self.m_transform:SetParent(actorTr)
    self.m_transform.localPosition = Vector3.zero
    self.m_transform.localRotation = Quaternion.identity
    self.m_transform.localScale = Vector3.one

    -- 缓存Actor的方位
    self.m_actorDummyPostion = actorDummyTr.localPosition
    self.m_actorDummyRotation = actorDummyTr.localRotation
    self.m_actorDummyScale = actorDummyTr.localScale

    -- 创建动画挂点
    if IsNull(self.m_ridePoint) then
        self.m_ridePoint = GameObject('RidePoint')
        local tr = self.m_ridePoint.transform
        tr.localRotation = actorTr.localRotation
        tr.localScale = actorTr.localScale
        tr:SetParent(self.m_rideTransform)
        tr.localPosition = Vector3.zero
    end

    -- Actor的Dummy挂到自己的Dummy下
    actorDummyTr:SetParent(self.m_ridePoint.transform)
    actorDummyTr.localPosition = Vector3.zero
    actorDummyTr.localRotation = Quaternion.identity
    actorDummyTr.localScale = Vector3.one
end

function HorseShow:MountOff(actorTr, actorDummyTr)
    if IsNull(actorTr) or IsNull(actorDummyTr) then
        return
    end

    actorDummyTr:SetParent(actorTr)
    actorDummyTr.localPosition = self.m_actorDummyPostion 
    actorDummyTr.localRotation = self.m_actorDummyRotation
    actorDummyTr.localScale =    self.m_actorDummyScale
    self.m_horseGo:SetActive(false)
end

function HorseShow:SetAnimatorSpeed(speed)
    self.m_animator.speed = speed
end

function HorseShow:GetAnimatorSpeed()
    return self.m_animator.speed
end

function HorseShow:PlayAnim(animName)
    if self.m_animator then
        if animName == BattleEnum.ANIM_IDLE or 
            animName == BattleEnum.ANIM_RIDE_IDLE or 
            animName == BattleEnum.ANIM_RIDE_IDLE_EX then
            --GameUtility.ForceCrossFade(self.m_animator, BattleEnum.ANIM_IDLE, 0)
            self.m_animator:Play(BattleEnum.ANIM_IDLE, 0, 0)

        elseif animName == BattleEnum.ANIM_MOVE or 
                animName == BattleEnum.ANIM_RIDE_WALK or
                animName == BattleEnum.ANIM_RIDE_WALK_EX then
           -- GameUtility.ForceCrossFade(self.m_animator, BattleEnum.ANIM_MOVE, 0)
            self.m_animator:Play(BattleEnum.ANIM_MOVE, 0, 0)
        end
    end
end

function HorseShow:SetShadowHeight(height)
    local y = height + 0.03
    for _, mat in ipairs(self.m_shadowMatList) do
        mat:SetFloat(self.m_ShaderShadowHeightID, y)
    end
end

function HorseShow:SetNameTextMesh(name)
    if name and self.m_nameText then
        self.m_nameText.text = name
    end
end

function HorseShow:SetNameTextMeshRotationY(rotationY)
    if self.m_nameText and rotationY then
        self.m_nameText.transform.localRotation = Quaternion.Euler(0, rotationY, 0)
    end
end

function HorseShow:ShowSmokeEffect(isShow)
    if isShow then
        if not self.m_smokeEffect then
            GameObjectPoolInst:GetGameObjectAsync(SmokeEffectPath, 
                function(go, effectID)
                    if not IsNull(go) then
                        local trans = go.transform
                        local pos = Vector3.zero
                        local effectRotation = Quaternion.identity

                        trans:SetParent(self.m_transform)
                        trans.localPosition = pos
                        trans.rotation = effectRotation
                        self.m_smokeEffect = go
    
                        GameUtility.SetLayer(go, Layers.IGNORE_RAYCAST)
                    end
                end
            )
        end
    else
        self:RecycleSmokeEffect()
    end
end

function HorseShow:RecycleSmokeEffect()
    if not IsNull(self.m_smokeEffect) then
        GameObjectPoolInst:RecycleGameObject(SmokeEffectPath, self.m_smokeEffect)
        self.m_smokeEffect = nil
    end
end

function HorseShow:PauseSmokeEffect(isPause)
    if self.m_smokeEffect then
        self.m_smokeEffect:SetActive(not isPause)
    end
end

return HorseShow