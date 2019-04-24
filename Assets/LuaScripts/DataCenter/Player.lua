local table_insert = table.insert

local wujiangMgrClass = require("DataCenter.WuJiangMgr")
local loginMgrClass = require("DataCenter.LoginManager")
local userMgrClass = require("DataCenter.UserManager")
local itemMgrClass = require("DataCenter.ItemMgr")
local mountMgrClass = require("DataCenter.MountMgr")
local shenbingMgrClass = require("DataCenter.ShenBingMgr")
local inscriptionMgrClass =  require("DataCenter.InscriptionMgr")
local lineupMgrClass = require("DataCenter.LineupManager")
local CampsRushMgrClass = require("DataCenter.CampsRushManager")
local arenaMgrClass = require("DataCenter.ArenaMgr")
local bossMgrClass = require("DataCenter.BossMgr")
local shenbingCopyMgrClass = require("DataCenter.ShenbingCopyManager")
local videoMgrClass = require("DataCenter.VideoMgr")
local MainlineManagerClass = require("DataCenter.MainlineManager")
local emailMgrClass = require("DataCenter.EmailMgr")
local guildMgrClass = require("DataCenter.GuildMgr")
local friendMgrClass = require("DataCenter.FriendMgr")
local guildBossMgrClass = require("DataCenter.GuildBossMgr")
local commonRankMgrClass = require("DataCenter.CommonRankMgr")
local chatMgrClass = require("DataCenter.ChatMgr")
local graveMgrClass = require("DataCenter.GraveMgr")
local taskMgrClass = require("DataCenter.TaskMgr")
local yuanmenMgrClass = require("DataCenter.YuanmenMgr")
local dianjiangMgrClass = require("DataCenter.DianjiangMgr")
local ShopMgrClass = require("DataCenter.ShopManager")
local GodBeastMgrClass = require("DataCenter.GodBeastMgr")
local GuildWarMgrClass = require("DataCenter.GuildWarMgr")
local LieZhuanMgrClass = require("DataCenter.LieZhuanMgr")
local FuliMgrClass = require("DataCenter.FuliMgr")
local ActMgrClass = require("DataCenter.ActivityMgr")
local GroupHerosMgrClass = require("DataCenter.GroupHerosWarMgr")
local HorseRaceMgrClass = require("DataCenter.HorseRaceMgr")

local Player = BaseClass("Player", Singleton)

function Player:__init()
    self.m_isAppPause = false
    self.m_isGameInit = false
    self.m_isFirstIn = true 
    self.m_serverTime = 0
    self.m_modules = {}

    -- 这里先这样区分，如果后面还有其他逻辑服务器不需要的，就分一个BasePlayer和ClientPlayer
    if Config.IsClient or Config.IsSyncTest then
        self:ModulesInit()
    end
end

function Player:ModulesInit()
    self.WujiangMgr = self:InitSingleModule(wujiangMgrClass)
    self.m_loginMgr = self:InitSingleModule(loginMgrClass)
    self.m_userMgr = self:InitSingleModule(userMgrClass)
    self.m_itemMgr = self:InitSingleModule(itemMgrClass)
    self.m_mountMgr = self:InitSingleModule(mountMgrClass)
    self.m_shenbingMgr = self:InitSingleModule(shenbingMgrClass)
    self.InscriptionMgr = self:InitSingleModule(inscriptionMgrClass)
    self.m_lineupMgr = self:InitSingleModule(lineupMgrClass)
    self.m_campsRushMgr = self:InitSingleModule(CampsRushMgrClass)
    self.m_arenaMgr = self:InitSingleModule(arenaMgrClass)
    self.m_bossMgr = self:InitSingleModule(bossMgrClass)
    self.m_shenbingcopyMgr = self:InitSingleModule(shenbingCopyMgrClass)
    self.m_videoMgr = self:InitSingleModule(videoMgrClass)
    self.m_mainlineMgr = self:InitSingleModule(MainlineManagerClass)
    self.m_emailMgr = self:InitSingleModule(emailMgrClass)
    self.GuildMgr = self:InitSingleModule(guildMgrClass)
    self.m_friendMgr = self:InitSingleModule(friendMgrClass)
    self.m_guildBossMgr = self:InitSingleModule(guildBossMgrClass)
    self.m_commonRankMgr = self:InitSingleModule(commonRankMgrClass)
    self.m_chatMgr = self:InitSingleModule(chatMgrClass)
    self.m_graveMgr = self:InitSingleModule(graveMgrClass)
    self.m_taskMgr = self:InitSingleModule(taskMgrClass)
    self.m_yuanmenMgr = self:InitSingleModule(yuanmenMgrClass)
    self.m_dianjiangMgr = self:InitSingleModule(dianjiangMgrClass)
    self.m_shopMgr = self:InitSingleModule(ShopMgrClass)
    self.m_GodBeastMgr = self:InitSingleModule(GodBeastMgrClass)
    self.m_guildWarMgr = self:InitSingleModule(GuildWarMgrClass)
    self.m_LieZhuanMgr = self:InitSingleModule(LieZhuanMgrClass)
    self.m_fuliMgr = self:InitSingleModule(FuliMgrClass)
    self.m_actMgr = self:InitSingleModule(ActMgrClass)
    self.m_groupHerosMgr = self:InitSingleModule(GroupHerosMgrClass)
    self.m_horseRaceMgr = self:InitSingleModule(HorseRaceMgrClass)
