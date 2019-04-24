local GameObject = CS.UnityEngine.GameObject
local Color = Color
local table_insert = table.insert
local string_format = string.format
local math_ceil = math.ceil
local BASE_SPEED = 20

local ActorComponent = require "GameLogic.Battle.Component.ActorComponent"
local HorseRaceActorComponent = BaseClass("HorseRaceActorComponent", ActorComponent)
local base = ActorComponent

function HorseRaceActorComponent:PlayAnim(animName, crossTime)
    if self.m_isOnHorse then
        if self.m_horseShow then
            if animName == BattleEnum.ANIM_IDLE then                    
                animName = PreloadHelper.GetRideIdleAnim(self.m_horseShow:GetHorseID())
            elseif animName == BattleEnum.ANIM_MOVE then
                animName = PreloadHelper.GetRideWalkAnim(self.m_horseShow:GetHorseID())
            end
            self.m_horseShow:PlayAnim(animName)
        end
    end
end

function HorseRaceActorComponent:Update(deltaTime)   
    self:UpdateForward(deltaTime)
end

function HorseRaceActorComponent:SetAnimatorSpeed(speed)
    local speedRate = speed / BASE_SPEED
    self.m_horseShow:SetAnimatorSpeed(speedRate)
end

function HorseRaceActorComponent:SetName(name, is_self)
    if self.m_horseShow then
        local horseCfg = ConfigUtil.GetZuoQiCfgByID(self.m_horseShow:GetHorseID())
        local horseName = horseCfg["name"..math_ceil(self.m_horseShow:GetHorseLV())]

        local num = is_self and 4171 or 4172
        local horseName = string_format(Language.GetString(num), horseName, name)
        self.m_horseShow:SetNameTextMesh(horseName)
    end
end

function HorseRaceActorComponent:Pause(reason)
    base.Pause(self, reason)
    self.m_pauseSpeed = self.m_horseShow:GetAnimatorSpeed()
    self.m_horseShow:SetAnimatorSpeed(0)
    self.m_horseShow:PauseSmokeEffect(true)
end

function HorseRaceActorComponent:Resume(reason)
    base.Resume(self, reason)
    self.m_horseShow:SetAnimatorSpeed(self.m_pauseSpeed)
    self.m_horseShow:PauseSmokeEffect(false)
end

function HorseRaceActorComponent:SetHorseNameRotationY(rotationY)
    if self.m_horseShow then
        self.m_horseShow:SetNameTextMeshRotationY(rotationY)
    end
end

function HorseRaceActorComponent:ShowSmokeEffect(isShow)
    if self.m_horseShow then
        self.m_horseShow:ShowSmokeEffect(isShow)
    end
end

return HorseRaceActorComponent