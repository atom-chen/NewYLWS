
local table_insert = table.insert
local SKILL_RELATION_TYPE = SKILL_RELATION_TYPE
local Vector3 = Vector3
local FixNewVector3 = FixMath.NewFixVector3
local BattleEnum = BattleEnum
local SKILL_TYPE = SKILL_TYPE

local ClientSkillInputMgr = require "GameLogic.Battle.Input.ClientSkillInputMgr"
local ActorSkillInputMgr = BaseClass("ActorSkillInputMgr", ClientSkillInputMgr)
local base = ClientSkillInputMgr


function ActorSkillInputMgr:PreProcess(performer, skillBase)
    local cameraFX = CtlBattleInst:GetSkillCameraFX()
    if cameraFX then
        cameraFX:PlayPerformPrepareFX(performer)
    end
end

function ActorSkillInputMgr:HasPerformCameraFX()
    return true
end

function ActorSkillInputMgr:DoActive(performer, skillBase)


    local skillcfg = skillBase:GetSkillCfg()
    local battleLogic = CtlBattleInst:GetLogic()

    if skillcfg.relationship == SKILL_RELATION_TYPE.ENEMY then
        ActorManagerInst:Walk(
            function(tmpTarget)
                if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SELECT_TARGET) then
                    return
                end

                table_insert(self.m_candidateTargets, tmpTarget)
            end
        )
    elseif skillcfg.relationship == SKILL_RELATION_TYPE.SELF then
        table_insert(self.m_candidateTargets, performer)
    elseif skillcfg.relationship == SKILL_RELATION_TYPE.NONE then
    else
        ActorManagerInst:Walk(
            function(tmpTarget)
                if not battleLogic:IsFriend(performer, tmpTarget, (skillcfg.relationship == SKILL_RELATION_TYPE.FRIEND_WITH_SELF and true or false), 
                    BattleEnum.RelationReason_SELECT_TARGET) then
                    return
                end
                table_insert(self.m_candidateTargets, tmpTarget)
            end
        )
    end
end

function ActorSkillInputMgr:CreateSkillSelector()

    base.CreateSkillSelector(self)

    if self.m_skillSelector then
        local x, y, z = self.m_performer:GetPosition():GetXYZ()
        local pos = Vector3.New(x, y, z)
        self.m_skillSelector:InitBySkillCfg(self.m_skillBase:GetSkillCfg(), pos, self.m_candidateTargets)
    end
end


function ActorSkillInputMgr:UpdateTargets()
    if self.m_performer and self.m_skillBase then
        local pos = self.m_skillSelector:GetSkillReallyPos()
        local performPos = FixNewVector3(pos.x, pos.y, pos.z)
        local ret, tmpList = self.m_skillBase:GetTargetList(self.m_performer, performPos, self.m_skillSelector:SkillReallySingleTarget()) 
        
        self.m_targets = {}
        if ret == SKILL_CHK_RESULT.OK and tmpList and self.m_targets then
            for _, tmpActor in ipairs(tmpList) do
                table_insert(self.m_targets, tmpActor)
            end
        end

        return ret == SKILL_CHK_RESULT.OK
    end
    
    return false
end


return ActorSkillInputMgr

