local FixAdd = FixMath.add
local ACTOR_ATTR = ACTOR_ATTR
local BattleRecordEnum = BattleRecordEnum

local FightData = BaseClass("FightData")

function FightData:__init()
    self.m_fightAttrs = {
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    }
    self.m_fightProbs = { 
        [ACTOR_ATTR.PHY_HURTOTHER_MULTIPLE]      = 1,
        [ACTOR_ATTR.MAGIC_HURTOTHER_MULTIPLE]    = 1,
        [ACTOR_ATTR.PHY_BEHURT_MULTIPLE]         = 1,
        [ACTOR_ATTR.MAGIC_BEHURT_MULTIPLE]       = 1,
        [ACTOR_ATTR.MINGZHONG_PROB_CHG]          = 0,
        [ACTOR_ATTR.SNAHBI_PROB_CHG]             = 0,
        [ACTOR_ATTR.PHY_BAOJI_PROB_CHG]          = 0,
        [ACTOR_ATTR.MAGIC_BAOJI_PROB_CHG]        = 0,
    }

    self.m_nuqi = 0
    self.m_selfActor = false
end

function FightData:InitOwner(actor)
    self.m_selfActor = actor
end

function FightData:__delete()
    self.m_selfActor = nil
end

function FightData:GetNuqi()
    return self.m_nuqi
end

function FightData:SetNuqi(nuqi)
    self.m_nuqi = nuqi
end

function FightData:ChgNuqi(chg)
    self.m_nuqi = FixAdd(self.m_nuqi, chg)
end

function FightData:GetAttrValue(attr)
    if ACTOR_ATTR.IsProbAttr(attr) or ACTOR_ATTR.IsFightAttr(attr) or ACTOR_ATTR.IsBaseAttr(attr) then
        return self.m_fightAttrs[attr] or 0
    end
    return 0
end

function FightData:SetAttrValue(attr, val)
    self.m_fightAttrs[attr] = val
end

function FightData:AddBaseAttr(attr, val)
    if ACTOR_ATTR.IsBaseAttr(attr) then
        local old = self.m_fightAttrs[attr] or 0
        self.m_fightAttrs[attr] = FixAdd(old, val)
    end
end

function FightData:AddFightAttr(attr, val, isShow)
    if ACTOR_ATTR.IsFightAttr(attr) then
        local old = self.m_fightAttrs[attr] or 0
        local new = FixAdd(old, val)
        self.m_fightAttrs[attr] = new

        self:OnAttrChg(attr, old, new, isShow)

        if attr ~= ACTOR_ATTR.FIGHT_HP then
            FrameDebuggerInst:FrameRecord(BattleRecordEnum.EVENT_TYPE_WUJIANG_ATTR, self.m_selfActor:GetActorID(), attr, old, new)
        end
    elseif ACTOR_ATTR.IsProbAttr(attr) then


        local old = self.m_fightProbs[attr]
        local new = FixAdd(old, val)
        self.m_fightProbs[attr] = new

        self:OnAttrChg(attr, old, new)
        FrameDebuggerInst:FrameRecord(BattleRecordEnum.EVENT_TYPE_WUJIANG_ATTR, self.m_selfActor:GetActorID(), attr, old, new)
    end
end


function FightData:AddFightAttrList(attrList)
    for attr, val in pairs(attrList) do
        self:AddFightAttr(attr, val)
    end
end

-- function FightData:AddProbAttr(attr, val)
--     if ACTOR_ATTR.IsProbAttr(attr) then
--         local old = self.m_fightProbs[attr]
--         self.m_fightProbs[attr] = FixAdd(old, val)

--         self:OnAttrChg(attr, old, new)
--         FrameDebuggerInst:FrameRecord(BattleRecordEnum.EVENT_TYPE_WUJIANG_ATTR, self.m_selfActor:GetActorID(), attr, old, new)
--     end
-- end

function FightData:GetProbValue(attr)
    if ACTOR_ATTR.IsProbAttr(attr) then
        return self.m_fightProbs[attr]
    end
    return 0
end

