local StatusGiver = StatusGiver
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixSub = FixMath.sub
local Formular = Formular
local Factor = Factor
local AtkRoundJudge = Formular.AtkRoundJudge
local IsJudgeEnd = Formular.IsJudgeEnd
local CalcInjure = Formular.CalcInjure
local BattleEnum = BattleEnum
local StatusFactoryInst = StatusFactoryInst
local FixNormalize = FixMath.Vector3Normalize
local FixNewVector3 = FixMath.NewFixVector3
local FixIntMul = FixMath.muli
local BattleCameraMgr = BattleCameraMgr
local CtlBattleInst = CtlBattleInst
local ACTOR_ATTR = ACTOR_ATTR
local StatusEnum = StatusEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10042 = BaseClass("Skill10042", SkillBase)

function Skill10042:Perform(performer, target, performPos, special_param)
    if not performer or not target then
        return
    end
    
    -- 这里的暴击率是最终暴击率，不是暴击值	
    -- 赵云对当前敌人连续进行5次攻击，每次造成{X1}（+{e}%物攻)点物理伤害，并击退{a}米，最后一下将敌人击飞{b}米。
    -- 赵云对当前敌人连续进行5次攻击，每次造成{X2}（+{e}%物攻)点物理伤害，并击退{a}米，最后一下将敌人击飞{b}米。
    -- 赵云对当前敌人连续进行5次攻击，每次造成{X3}（+{e}%物攻)点物理伤害，并击退{a}米，最后一下将敌人击飞{b}米。赵云发动暴雨枪时，物理暴击率临时提升{Y3}%。
    -- 赵云对当前敌人连续进行5次攻击，每次造成{X4}（+{e}%物攻)点物理伤害，并击退{a}米，最后一下将敌人击飞{b}米。赵云发动暴雨枪时，物理暴击率临时提升{Y4}%。
    -- 赵云对当前敌人连续进行5次攻击，每次造成{X5}（+{e}%物攻)点物理伤害，并击退{a}米，最后一下将敌人击飞{b}米。赵云发动暴雨枪时，物理暴击率临时提升{Y5}%。
    -- 赵云对当前敌人连续进行5次攻击，每次造成{X6}（+{e}%物攻)点物理伤害，并击退{a}米，最后一下将敌人击飞{b}米。赵云发动暴雨枪时，物理暴击率临时提升{Y6}%。只要暴雨枪触发了暴击，就令敌人陷入{b}秒的断筋状态，攻速与移速各下降{c}%，可叠加。

    if special_param.keyFrameTimes ~= 5 then
        local judge = 0
        if self.m_level < 3 then 
            judge = AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
        else 
            local factor = Factor.New()
            factor.phyBaojiProbAdd = FixDiv(self:Y(), 100)
    
            judge = AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true, factor)
    
            if self.m_level == 6 then
                if judge == BattleEnum.ROUNDJUDGE_BAOJI then
                    -- 只要暴雨枪触发了暴击，就令敌人陷入{b}秒的断筋状态，攻速与移速各下降{c}%，可叠加。
    
                    local giver = StatusGiver.New(performer:GetActorID(), 10042)  
                    local buff = StatusFactoryInst:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self:B(), 1000))
                    buff:SetMergeRule(StatusEnum.MERGERULE_TOGATHER)
    
                    local decMul = FixDiv(self:C(), 100)
                    local curMoveSpeed = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_MOVESPEED)
                    local chgMoveSpeed = FixIntMul(curMoveSpeed, decMul)
                
                    local curAtkSpeed = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED)
                    local chgAtkSpeed = FixIntMul(curAtkSpeed, decMul)
                    
                    buff:AddAttrPair(ACTOR_ATTR.FIGHT_MOVESPEED, FixMul(chgMoveSpeed, -1))
                    buff:AddAttrPair(ACTOR_ATTR.FIGHT_ATKSPEED, FixMul(chgAtkSpeed, -1))
                    self:AddStatus(performer, target, buff)

                    performer:ShowSkillMaskMsg(0, BattleEnum.SKILL_MASK_ZHAOYUN, TheGameIds.BattleBuffMaskGrey)
                end
            end
        end
    
        if IsJudgeEnd(judge) then
            return  
        end
    
        local injure = CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
        if injure > 0 then
            local giver = StatusGiver.New(performer:GetActorID(), 10042)          
            
            local statusHP = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)
            self:AddStatus(performer, target, statusHP)
        end
    
        target:OnBeatBack(performer, self:A())
        local movehelper = performer:GetMoveHelper()
        if movehelper then
            local dir = target:GetPosition() - performer:GetPosition()
            dir.y = 0
            
            local moveTargetPos = FixNormalize(dir)
            moveTargetPos:Mul(self:A())
            moveTargetPos:Add(performer:GetPosition())

            local pathHandler = CtlBattleInst:GetPathHandler()
            if pathHandler then
                local x,y,z = performer:GetPosition():GetXYZ()
                local x2, y2, z2 = moveTargetPos:GetXYZ()
                local hitPos = pathHandler:HitTest(x, y, z, x2, y2, z2)
                if hitPos then
                    moveTargetPos:SetXYZ(hitPos.x , performer:GetPosition().y, hitPos.z)
                end
            end

            movehelper:Stop()
            movehelper:Start({ moveTargetPos }, 30, nil, true)
        end
    else
        -- target:OnBeatFly(BattleEnum.ATTACK_WAY_FLY_AWAY, performer:GetPosition(), self:B())
        target:OnBeatBack(performer, self:B())
    end



end

return Skill10042