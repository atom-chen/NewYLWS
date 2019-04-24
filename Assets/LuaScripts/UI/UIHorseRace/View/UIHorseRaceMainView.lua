local GameObject = CS.UnityEngine.GameObject
local table_insert = table.insert
local string_format = string.format
local math_ceil = math.ceil
local HorseRaceUserItemPath = "UI/Prefabs/HorseRace/HorseRaceUserItem.prefab"
local HorseRaceUserItem = require "UI.UIHorseRace.View.HorseRaceUserItem"
local UIGameObjectLoader = UIGameObjectLoader:GetInstance()
local HorseRaceMgr = Player:GetInstance():GetHorseRaceMgr()
local UIHorseRaceMainView = BaseClass("UIHorseRaceMainView", UIBaseView)
local base = UIBaseView

local RACE_MEMBER_COUNT = 8
local MAX_FREE_TIME = 3
local RaceStateEnum = {
    OnlyShow = 0,       --仅显示比赛信息未参加
    Matching = 1,       --匹配中
    WaitRace = 2,       --匹配完成等待开始
    FightComplete = 3,  --战斗完成
    Checked = 4,        --已经查看
}

function UIHorseRaceMainView:OnCreate()
    base.OnCreate(self)
    self:InitView()
end

function UIHorseRaceMainView:InitView()
    self.m_closeBtn, self.m_backBtn, self.m_rulerBtn, self.m_applyBtn, self.m_startRaceBtn,
    self.m_memberContent, self.m_yuanbaoImage = UIUtil.GetChildRectTrans(self.transform, {
        "closeBtn",
        "Container/top/backBtn",
        "Container/top/rulerBtn",
        "Container/bottom/applyBtn",
        "Container/bottom/startRaceBtn",
        "Container/mid/memberContent",
        "Container/bottom/yuanbaoImage",
    })

    local titleText, startRaceText, applyBtnText
    titleText, startRaceText, applyBtnText, self.m_matchingText,
    self.m_freeTimeText, self.m_costText = UIUtil.GetChildTexts(self.transform, {
        "Container/top/titleBg/titleText",
        "Container/bottom/startRaceBtn/startRaceBtnText",
        "Container/bottom/applyBtn/applyBtnText",
        "Container/bottom/matchingText",
        "Container/bottom/freeTimeText",
        "Container/bottom/yuanbaoImage/costText",
    })

    titleText.text = Language.GetString(4150)
    startRaceText.text = Language.GetString(4152)
    applyBtnText.text = Language.GetString(4153)
    self.m_matchingText.text = Language.GetString(4154)

    self.m_userMgr = Player:GetInstance():GetUserMgr()
    self.m_raceMembersList = nil
    self.m_raceMembersItemList = {}
    self.m_isJoinRace = false
    self.m_raceState = RaceStateEnum.OnlyShow
    self.m_raceId = 0
end

function UIHorseRaceMainView:OnClick(go, x, y)
    if go.name == "closeBtn" or go.name == "backBtn" then
        self:CloseSelf()
        HorseRaceMgr:ReqRacingPannel(true)
    elseif go.name == "rulerBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIQuestionsMarkTips, 116) 
    elseif go.name == "applyBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIHorseRaceSelect)
    elseif go.name == "startRaceBtn" then
        HorseRaceMgr:ReqStartRace(self.m_raceId)
    end
end

function UIHorseRaceMainView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_backBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_rulerBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_applyBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_startRaceBtn.gameObject, onClick)
end

function UIHorseRaceMainView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_rulerBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_applyBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_startRaceBtn.gameObject)
end

function UIHorseRaceMainView:OnEnable(...)
    base.OnEnable(self, ...)
    HorseRaceMgr:ReqRacingPannel(false)
    self:HandleClick()
end

function UIHorseRaceMainView:OnDisable()
    base.OnDisable(self)

    for _,item in pairs(self.m_raceMembersItemList) do
		item:Delete()
    end
    self.m_isJoinRace = false
    self.m_raceMembersItemList = {}
    self.m_raceMembersList = nil
    self.m_raceId = 0
    self:RemoveClick()
end