function FightData:SetProbValue(attr, val)
    self.m_fightProbs[attr] = val
end

function FightData:PutBaseToFight(curHP)
    self.m_fightAttrs[ACTOR_ATTR.FIGHT_MAXHP] = self.m_fightAttrs[ACTOR_ATTR.BASE_MAXHP] 
    self.m_fightAttrs[ACTOR_ATTR.FIGHT_HP] = curHP == 0 and self.m_fightAttrs[ACTOR_ATTR.FIGHT_MAXHP] or curHP
    self.m_fightAttrs[ACTOR_ATTR.FIGHT_PHY_ATK] = self.m_fightAttrs[ACTOR_ATTR.BASE_PHY_ATK]
    self.m_fightAttrs[ACTOR_ATTR.FIGHT_PHY_DEF] = self.m_fightAttrs[ACTOR_ATTR.BASE_PHY_DEF]
    self.m_fightAttrs[ACTOR_ATTR.FIGHT_MAGIC_ATK] = self.m_fightAttrs[ACTOR_ATTR.BASE_MAGIC_ATK]
    self.m_fightAttrs[ACTOR_ATTR.FIGHT_MAGIC_DEF] = self.m_fightAttrs[ACTOR_ATTR.BASE_MAGIC_DEF]
    self.m_fightAttrs[ACTOR_ATTR.FIGHT_PHY_BAOJI] = self.m_fightAttrs[ACTOR_ATTR.BASE_PHY_BAOJI]
    self.m_fightAttrs[ACTOR_ATTR.FIGHT_MAGIC_BAOJI] = self.m_fightAttrs[ACTOR_ATTR.BASE_MAGIC_BAOJI]
    self.m_fightAttrs[ACTOR_ATTR.FIGHT_SHANBI] = self.m_fightAttrs[ACTOR_ATTR.BASE_SHANBI]
    self.m_fightAttrs[ACTOR_ATTR.FIGHT_MINGZHONG] = self.m_fightAttrs[ACTOR_ATTR.BASE_MINGZHONG]
    self.m_fightAttrs[ACTOR_ATTR.FIGHT_MOVESPEED] = self.m_fightAttrs[ACTOR_ATTR.BASE_MOVESPEED]
    self.m_fightAttrs[ACTOR_ATTR.FIGHT_ATKSPEED] = self.m_fightAttrs[ACTOR_ATTR.BASE_ATKSPEED]
    self.m_fightAttrs[ACTOR_ATTR.FIGHT_HP_RECOVER] = self.m_fightAttrs[ACTOR_ATTR.BASE_HP_RECOVER]
    self.m_fightAttrs[ACTOR_ATTR.FIGHT_NUQI_RECOVER] = self.m_fightAttrs[ACTOR_ATTR.BASE_NUQI_RECOVER]
    self.m_fightAttrs[ACTOR_ATTR.FIGHT_BAOJI_HURT] = self.m_fightAttrs[ACTOR_ATTR.BASE_BAOJI_HURT]
    self.m_fightAttrs[ACTOR_ATTR.FIGHT_PHY_SUCKBLOOD] = self.m_fightAttrs[ACTOR_ATTR.BASE_PHY_SUCKBLOOD]
    self.m_fightAttrs[ACTOR_ATTR.FIGHT_MAGIC_SUCKBLOOD] = self.m_fightAttrs[ACTOR_ATTR.BASE_MAGIC_SUCKBLOOD]
    self.m_fightAttrs[ACTOR_ATTR.FIGHT_REDUCE_CD] = self.m_fightAttrs[ACTOR_ATTR.BASE_REDUCE_CD]
end

function FightData:OnAttrChg(attr, oldVal, newVal, isShow)
    if isShow == nil then 
        isShow = true 
    end

    if oldVal == newVal then
        return
    end

    self.m_selfActor:OnAttrChg(attr, oldVal, newVal)
    
    if isShow then
        local comp = self.m_selfActor:GetComponent()
        if comp then
            comp:ShowAttr(attr, oldVal, newVal)
        end
    end
end

return FightData
