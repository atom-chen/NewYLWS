local table_insert = table.insert
local table_remove = table.remove
local table_sort = table.sort
local CommonDefine = CommonDefine

local GamePromptMgr = BaseClass("GamePromptMgr", Singleton)

function GamePromptMgr:__init()
    self.m_delayTime = 0
    self.m_promptList = {}
    self.m_curPrompt = nil
    self.m_index = 0
end

function GamePromptMgr:Update(deltaTime)
    if self.m_delayTime > 0 then
        self.m_delayTime = self.m_delayTime - deltaTime
        if self.m_delayTime <= 0 then
            self.m_delayTime = 0

            if #self.m_promptList > 0 then
                self.m_curPrompt = self.m_promptList[1]
                table_remove(self.m_promptList, 1)
                self:DelayShow()
            end
        end
    end
end

function GamePromptMgr:InstallPrompt(promptType, data)
    local promptInfo = {
        type = promptType,
        data = data,
        index = self.m_index,
    }
    self.m_index = self.m_index + 1

    table_insert(self.m_promptList, promptInfo)

    self:Sort()
end

function GamePromptMgr:Sort()
    table_sort(self.m_promptList, function(l, r)
        if l.type > r.type then
            return true
        elseif l.type < r.type then
            return false
        else
            if l.index > r.index then
                return true
            else
                return false
            end
        end
    end)
end

function GamePromptMgr:DelayShow()
    if self.m_curPrompt.type == CommonDefine.PROMPT_TYPE_LEVEL_UP then
        UIManagerInst:OpenWindow(UIWindowNames.UIZhuGongLevelUp, self.m_curPrompt.data)
    elseif self.m_curPrompt.type == CommonDefine.ARENA_RANK_LEVEL_UP then
        UIManagerInst:OpenWindow(UIWindowNames.UIArenaMain, self.m_curPrompt.data + 1)
        UIManagerInst:OpenWindow(UIWindowNames.UIArenaLevelUp, self.m_curPrompt.data)
    elseif self.m_curPrompt.type == CommonDefine.GUILD_BOSS_BACK_SETTLE then
        UIManagerInst:OpenWindow(UIWindowNames.UIGuildBossBackSettlement, self.m_curPrompt.data)
    elseif self.m_curPrompt.type == CommonDefine.LIEZHUAN_INVITE_TEAM then
        Player:GetInstance():GetLieZhuanMgr():CheckCacheInvite()
    elseif self.m_curPrompt.type == CommonDefine.LIEZHUAN_TEAM_FIGHT_END then
        Player:GetInstance():GetLieZhuanMgr():ReqZhuanWatchBattleFinish()    
    end
end

function GamePromptMgr:ClearCurPrompt()
    self.m_curPrompt = nil
end

function GamePromptMgr:IsPromptListEmpty()
    return #self.m_promptList == 0
end

function GamePromptMgr:ShowPrompt()
    if self.m_curPrompt ~= nil or SceneManagerInst:IsLoadingScene()
        or SceneManagerInst:IsBattleScene() then
		return
    end
    if self:IsPromptListEmpty() then
        UIManagerInst:OnPromptClear()
    else
        self.m_delayTime = 0.1
    end
end


function GamePromptMgr:Clear()
    self.m_curPrompt = nil
    self.m_delayTime = 0
    self.m_promptList = {}
end


return GamePromptMgr