function UIHorseRaceMainView:UpdateView(raceInfo)
    self.m_isJoinRace = HorseRaceMgr:CheckSelfInRaceInfo(raceInfo)
    if raceInfo then
        self.m_raceId = raceInfo.race_id
        self.m_raceState = raceInfo.status or RaceStateEnum.OnlyShow
        
        if self.m_isJoinRace then
            if self.m_raceState == RaceStateEnum.Matching or self.m_raceState == RaceStateEnum.WaitRace then
                self.m_matchingText.gameObject:SetActive(true)
                self.m_applyBtn.gameObject:SetActive(false)
                self.m_startRaceBtn.gameObject:SetActive(false)
            elseif self.m_raceState == RaceStateEnum.FightComplete then
                self.m_startRaceBtn.gameObject:SetActive(true)
                self.m_applyBtn.gameObject:SetActive(false)
                self.m_matchingText.gameObject:SetActive(false)
            end
        else
            self.m_applyBtn.gameObject:SetActive(true)
            self.m_startRaceBtn.gameObject:SetActive(false)
            self.m_matchingText.gameObject:SetActive(false)
        end

        self:UpdateRaceMembers(raceInfo.member_list)
    end

    self:UpdateRaceTimes()
end

function UIHorseRaceMainView:UpdateRaceTimes()
    local todayRaceCount = HorseRaceMgr:GetTodayRaceCount()
    local dailyFreeCount = HorseRaceMgr:GetDailyFreeCount()
    if todayRaceCount < dailyFreeCount then
        self.m_freeTimeText.text = string_format(Language.GetString(4155), dailyFreeCount - todayRaceCount ,dailyFreeCount)
        self.m_freeTimeText.gameObject:SetActive(true)
        self.m_yuanbaoImage.gameObject:SetActive(false)
    else
        local costCount = todayRaceCount - dailyFreeCount + 1
        if costCount > 10 then
            costCount = 10
        end
        self.m_costText.text = ConfigUtil.GetHorseRacePriceCfgById(costCount).yuanbao
        self.m_freeTimeText.gameObject:SetActive(false)
        self.m_yuanbaoImage.gameObject:SetActive(true)
    end
end

function UIHorseRaceMainView:UpdateRaceMembers(member_list)
    self.m_raceMembersList = member_list
    if #self.m_raceMembersItemList == 0 then
        self.m_seq = UIGameObjectLoader:PrepareOneSeq()
        UIGameObjectLoader:GetGameObjects(self.m_seq, HorseRaceUserItemPath, RACE_MEMBER_COUNT, function(objs)
            self.m_seq = 0
            if objs then
                for i = 1, #objs do
                    local userItem = HorseRaceUserItem.New(objs[i], self.m_memberContent, HorseRaceUserItemPath)
                    local userBrief = nil
                    if member_list and i <= #member_list then
                        userBrief = member_list[i].user_brief
                    end

                    if userItem then
                        table_insert(self.m_raceMembersItemList, userItem)
                        userItem:SetData(userBrief)
                    end 
                end
            end
        end)
    else
        for i = 1, #self.m_raceMembersItemList do
            local userBrief = nil
            if member_list and i <= #member_list then
                userBrief = member_list[i].user_brief
            end
            self.m_raceMembersItemList[i]:SetData(userBrief)
        end
    end
end

function UIHorseRaceMainView:OnDestroy()
    base.OnDestroy(self)
end

function UIHorseRaceMainView:OnAddListener()
    self:AddUIListener(UIMessageNames.MN_HORSERACE_PANNEL, self.UpdateView)
    self:AddUIListener(UIMessageNames.MN_HORSERACE_LEFTTIMES, self.UpdateRaceTimes)
	base.OnAddListener(self)
end

function UIHorseRaceMainView:OnRemoveListener()
    self:RemoveUIListener(UIMessageNames.MN_HORSERACE_PANNEL, self.UpdateView)
    self:RemoveUIListener(UIMessageNames.MN_HORSERACE_LEFTTIMES, self.UpdateRaceTimes)
	base.OnRemoveListener(self)
end

return UIHorseRaceMainView