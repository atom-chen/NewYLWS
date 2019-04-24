

local BossMgr = BaseClass("BossMgr")
local table_insert = table.insert
local table_remove = table.remove


function BossMgr:__init()
    self.m_todayBossIndex = 1
    self.m_bossData = {}
    self.m_finishResult = nil
    self.m_bossId = 0

    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WORLDBOSS_RSP_WORLD_BOSS_INFO, Bind(self, self.RspWorldBossInfo))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WORLDBOSS_RSP_ENHANCE_ATK, Bind(self, self.RspEnHanceAtk))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WORLDBOSS_RSP_BUY_FIGHT_BOSS_TIME, Bind(self, self.RspBuyFightBossTime))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.COMMONRANK_RSP_WORLD_BOSS_RANK, Bind(self, self.RspWorldBossRank))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.COMMONRANK_RSP_WORLD_BOSS_RANK_YESTERDAY, Bind(self, self.RspWorldBossRankYesterday))
end


function BossMgr:SetBossFinishFight(finishResult)
    self.m_finishResult = finishResult
end

function BossMgr:GetBossFinishFight()
    return self.m_finishResult
end

function BossMgr:ResetBossFinishFight()
    self.m_finishResult = nil
end

function BossMgr:GetBossID()
    return self.m_bossId 
end

function BossMgr:RspWorldBossInfo(msg_obj)
    if not msg_obj or not msg_obj.result == 0 then
        return
    end

    self.m_todayBossIndex = msg_obj.boss_index
    self.m_bossData = msg_obj
    self.m_bossId = msg_obj.boss_id

    UIManagerInst:Broadcast(UIMessageNames.MN_BOSS_RSP_WORLDBOSSINFO, msg_obj, self.m_finishResult)
    self.m_finishResult = nil
end


function BossMgr:RspEnHanceAtk(msg_obj)
    if not msg_obj or not msg_obj.result == 0 then
        return
    end

    self.m_bossData.enhanced_atk = msg_obj.enhanced_atk
    UIManagerInst:Broadcast(UIMessageNames.MN_BOSS_RSP_ENHANCEATK, msg_obj)
end


function BossMgr:RspBuyFightBossTime(msg_obj)
    if not msg_obj or not msg_obj.result == 0 then
        return
    end

    self.m_bossData.left_fight_boss_count = msg_obj.left_fight_boss_count
    self.m_bossData.can_buy_fight_boss_count = msg_obj.can_buy_fight_boss_count
    UIManagerInst:Broadcast(UIMessageNames.MN_BOSS_RSP_BUYFIGHTBOSS_TIME, msg_obj)
end

function BossMgr:RspWorldBossRank(msg_obj)
    if not msg_obj or not msg_obj.result == 0 then
        return
    end

    UIManagerInst:Broadcast(UIMessageNames.MN_BOSS_RSP_WORLDBOSS_RANK, msg_obj)
end

function BossMgr:RspWorldBossRankYesterday(msg_obj)
    if not msg_obj or not msg_obj.result == 0 then
        return
    end
    UIManagerInst:Broadcast(UIMessageNames.MN_BOSS_RSP_WORLDBOSS_RANK_YESTERDAY, msg_obj)
end

function BossMgr:GetTodayBattleType()
    local cfg = ConfigUtil.GetWorldBossCfgByID(self.m_todayBossIndex)
    if cfg then
        return cfg.battle_type
    end
    return 0
end

return BossMgr