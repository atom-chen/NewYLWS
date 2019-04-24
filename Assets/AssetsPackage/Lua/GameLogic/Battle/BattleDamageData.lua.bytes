-- 战损数据
local Vector3 = Vector3
local BattleDamageData = BaseClass("BattleDamageData")
-- todo
-- BattleDamageData.ActorType_Role = 1
-- BattleDamageData.ActorType_Summon = 2
-- BattleDamageData.ActorType_DUMMY_ROLE = 3

function BattleDamageData:__init(actorID, starID)
    self.m_actorID = actorID
    self.m_starID  = starID
    self.m_wujiangID  = 0
    self.m_camp = 0
    self.m_monsterID = 0
    self.m_isBoss = false
    self.m_level  = 0

    self.m_stage  = 0 -- 等阶  to do
    self.m_hurt   = 0 
    self.m_dropHP = 0 
    self.m_addHP  = 0 
    self.m_killCount = 0
    self.m_curWujiangPos = Vector3.zero
    self.m_leftNuqi = 0
    self.m_leftHP = 0
    self.m_wujiangSeq = 0
    self.m_maxHP = 0
end

function BattleDamageData:GetActorID()
    return self.m_actorID
end

function BattleDamageData:GetMonsterID()
    return self.m_monsterID
end

function BattleDamageData:GetIsBoss()
    return self.m_isBoss
end

function BattleDamageData:GetStage()
    return self.m_stage
end

function BattleDamageData:GetLevel()
    return self.m_level
end

function BattleDamageData:GetHurt()
    return self.m_hurt
end

function BattleDamageData:GetDropHP()
    return self.m_dropHP
end

function BattleDamageData:GetWuJiangID()
    return self.m_wujiangID
end

function BattleDamageData:GetAddHP()
    return self.m_addHP
end

function BattleDamageData:GetKillCount()
    return self.m_killCount
end

-- function BattleDamageData:GetActorRoleType()
--     return self.m_type
-- end

function BattleDamageData:GetPlayerName()
    return self.m_camp
end

function BattleDamageData:ChgStage(stage)
    self.m_stage = stage
end

function BattleDamageData:ChgHurt(delta)
    self.m_hurt = self.m_hurt + delta
end

function BattleDamageData:ChgDropHP(delta)
    self.m_dropHP = self.m_dropHP + delta
end

function BattleDamageData:ChgAddHP(delta)
    self.m_addHP = self.m_addHP + delta
end

function BattleDamageData:ChgKillCount(count)
    self.m_killCount = self.m_killCount + count
end

-- function BattleDamageData:ChgActorType(actorType)
--     self.m_type = actorType
-- end

function BattleDamageData:SetWuJiangID(wujiangID)
    self.m_wujiangID = wujiangID
end

function BattleDamageData:SetCamp(camp)
    self.m_camp = camp
end

function BattleDamageData:SetLevel(level)
    self.m_level = level
end

function BattleDamageData:SetMonsterID(monsterID)
    self.m_monsterID = monsterID
end

function BattleDamageData:IsBoss(isBoss)
    self.m_isBoss = isBoss
end

function BattleDamageData:SetLeftNuqi(nuqi)
    self.m_leftNuqi = nuqi
end

function BattleDamageData:GetLeftNuqi()
    return self.m_leftNuqi
end

function BattleDamageData:SetWujiangPos(x,y,z)
    self.m_curWujiangPos.x = x
    self.m_curWujiangPos.y = y
    self.m_curWujiangPos.z = z
end

function BattleDamageData:GetWujiangPos()
    return self.m_curWujiangPos
end

function BattleDamageData:GetWujiangSeq()
    return self.m_wujiangSeq
end

function BattleDamageData:SetWujiangSeq(seq)
    self.m_wujiangSeq = seq
end

function BattleDamageData:SetLeftHP(hp)
    self.m_leftHP = hp
end

function BattleDamageData:GetLeftHP()
    return self.m_leftHP
end

function BattleDamageData:SetMaxHP(max_hp)
    self.m_maxHP = max_hp
end

function BattleDamageData:GetMaxHP()
    return self.m_maxHP
end

return BattleDamageData