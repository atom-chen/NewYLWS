local guildWarMgr = Player:GetInstance():GetGuildWarMgr()
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance() 
local GuildWarTaskItemClass = require "UI.GuildWar.GuildWarEscortTaskItem"
local table_insert = table.insert
local GameObject = CS.UnityEngine.GameObject

local GuildWarEscortTaskView = BaseClass("GuildWarEscortTaskView", UIBaseView)
local base = UIBaseView 

function GuildWarEscortTaskView:OnCreate()
    base.OnCreate(self)
    self.m_husongMissionInfoList = nil
    self.m_todayHuSongCount = 0
    self.m_guildHuSongProgress = 0
    self.m_guildHuSongProMax = 0

    self.m_taskItemList = {}
    self.m_itemLoaderSeq = 0
    self.m_updateInterval = 0

    self:InitView()
    self:HandleClick()

end

function GuildWarEscortTaskView:InitView()
    self.m_blackBgTr,
    self.m_closeBtnTr,
    self.m_taskItemContentTr, self.m_taskItemPrefab = UIUtil.GetChildTransforms(self.transform, {
        "BlackBg",
        "CloseBtn",
        "Panel/TaskItemContent",
        "TaskItemPrefab"
    })

    self.m_taskItemPrefab = self.m_taskItemPrefab.gameObject

    self.m_titleTxt,
    self.m_todayCountTxt,
    self.m_sliderValueTxt = UIUtil.GetChildTexts(self.transform, { 
        "Panel/TitleBg/TitleTxt",
        "Panel/TodayCount",
        "Panel/ProgressSlider/SliderValueTxt",
    })  
    self.m_progressSlider = UIUtil.FindSlider(self.transform, "Panel/ProgressSlider") 

    self.m_sliderFiilImg = UIUtil.AddComponent(UIImage, self, "Panel/ProgressSlider/FillImg", AtlasConfig.DynamicLoad)

    self.m_titleTxt.text = Language.GetString(2370)
end

function GuildWarEscortTaskView:OnEnable(...)
    base.OnEnable(self, ...) 
    guildWarMgr:ReqHuSongPanel() 
end

function GuildWarEscortTaskView:Update()
    if self.m_updateInterval > 0 then
        self.m_updateInterval = self.m_updateInterval - Time.deltaTime
        if self.m_updateInterval <= 0 then
            if self.m_taskItemList then
                for i, v in ipairs(self.m_taskItemList) do
                    if v then
                        v:Update()
                    end
                end
            end
            self.m_updateInterval = 1
        end
    end
end

function GuildWarEscortTaskView:OnHuSongPanel(husong_panel)
    if not husong_panel then
        return
    end 
    self.m_husongMissionInfoList = husong_panel.husong_mission_list 
    self.m_todayHuSongCount = math.floor(husong_panel.today_husong_count_limit - husong_panel.today_husong_count)  
    self.m_guildHuSongProgress = math.floor(husong_panel.guild_husong_progress)
    self.m_guildHuSongProMax = math.floor(husong_panel.guild_husong_progress_max) 
    self.m_curr_husong_mission = husong_panel.curr_husong_mission

    self:UpdateData()

    self.m_updateInterval = 1
end

function GuildWarEscortTaskView:UpdateData() 
    self.m_sliderValueTxt.text = string.format(Language.GetString(2371), self.m_guildHuSongProgress, self.m_guildHuSongProMax)
    local percent = self.m_guildHuSongProgress / self.m_guildHuSongProMax
    if percent >= 1 then
        percent = 1
    end
   
    if percent < 0.7 then
        self.m_sliderFiilImg:SetAtlasSprite("st01.png")  
    elseif percent >= 0.7 and percent < 1 then
        self.m_sliderFiilImg:SetAtlasSprite("beibao10.png") 
    else
        self.m_sliderFiilImg:SetAtlasSprite("st03.png") 
    end 
    self.m_progressSlider.value = percent 
    self.m_todayCountTxt.text = string.format(Language.GetString(2372), self.m_todayHuSongCount)  

    self:CreateTaskItem()
end

function GuildWarEscortTaskView:CreateTaskItem()
    if self.m_husongMissionInfoList then
        for i, v in ipairs(self.m_husongMissionInfoList) do 
            local taskItem = self.m_taskItemList[i]
            if not taskItem then
                local go = GameObject.Instantiate(self.m_taskItemPrefab)
                taskItem = GuildWarTaskItemClass.New(go, self.m_taskItemContentTr)
                table_insert(self.m_taskItemList, taskItem)
            end

            taskItem:UpdateData(v, self.m_curr_husong_mission)
        end
    end
end

function GuildWarEscortTaskView:OnTakeAward(husongID)
    if husongID then
        for i = 1, #self.m_taskItemList do
            local isMatchId = self.m_taskItemList[i]:GetHuSongID() == husongID
            if isMatchId then
                self.m_taskItemList[i]:SetAwardBtnUnActiveStatus()
            end
        end
    end
end

function GuildWarEscortTaskView:OnAddListener()
	base.OnAddListener(self)
	
    self:AddUIListener(UIMessageNames.MN_GUILDWAR_RSP_HUSONG_PANEL, self.OnHuSongPanel) 
    self:AddUIListener(UIMessageNames.MN_GUILDWAR_RSP_TAKE_HUSONG_AWARD, self.OnTakeAward)
    self:AddUIListener(UIMessageNames.MN_GUILDWAR_HUSONG_INVITE, self.OnInvite)
end

function GuildWarEscortTaskView:OnRemoveListener()
	base.OnRemoveListener(self)
	
    self:RemoveUIListener(UIMessageNames.MN_GUILDWAR_RSP_HUSONG_PANEL, self.OnHuSongPanel) 
    self:RemoveUIListener(UIMessageNames.MN_GUILDWAR_RSP_TAKE_HUSONG_AWARD, self.OnTakeAward)
    self:RemoveUIListener(UIMessageNames.MN_GUILDWAR_HUSONG_INVITE, self.OnInvite)
end 

function GuildWarEscortTaskView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)
    UIUtil.AddClickEvent(self.m_blackBgTr.gameObject, onClick)  
    UIUtil.AddClickEvent(self.m_closeBtnTr.gameObject, onClick) 
end

function GuildWarEscortTaskView:OnClick(go, x, y)
    if go.name == "BlackBg" or go.name == "CloseBtn" then
        self:CloseSelf()
    end
end 

function GuildWarEscortTaskView:OnDisable()
    if self.m_taskItemList then
        for i = 1,#self.m_taskItemList do
            self.m_taskItemList[i]:Delete()
        end

        self.m_taskItemList = {}
    end
    
    base.OnDisable(self)
end

function GuildWarEscortTaskView:OnDestroy() 
    UIUtil.RemoveClickEvent(self.m_blackBgTr.gameObject)  
    UIUtil.RemoveClickEvent(self.m_closeBtnTr.gameObject) 

    base.OnDestroy(self)
end

function GuildWarEscortTaskView:OnInvite()
    guildWarMgr:ReqHuSongPanel()
end

return GuildWarEscortTaskView
