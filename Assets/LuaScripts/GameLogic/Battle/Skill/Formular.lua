local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local FixFloor = FixMath.floor
local FixCeil = FixMath.ceil
local FixExp = FixMath.exp
local FixMod = FixMath.mod
local FixIntMul = FixMath.muli
local BattleRander = BattleRander

local ACTOR_ATTR = ACTOR_ATTR
local BattleEnum = BattleEnum
local BattleRecordEnum = BattleRecordEnum

local C_PHYDEF	    = 1.1
local A_PHYDEF	    = 4.8
local C_MAGICDEF	= 1.1
local A_MAGICDEF	= 4.8
local C_MINGZHONG	= 1
local A_MINGZHONG	= 7.14
local C_PHYBAOJI	= 1
local A_PHYBAOJI	= 7.14
local C_MAGICBAOJI	= 1
local A_MAGICBAOJI	= 7.14
local C_SHANBI	    = 1
local A_SHANBI	    = 8
local A_PHYATK	    = 2.4192
local A_MAGICATK    = 2.4192

Factor = BaseClass("Factor")
function Factor:__init()
    self.mingzhongProbAdd = 0
    self.shanbiProbAdd = 0
    self.phyBaojiProbAdd = 0
    self.magicBaojiProbAdd = 0
    self.chgMagicDef = 0
    self.chgPhyDef = 0
end
function Factor:Init()
    self.mingzhongProbAdd = 0
    self.shanbiProbAdd = 0
    self.phyBaojiProbAdd = 0
    self.magicBaojiProbAdd = 0
    self.chgMagicDef = 0
    self.chgPhyDef = 0
end


local FLV = function(level) 
    return FixAdd(5, FixMul(level, 20)) 
end

