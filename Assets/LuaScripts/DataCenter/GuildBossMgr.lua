

local GuildBossMgr = BaseClass("GuildBossMgr")
local table_insert = table.insert
local table_remove = table.remove
local table_sort = table.sort

function GuildBossMgr:__init()
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.GUILD_RSP_ALL_GUILD_BOSS_INFO, Bind(self, self.RspGuildBossInfo))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.GUILD_RSP_GUILD_BOSS_RANK_LIST, Bind(self, self.RspGuildBossRankInfo))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.GUILD_RSP_BUY_BUFF, Bind(self, self.RspBuyBuff))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.GUILD_RSP_RESET_BOSS, Bind(self, self.RspResetBoss))
    self.m_bossCfg = nil
    self.m_finishBattleMsg = nil
    self.m_enterBattleMsg = nil
end

function GuildBossMgr:ReqGuildBossInfo()
    local msg_id = MsgIDDefine.GUILD_REQ_ALL_GUILD_BOSS_INFO
	local msg = (MsgIDMap[msg_id])()
	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function GuildBossMgr:RspGuildBossInfo(msg_obj)
    if not msg_obj or not msg_obj.result == 0 then
        return
    end
    self.m_enterBattleMsg = msg_obj
    -- GameObjectPoolInst:GetGameObjectAsync(TheGameIds.GuildBossBgPath, function(go)
    --     if go then
    --         UIManagerInst:OpenWindow(UIWindowNames.UIGuildBoss, go)
    --         --UIManagerInst:Broadcast(UIMessageNames.MN_GUILDBOSS_RSP_BOSSINFO, go)
    --     end
    -- end)
    UIManagerInst:Broadcast(UIMessageNames.MN_GUILD_RSP_ALL_GUILD_BOSS_INFO, msg_obj)
end

function GuildBossMgr:RspGuildBossRankInfo(msg_obj)
    if not msg_obj or not msg_obj.result == 0 then
        return
    end
    UIManagerInst:Broadcast(UIMessageNames.MN_GUILDBOSS_RSP_BOSSRANKINFO, msg_obj)
end

function GuildBossMgr:RspBuyBuff(msg_obj)
    if not msg_obj or not msg_obj.result == 0 then
        return
    end
    UIManagerInst:Broadcast(UIMessageNames.MN_GUILDBOSS_BUYBUFF, msg_obj)
end

function GuildBossMgr:RspResetBoss(msg_obj)
    if not msg_obj or not msg_obj.result == 0 then
        return
    end
    UIManagerInst:Broadcast(UIMessageNames.MN_GUILDBOSS_RESETBOSS, msg_obj)
end

function GuildBossMgr:SetBossCfg(cfg)
    self.m_bossCfg = cfg
end

function GuildBossMgr:GetBossCfg()
    return self.m_bossCfg
end

function GuildBossMgr:SetFinishBattleMsg(msg)
    self.m_finishBattleMsg = msg
end

function GuildBossMgr:GetFinishBattleMsg()
    return self.m_finishBattleMsg
end

function GuildBossMgr:GetEnterBattleMsg()
    return self.m_enterBattleMsg
end

return GuildBossMgr