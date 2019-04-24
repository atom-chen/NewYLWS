local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local Quaternion = Quaternion
local CtlBattleInst = CtlBattleInst
local BattleEnum = BattleEnum
local StatusEnum = StatusEnum

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor2034 = BaseClass("Actor2034", Actor)

function Actor2034:__init(actorID)
    self.m_offsetY = 2.5

    self.m_dropHp = 0

    self.m_giver = StatusGiver.New(self:GetActorID(), 0)
end

function Actor2034:__delete()
    self.m_giver = nil
end

function Actor2034:GetOffsetY()
    return self.m_offsetY
end

function Actor2034:DropHP(hp)
    self.m_dropHp = FixAdd(self.m_dropHp, hp)
end

function Actor2034:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    local pos = self:GetPosition()
    -- pos.y = FixSub(self.m_offsetY, pos.y)
    -- self:SetPosition(pos)
    self:AddSceneEffect(203406, Vector3.New(pos.x, pos.y + 0.2, pos.z), Quaternion.identity)    
end

function Actor2034:PreAddStatus(newStatus)
    Actor.PreAddStatus(self, newStatus)
    if not self:IsLive() or not newStatus then
        return
    end

    local statusType = newStatus:GetStatusType()
    if statusType == StatusEnum.STATUSTYPE_FROZEN or statusType == StatusEnum.STATUSTYPE_STUN or statusType == StatusEnum.STATUSTYPE_SILENT then
        if self:GetAI():GetSpecialState() == SPECIAL_STATE.CONTINUE_GUIDE then
            if self.m_stateContainer then
                if self.m_stateContainer:GetState() then
                    local stateID = self.m_stateContainer:GetState():GetStateID()
                    if stateID == BattleEnum.ActorState_ATTACK then
                        self:GetAI():SpecialStateEnd()
                        self:Idle()
                    end
                end
            end
        end
    end
end

function Actor2034:InitGlobalCD()
   if self.m_skillContainer then
        self.m_skillContainer:SetGlobalCD(6)
   end
end

function Actor2034:OnSkillPerformed(skillCfg)
    if skillCfg.id == 20342 then
        local logic = CtlBattleInst:GetLogic()
        if logic then
            logic:SwitchOnHexinCamMode()
        end
    end
    
    Actor.OnSkillPerformed(self, skillCfg)
end

function Actor2034:OnAttackEnd(skillCfg)
    if skillCfg.id == 20342 then
        local logic = CtlBattleInst:GetLogic()
        if logic then
            logic:SwitchOrignalCamMode()
        end
    end
end


function Actor2034:HasHurtAnim()
    return false
end

function Actor2034:OnDie(killerGiver, hpChgReason, killKeyFrame)
    self:AddSceneEffect(203403, Vector3.New(self:GetPosition().x, self:GetPosition().y + 0.2, self:GetPosition().z), Quaternion.identity)    

    Actor.OnDie(self, killerGiver, hpChgReason, killKeyFrame)
end


function Actor2034:LogicUpdate(deltaMS)
    if self.m_component then
        self.m_component:CheckEffect()
    end

    if self.m_dropHp < 0 then
        local statusHp = StatusFactoryInst:NewStatusDelayHurt(self.m_giver,  self.m_dropHp, BattleEnum.HURTTYPE_REAL_HURT, 0, BattleEnum.HPCHGREASON_SELF_HURT, 0, BattleEnum.ROUNDJUDGE_NORMAL)
        self:GetStatusContainer():Add(statusHp, self)

        self.m_dropHp = 0
    end
end

function Actor2034:NeedBlood()
    return false
end

function Actor2034:CanMove(checkAlive)
    return false
end

function Actor2034:CanBeatBack()
    return false
end

return Actor2034