Formular = {
    DEFAULTFACTOR = Factor.New(),

    Init = function()
    end,

    GetDefaultFactor = function ()
        Formular.DEFAULTFACTOR:Init()
        return Formular.DEFAULTFACTOR
    end,

    --@judge : BattleEnum.ROUNDJUDGE_
    IsJudgeEnd = function (judge)
        if judge == BattleEnum.ROUNDJUDGE_NON_MINGZHONG  or  
            judge == BattleEnum.ROUNDJUDGE_SHANBI  or 
            judge == BattleEnum.ROUNDJUDGE_WUDI then
            return true
        end
        return false
    end,

    --@f : Factor
    NonMingzhongProb = function (atkerMingzhong, defLevel, f, isBlind)
        if isBlind then
            return 0.5
        end
        --  攻击命中率=(攻方命中等级*C/（守方f(lv)*A）+自有命中率80%) * (1 + 其他加成)
        --              (M        /       N          +        0.8) * (1 + other)
        local M = FixMul(atkerMingzhong, C_MINGZHONG)
        local N = FixMul(FLV(defLevel), A_MINGZHONG)
        
        local prob = FixAdd(FixDiv(M, N), 0.8)
        prob = FixMul(prob, FixAdd(1, f.mingzhongProbAdd or 0))

        if prob > 1 then 
            prob = 1
        elseif prob < 0 then 
            prob = 0 
        end

        return FixSub(1, prob)
    end,

    --@f : Factor
    ShanbiProb = function (defShanbi, atkerLevel, f)
        --  攻击闪避率=(守方闪避等级*C/(守方闪避等级+攻方f(lv)*A)) * (1 + 其他加成)
        --              (M        /          N)               *     other
        local M = FixMul(defShanbi, C_SHANBI)
        local N = FixAdd(defShanbi, FixMul(A_SHANBI, FLV(atkerLevel)))

        local prob = FixDiv(M, N)
        prob = FixMul(prob, FixAdd(1, f.shanbiProbAdd or 0))
        
        if prob > 1 then 
            prob = 1 
        elseif prob < 0 
            then prob = 0 
        end

        return prob
    end,

    --@f : Factor
    BaojiProb = function (isPhysic, atkerBaoji, defLevel, f)
        -- 物理暴击率=(攻方物理暴击等级*C/(守方f(lv)*A)+自有物理暴击率10%) * (1 + 其他加成)
        -- 魔法暴击率=(攻方法术暴击等级*C/(守方f(lv)*A)+自有法术暴击率10%) * (1 + 其他加成)
        --                  (M        /       N     +            0.1)  *   Other

        local C = isPhysic and C_PHYBAOJI or C_MAGICBAOJI
        local A = isPhysic and A_PHYBAOJI or A_MAGICBAOJI

        local otherAdd = isPhysic and (f.phyBaojiProbAdd or 0) or (f.magicBaojiProbAdd or 0)

        local M = FixMul(atkerBaoji, C)
        local N = FixMul(FLV(defLevel), A)

        local prob = FixAdd(FixDiv(M, N), 0.1)
        prob = FixMul(prob, FixAdd(1, otherAdd))

        if prob > 1 then 
            prob = 1 
        elseif prob < 0 then 
            prob = 0 
        end

        return prob
    end,

    --@atker,@target : Actor
    StatusRoundJudge = function (atker, target, skillLevel)
        if not target or not atker then
            return BattleEnum.ROUNDJUDGE_SHANBI
        end

        local tmp = target:GetLevel() - atker:GetLevel()
        if tmp < 0 then tmp = 0 end

        local hitProb = FixExp(FixMul(-0.05, tmp))
        local randVal = FixMod(BattleRander.Rand(), 1000)
        if randVal < FixMul(hitProb, 1000) then
            return BattleEnum.ROUNDJUDGE_NORMAL
        end
        
        -- todo target.ShowHPText(m_noHitStr, ROUNDJUDGE.SHANBI, HPCHGREASON.NONE);
        return BattleEnum.ROUNDJUDGE_SHANBI
    end,

    RoundJudgeHelper = function(randVal, atkerMingzhong, atkerLevel, defShanbi, atkerBaoji, defLevel, hurtType, factor, isBlind)
        if hurtType == BattleEnum.HURTTYPE_REAL_HURT then
            return BattleEnum.ROUNDJUDGE_NORMAL
        end

        local nonMingzhongProb = Formular.NonMingzhongProb(atkerMingzhong, defLevel, factor, isBlind)
        if nonMingzhongProb >= 1 then
            return BattleEnum.ROUNDJUDGE_NON_MINGZHONG
        end

        local shanbiProb = Formular.ShanbiProb(defShanbi, atkerLevel, factor)
        if FixAdd(nonMingzhongProb, shanbiProb) >= 1 then
            if randVal < FixFloor(FixMul(nonMingzhongProb, 1000)) then
                return BattleEnum.ROUNDJUDGE_NON_MINGZHONG
            end
            return BattleEnum.ROUNDJUDGE_SHANBI
        end

        local isPhy = hurtType == BattleEnum.HURTTYPE_PHY_HURT and true or false
        local baojiProb = Formular.BaojiProb(isPhy, atkerBaoji, defLevel, factor)

        local nonMZProb = FixFloor(FixMul(nonMingzhongProb, 1000))
        local sbProb = FixFloor(FixAdd(nonMZProb, FixMul(shanbiProb, 1000)))
        local bjProb = FixFloor(FixAdd(sbProb, FixMul(baojiProb, 1000)))

        if randVal < nonMZProb then
            return BattleEnum.ROUNDJUDGE_NON_MINGZHONG
        end

        if randVal < sbProb then
            return BattleEnum.ROUNDJUDGE_SHANBI
        end

        if randVal < bjProb then
            return BattleEnum.ROUNDJUDGE_BAOJI
        end

        return BattleEnum.ROUNDJUDGE_NORMAL
    end,

    AtkRoundJudge = function(atker, target, hurtType, showText, factor)
        if not atker or not target then
            FrameDebuggerInst:FrameRecord(BattleRecordEnum.EVENT_TYPE_ROUNDJUDGE, 999, 888, BattleEnum.ROUNDJUDGE_NON_MINGZHONG)
            return BattleEnum.ROUNDJUDGE_NON_MINGZHONG
        end

        if target:GetStatusContainer():IsWudi() then
            FrameDebuggerInst:FrameRecord(BattleRecordEnum.EVENT_TYPE_ROUNDJUDGE, atker:GetActorID(), target:GetActorID(), BattleEnum.ROUNDJUDGE_WUDI)
            target:ShowJudgeFloatMsg(BattleEnum.ROUNDJUDGE_IMMUNE)
            return BattleEnum.ROUNDJUDGE_WUDI
        end

        local atkerMingzhong = atker:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_MINGZHONG)
        local atkerLevel = atker:GetLevel()
        local defShanbi = target:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_SHANBI)
        local atkerBaoji = atker:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_MAGIC_BAOJI)
        if hurtType == BattleEnum.HURTTYPE_PHY_HURT then
            atkerBaoji = atker:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_PHY_BAOJI)
        end
        local defLevel = target:GetLevel()

        if not factor then
            factor = Formular.GetDefaultFactor()
        end
        
        -- 随机数放在这个位置，每次判定必消耗一个
        local randVal = FixMod(BattleRander.Rand(), 1000)
        local isBlind = false
        factor.mingzhongProbAdd = FixAdd(factor.mingzhongProbAdd, atker:GetData():GetProbValue(ACTOR_ATTR.MINGZHONG_PROB_CHG))
        factor.shanbiProbAdd = FixAdd(factor.shanbiProbAdd, target:GetData():GetProbValue(ACTOR_ATTR.SNAHBI_PROB_CHG))

        if atker:GetCamp() == BattleEnum.ActorCamp_LEFT and atker:GetLevel() <= 5 then
            factor.mingzhongProbAdd = FixAdd(factor.mingzhongProbAdd, 0.1)
        end

        factor.phyBaojiProbAdd = FixAdd(factor.phyBaojiProbAdd, atker:GetData():GetProbValue(ACTOR_ATTR.PHY_BAOJI_PROB_CHG))
        factor.magicBaojiProbAdd = FixAdd(factor.magicBaojiProbAdd, atker:GetData():GetProbValue(ACTOR_ATTR.MAGIC_BAOJI_PROB_CHG))

        local judge = Formular.RoundJudgeHelper(randVal, atkerMingzhong, atkerLevel, defShanbi, atkerBaoji, defLevel, hurtType, factor, isBlind)

        if showText then
            if judge == BattleEnum.ROUNDJUDGE_NON_MINGZHONG or judge == BattleEnum.ROUNDJUDGE_SHANBI then
                target:ShowJudgeFloatMsg(judge) 
            end
        end

        if judge == BattleEnum.ROUNDJUDGE_SHANBI then
            target:OnShanbi(atker) 
            atker:OnSBShanbi(target)
        end

        if judge == BattleEnum.ROUNDJUDGE_NON_MINGZHONG then
            target:OnNonMingZhong(atker)
            atker:OnAtkNonMingZhong(target)
        end

        FrameDebuggerInst:FrameRecord(BattleRecordEnum.EVENT_TYPE_ROUNDJUDGE, atker:GetActorID(), target:GetActorID(), judge)
        return judge
    end,

    GedangJudge = function(target, prob)
        -- todo
        local randVal = FixMod(BattleRander.Rand(), 1000)
        if randVal < FixMul(prob, 10) then
            target:ShowJudgeFloatMsg(BattleEnum.ROUNDJUDGE_GEDANG) 
            FrameDebuggerInst:FrameRecord(BattleRecordEnum.EVENT_TYPE_ROUNDJUDGE, 777, target:GetActorID(), BattleEnum.ROUNDJUDGE_GEDANG)
            return BattleEnum.ROUNDJUDGE_GEDANG
        end

        FrameDebuggerInst:FrameRecord(BattleRecordEnum.EVENT_TYPE_ROUNDJUDGE, 777, target:GetActorID(), BattleEnum.ROUNDJUDGE_NORMAL)
        return BattleEnum.ROUNDJUDGE_NORMAL
    end,

    DefMultiple = function(isPhysic, def, atkerLevel)
        -- 物理减伤比=守方护甲*C/(守方护甲+攻方f(lv)*A)
        -- 法术减伤比=守方魔抗*C/(守方魔抗+攻方f(lv)*A)
        --              M     /         def   +  N
        local C = isPhysic and C_PHYDEF or C_MAGICDEF
        local A = isPhysic and A_PHYDEF or A_MAGICDEF

        local M = FixMul(def, C)
        local N = FixMul(FLV(atkerLevel), A)
        local p = FixDiv(M, FixAdd(def, N))
        if p > 0.8 then p = 0.8 end

        return FixSub(1, p)
    end,

    CalcInjureHelper = function(judge, ATK_A, atk, f1, skillHurt, f2, baojiHurt, decMultiple, otherMultiple)
        -- hurt = (atk/ATK_A * f1 + skillHurt * f2) * decMultiple * otherMultiple

        -- new  hurt = (atk/ATK_A * skillHurt / 100) * decMultiple * otherMultiple
        local _atk = FixMul(FixDiv(atk, ATK_A), FixDiv(skillHurt, 100))
        local hurt = FixMul(FixMul(_atk, decMultiple), otherMultiple)

        if judge == BattleEnum.ROUNDJUDGE_BAOJI then
            if baojiHurt > 0 then
                hurt = FixMul(hurt, baojiHurt)
            end
        end
        
        if hurt <= 0 then hurt = 1 end
        return FixCeil(hurt)
    end,

    CalcDragonInjureHelper = function(judge, ATK_A, atk, f1, skillHurt, f2, baojiHurt, decMultiple, otherMultiple)
        local _atk = FixAdd(FixDiv(atk, ATK_A), FixMul(skillHurt, f2))
        local hurt = FixMul(FixMul(_atk, decMultiple), otherMultiple)

        if judge == BattleEnum.ROUNDJUDGE_BAOJI then
            if baojiHurt > 0 then
                hurt = FixMul(hurt, baojiHurt)
            end
        end
        
        if hurt <= 0 then hurt = 1 end
        return FixCeil(hurt)
    end,

    CalcDragonInjure = function(hurtType, atk, skillHurt)
        local ATK_A = hurtType ~= BattleEnum.HURTTYPE_PHY_HURT and A_MAGICATK or A_PHYATK 
        return Formular.CalcDragonInjureHelper(BattleEnum.ROUNDJUDGE_NORMAL, ATK_A, atk, 1, skillHurt, 1, 0, 1, 1)
    end,

    CalcInjure = function(atker, target, skillCfg, hurtType, judge, skillInjure, factor)
        if not atker or not target or not skillCfg then
            return 0
        end

        if judge == BattleEnum.ROUNDJUDGE_WUDI then
            return 0
        end

        if hurtType == BattleEnum.HURTTYPE_REAL_HURT then
            return skillInjure
        end

        if judge == BattleEnum.ROUNDJUDGE_NON_MINGZHONG or judge == BattleEnum.ROUNDJUDGE_SHANBI then
            return 0
        end

        local ATK_A = A_PHYATK 
        local atk = atker:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_PHY_ATK)
        local def = target:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_PHY_DEF) 
        local hurtOtherMul = atker:GetData():GetProbValue(ACTOR_ATTR.PHY_HURTOTHER_MULTIPLE)
        local behurtMul = target:GetData():GetProbValue(ACTOR_ATTR.PHY_BEHURT_MULTIPLE)
        -- local baojiMultiple = atker:GetData():GetProbValue(ACTOR_ATTR.PHY_BAOJI_HURT_MULTIPLE)
        
        if hurtType ~= BattleEnum.HURTTYPE_PHY_HURT then
            ATK_A = A_MAGICATK
            atk = atker:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_MAGIC_ATK)
            def = target:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_MAGIC_DEF)
            hurtOtherMul = atker:GetData():GetProbValue(ACTOR_ATTR.MAGIC_HURTOTHER_MULTIPLE)
            behurtMul = target:GetData():GetProbValue(ACTOR_ATTR.MAGIC_BEHURT_MULTIPLE)
            -- baojiMultiple = atker:GetData():GetProbValue(ACTOR_ATTR.MAGIC_BAOJI_HURT_MULTIPLE)            
        end

        def = atker:GetInscriptionSkillContainer():ChgTargetDef(skillCfg, def, hurtType)

        local hurtMul = atker:GetStatusContainer():GetHurtOtherMul(skillCfg.type)
        hurtOtherMul = FixMul(hurtOtherMul, hurtMul)

        local insHurtMul = atker:GetInscriptionSkillContainer():PreHurtOther(target, hurtType, skillCfg, judge)
        hurtOtherMul = FixMul(hurtOtherMul, insHurtMul)
        local insBeHurtMul = target:GetInscriptionSkillContainer():PreBeHurt(target, hurtType, skillCfg, judge)
        hurtOtherMul = FixMul(hurtOtherMul, insBeHurtMul)

        -- local horseHurtMul = atker:GetHorseSkillContainer():PreHurtOther(target, hurtType, skillCfg, judge)
        -- hurtOtherMul = FixMul(hurtOtherMul, horseHurtMul)
        -- local horseBeHurtMul = target:GetHorseSkillContainer():PreBeHurt(target, hurtType, skillCfg, judge)
        -- hurtOtherMul = FixMul(hurtOtherMul, horseBeHurtMul)

        if factor then
            if hurtType == BattleEnum.HURTTYPE_PHY_HURT then
                def = FixAdd(def, factor.chgPhyDef)
            elseif hurtType == BattleEnum.HURTTYPE_MAGIC_HURT then
                def = FixAdd(def, factor.chgMagicDef)
            end            
        end

        if atk <= 0 then atk = 1 end
        if def <= 0 then def = 1 end
        if hurtOtherMul <= 0 then hurtOtherMul = 1 end
        if behurtMul <= 0 then behurtMul = 1 end
        if behurtMul < 0.15 then behurtMul = 0.15 end

        local defMul = Formular.DefMultiple(true, def, atker:GetLevel())
        local otherMultiple = FixMul(hurtOtherMul, behurtMul) -- todo  status multiple
                                           
        local hurt = Formular.CalcInjureHelper(judge, ATK_A, atk, skillCfg.attrfactor, skillInjure, skillCfg.hurtfactor,
                                               atker:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_BAOJI_HURT), defMul, otherMultiple)
        
        -- if judge == BattleEnum.ROUNDJUDGE_BAOJI then
        --     if baojiMultiple > 0 then
        --         return FixFloor(FixMul(hurt, baojiMultiple))
        --     end
        -- end
        return hurt
    end,

    CalcRecover = function(hurtType, atker, target, skillCfg, skillInjure, factor)
        local atk = atker:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_MAGIC_ATK)
        if atk <= 0 then atk = 1 end

        local recover = FixMul(FixDiv(skillInjure, 100), atk)
        
        local isPhy = hurtType == BattleEnum.HURTTYPE_PHY_HURT and true or false        
        local atkerBaoji = 0
        if isPhy then
            atkerBaoji = atker:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_PHY_BAOJI)
        else
            atkerBaoji = atker:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_MAGIC_BAOJI)
        end
        
        if not factor then
            factor = Formular.GetDefaultFactor()
        end 

        local isBaoji = false

        local baojiProb = Formular.BaojiProb(isPhy, atkerBaoji, target:GetLevel(), factor)
        local randVal = FixMod(BattleRander.Rand(), 1000)
        if randVal < FixFloor(FixMul(baojiProb, 1000)) then
            isBaoji = true

            local baojiHurt = atker:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_BAOJI_HURT)
            if baojiHurt > 0 then
                recover = FixMul(recover, baojiHurt)
            end
        end
        
        return FixFloor(recover), isBaoji
    end,


    CalcHudunFactor = function(atker)
        local atk = atker:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_MAGIC_ATK)
        if atk <= 0 then atk = 1 end

        local ATK_A = A_MAGICATK

        return FixDiv(atk, ATK_A)
    end,


    SummonStatusRoundJudge = function(target, dragonLevel)
        if not target then
            FrameDebuggerInst:FrameRecord(BattleRecordEnum.EVENT_TYPE_ROUNDJUDGE, 3506, 0, BattleEnum.ROUNDJUDGE_SHANBI)
            return BattleEnum.ROUNDJUDGE_SHANBI
        end

        local deltaLevel = FixSub(target:GetLevel(), dragonLevel)
        deltaLevel = FixSub(deltaLevel, 30)
        if deltaLevel < 0 then
            deltaLevel = 0
        end

        local hitProb = FixMul(FixExp(FixMul(-0.05, deltaLevel)), 1000)
        local randVal = FixMod(BattleRander.Rand(), 1000)
        if randVal < hitProb then
            FrameDebuggerInst:FrameRecord(BattleRecordEnum.EVENT_TYPE_ROUNDJUDGE, 3506, target:GetActorID(), BattleEnum.ROUNDJUDGE_NORMAL)
            return BattleEnum.ROUNDJUDGE_NORMAL
        end

        -- TODO
        -- target.ShowHPText(m_noHitStr, ROUNDJUDGE.SHANBI, HPCHGREASON.NONE);

        FrameDebuggerInst:FrameRecord(BattleRecordEnum.EVENT_TYPE_ROUNDJUDGE, 3506, target:GetActorID(), BattleEnum.ROUNDJUDGE_SHANBI)
        return BattleEnum.ROUNDJUDGE_SHANBI
    end,

    
    CalcMaxHPInjure = function(skillInjure, target, injureType)
        -- x值/y值*3000*等级/100 ===== X*等级*30
        if not skillInjure or skillInjure == 0 or not target or not target:IsLive() then
            return 0 
        end

        local mul = 0
        if injureType == BattleEnum.MAXHP_INJURE_PRO_LOSTHP then -- 已损生命
            mul = 30

        elseif injureType == BattleEnum.MAXHP_INJURE_PRO_LEFTHP then -- 当前生命
            mul = 30

        elseif injureType == BattleEnum.MAXHP_INJURE_PRO_MAXHP then -- 最大生命
            mul = 20
        end

        local level = target:GetLevel()
        local maxValue = FixIntMul(FixMul(skillInjure, level), mul)
        return maxValue
    end
}