end

function Player:InitSingleModule(moduleClass)
    local moduleMgr = moduleClass.New()
    table_insert(self.m_modules, moduleMgr)
    return moduleMgr
end

function Player:Dispose()
    for i, v in ipairs(self.m_modules) do
        v:Dispose()
    end
end

function Player:GetGroupHerosMgr()
    return self.m_groupHerosMgr
end

function Player:GetActMgr()
    return self.m_actMgr
end

function Player:GetFuliMgr()
    return self.m_fuliMgr
end

function Player:GetLoginMgr()
    return self.m_loginMgr
end

function Player:GetUserMgr()
    return self.m_userMgr
end

function Player:GetItemMgr()
    return self.m_itemMgr
end

function Player:GetMountMgr()
    return self.m_mountMgr
end

function Player:GetShenBingMgr()
    return self.m_shenbingMgr
end

function Player:GetLineupMgr()
    return self.m_lineupMgr
end

function Player:GetWujiangMgr()
    return self.WujiangMgr
end

function Player:GetCampsRushMgr()
    return self.m_campsRushMgr
end

function Player:GetShenbingCopyMgr()
    return self.m_shenbingcopyMgr
end

function Player:GetArenaMgr()
    return self.m_arenaMgr
end

function Player:GetBossMgr()
    return self.m_bossMgr
end

function Player:GetEmailMgr()
    return self.m_emailMgr
end

function Player:GetVideoMgr()
    return self.m_videoMgr
end

function Player:GetMainlineMgr()
    return self.m_mainlineMgr
end

function Player:GetFriendMgr()
    return self.m_friendMgr
end

function Player:GetGuildBossMgr()
    return self.m_guildBossMgr
end

function Player:GetCommonRankMgr()
    return self.m_commonRankMgr
end

function Player:GetChatMgr()
    return self.m_chatMgr
end

function Player:GetYuanmenMgr()
    return self.m_yuanmenMgr
end

function Player:GetDianjiangMgr()
    return self.m_dianjiangMgr
end

function Player:GetGraveMgr()
    return self.m_graveMgr
end

function Player:GetTaskMgr()
    return self.m_taskMgr
end

function Player:GetShopMgr()
    return self.m_shopMgr
end

function Player:GetGodBeastMgr()
    return self.m_GodBeastMgr
end

function Player:GetGuildWarMgr()
    return self.m_guildWarMgr
end

function Player:GetLieZhuanMgr()
    return self.m_LieZhuanMgr
end

function Player:GetHorseRaceMgr()
    return self.m_horseRaceMgr
end

function Player:IsAppPause()
    return self.m_isAppPause
end

function Player:SetAppPause(isPause)
    self.m_isAppPause = isPause
end

function Player:IsGameInit()
    return self.m_isGameInit
end

function Player:SetGameInit(isInit)
    self.m_isGameInit = isInit
end

function Player:GetServerTime()
    return self.m_serverTime
end

function Player:SetServerTime(servertime)
    self.m_serverTime = servertime
end

function Player:IsFirstIn()
    return self.m_isFirstIn
end

function Player:SetFirstIn(value)
    self.m_isFirstIn = value
end

return Player