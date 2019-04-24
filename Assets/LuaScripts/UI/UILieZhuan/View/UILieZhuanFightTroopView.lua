local GameObject = CS.UnityEngine.GameObject
local GameUtility = CS.GameUtility
local table_insert = table.insert
local string_format = string.format
local math_ceil = math.ceil
local string_split = CUtil.SplitString

local Quaternion = Quaternion
local LieZhuanMemberItem = require "UI.UILieZhuan.View.LieZhuanMemberItem"
local LieZhuanMgr = Player:GetInstance():GetLieZhuanMgr()

local UILieZhuanFightTroopView = BaseClass("UILieZhuanFightTroopView", UIBaseView)
local base = UIBaseView

function UILieZhuanFightTroopView:OnCreate()
    base.OnCreate(self)
    self:InitView()
end

function UILieZhuanFightTroopView:InitView()
    self.m_closeBtn, self.m_memberContent, self.m_leaveBtn, self.m_startBtn, self.m_talkBtn,
    self.m_checkBox, self.m_memberItemPrefab, self.m_select, self.m_waiterRoot = UIUtil.GetChildRectTrans(self.transform, {
        "closeBtn",
        "Container/mid/memberContent",
        "Container/bottom/leave_BTN",
        "Container/bottom/start_BTN",
        "Container/mid/talkBtn",
        "Container/bottom/checkBox",
        "memberItemPrefab",
        "Container/bottom/checkBox/select",
        "Container/mid/waiterRoot",
    })

    local titleText, aimText, levelText, limitText, lockToggleLabel, aotoToggleLabel, leaveBtnText, startBtnText, waiterText
    titleText, aimText, levelText, limitText, aotoToggleLabel, leaveBtnText, startBtnText,
    self.m_aimContentText, self.m_levelContentText, self.m_limitContentText, self.m_tokenText, self.m_consumeNumText,
    self.m_leftTimeText, waiterText = UIUtil.GetChildTexts(self.transform, {
        "Container/top/titleBg/titleText",
        "Container/mid/aimText",
        "Container/mid/levelText",
        "Container/mid/limitText",
        "Container/bottom/checkBox/multiFightText",
        "Container/bottom/leave_BTN/leaveBtnText",
        "Container/bottom/start_BTN/startBtnText",
        "Container/mid/aimText/aimContentText",
        "Container/mid/levelText/levelContentText",
        "Container/mid/limitText/limitContentText",
        "Container/bottom/checkBox/itemBg/consumeText",
        "Container/bottom/consumeBg/consumeNumText",
        "Container/bottom/leave_BTN/leftTimeText",
        "Container/mid/waiterRoot/waiterText",
    })

    self.m_select = self.m_select.gameObject
    self.m_waiterRoot = self.m_waiterRoot.gameObject
    titleText.text = Language.GetString(3767)
    aimText.text = Language.GetString(3768)
    levelText.text = Language.GetString(3769)
    limitText.text = Language.GetString(3770)
    aotoToggleLabel.text = Language.GetString(3772)
    leaveBtnText.text = Language.GetString(3773)
    startBtnText.text = Language.GetString(3774)
    waiterText.text = Language.GetString(3799)
    
    self.m_userMgr = Player:GetInstance():GetUserMgr()
    self.m_sCountryNameList = string_split(Language.GetString(3739), ",")
    self.m_sConditionList = string_split(Language.GetString(3785), ",")

    self.m_memberItemPrefab = self.m_memberItemPrefab.gameObject
    self.m_memberList = {}

    self.m_autoFightFlag = false
    self.m_timer = 0
end

function UILieZhuanFightTroopView:OnClick(go, x, y)
    if go.name == "leave_BTN" then     
        if self.m_teamInfo then
            LieZhuanMgr:ReqLiezhuanExitTeam(self.m_teamInfo.team_base_info.team_id)
        end
    elseif go.name == "start_BTN" then
        if self.m_teamInfo.curr_stat ~= 6 and self.m_teamInfo.curr_stat ~= 7 then
            LieZhuanMgr:ReqLiezhuanStartBuZhen() 
        end
    elseif go.name == "talkBtn" then

    elseif go.name == "checkBox" then
        self.m_autoFightFlag = not self.m_autoFightFlag
        LieZhuanMgr:ReqLieZhuanSetAutoFight(self.m_autoFightFlag)
    end
end

function UILieZhuanFightTroopView:OnExitTeam()
    self:CloseSelf()
end

function UILieZhuanFightTroopView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_leaveBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_startBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_talkBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_checkBox.gameObject, onClick)
end

function UILieZhuanFightTroopView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_leaveBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_startBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_talkBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_checkBox.gameObject)
end

function UILieZhuanFightTroopView:OnEnable(...)
    base.OnEnable(self, ...)
    local order, teamInfo
    order, teamInfo = ...

    self:HandleClick()
    self:UpdateView(teamInfo)
end

function UILieZhuanFightTroopView:OnDisable()
    base.OnDisable(self)
    self:RemoveClick()
end

function UILieZhuanFightTroopView:UpdateView(teamInfo)
    self.m_waiterRoot:SetActive(false)
    if not teamInfo then
        self:OnExitTeam()
        return
    end
    self.m_teamInfo = teamInfo
    --清空倒计时
    self.m_leftTimeText.text = ""
    self:UpdateLeftTime(self.m_teamInfo.left_time,self.m_teamInfo.curr_stat)

    if not self.m_teamInfo then
        return
    end
    local taoFaLingCount = Player:GetInstance():GetItemMgr():GetItemCountByID(ItemDefine.TaoFaLing_ID)
    local costTaoFaLingCount = LieZhuanMgr:GetAutoNeedTaoFaLing()
    local num = taoFaLingCount >= costTaoFaLingCount and 3628 or 3629
    self.m_tokenText.text = string_format(Language.GetString(num), taoFaLingCount, costTaoFaLingCount)
    local teamBaseInfo = self.m_teamInfo.team_base_info
    if teamBaseInfo then
        self.m_aimContentText.text = string_format(Language.GetString(3783), self.m_sCountryNameList[teamBaseInfo.country], teamBaseInfo.copy_id % 100)
        self.m_levelContentText.text = string_format(Language.GetString(3784), teamBaseInfo.min_level, teamBaseInfo.max_level)
        self.m_limitContentText.text = self.m_sConditionList[teamBaseInfo.permition + 1]
        self.m_consumeNumText.text = math_ceil(LieZhuanMgr:GetTeamFightNeedTili())
    end
    if self.m_teamInfo.member_list then
        self:UpdateMembers(self.m_teamInfo.member_list)
    end
end

function UILieZhuanFightTroopView:UpdateMembers(memberbriefList)
    
    if not memberbriefList then
        return
    end
        
    
    local captainId = 0
    if self.m_teamInfo and self.m_teamInfo.team_base_info then
        captainId = self.m_teamInfo.team_base_info.captain_uid
    end
    local isSelfCaptain = self.m_userMgr:CheckIsSelf(captainId)
    UIUtil.TryBtnEnable(self.m_startBtn.gameObject, #self.m_teamInfo.member_list > 1 and isSelfCaptain)

    for i = 1, 3 do
        local memberItem = self.m_memberList[i]
        local memberInfo = nil
        local userBrief = nil
        local isCaptain = false
        local autoNextFight = false
        local isShowKickOutBtn = false
        local isSelf = false
        if i <= #memberbriefList then
            memberInfo = memberbriefList[i]
        end
        if memberInfo then
            userBrief = memberInfo.user_brief
            autoNextFight = memberInfo.is_auto_fight
            isCaptain = captainId == userBrief.uid
            isSelf = self.m_userMgr:CheckIsSelf(userBrief.uid)
            isShowKickOutBtn = isSelfCaptain and not isSelf
        end

        if isSelf then
            self:UpdateAutoFight(autoNextFight)
        end

        if not memberItem then
            local go = GameObject.Instantiate(self.m_memberItemPrefab)
            if not IsNull(go) then
               local memberItem  = LieZhuanMemberItem.New(go, self.m_memberContent)
               memberItem:SetData(isCaptain, userBrief, autoNextFight, isShowKickOutBtn)
               table_insert(self.m_memberList, memberItem)
            end
        else
            memberItem:SetData(isCaptain, userBrief, autoNextFight, isShowKickOutBtn)
        end
    end
end

function UILieZhuanFightTroopView:UpdateLeftTime(left_time, curr_stat)
    if left_time and self.m_teamInfo then
        self.m_teamInfo.left_time = left_time
        self.m_teamInfo.curr_stat = curr_stat
    end

    if curr_stat == 6 or curr_stat == 7 then
        self.m_teamInfo.left_time = 0
        self.m_waiterRoot:SetActive(true)
    else
        self.m_waiterRoot:SetActive(false)
    end

    if self.m_teamInfo.left_time <= 0 or self.m_teamInfo.curr_stat ~= 3 then
        self.m_leftTimeText.text = ""
    end
end

function UILieZhuanFightTroopView:UpdateAutoFight(is_auto_fight)
    local taoFaLingCount = Player:GetInstance():GetItemMgr():GetItemCountByID(ItemDefine.TaoFaLing_ID)
    local costTaoFaLingCount = LieZhuanMgr:GetAutoNeedTaoFaLing()
    self.m_autoFightFlag = is_auto_fight and taoFaLingCount >= costTaoFaLingCount
    self.m_select:SetActive(self.m_autoFightFlag)
end

function UILieZhuanFightTroopView:UpdatePlayeNextFightState(is_cancel, uid, is_auto_next_fight)
    for _,v in ipairs(self.m_memberList) do
        if v:GetUid() == uid then
            v:SetNextFfight(is_auto_next_fight)
        end
    end
end

function UILieZhuanFightTroopView:Update()
    if self.m_teamInfo.left_time > 0 and self.m_teamInfo.curr_stat == 3 then
        self.m_teamInfo.left_time = self.m_teamInfo.left_time - Time.deltaTime
        self.m_leftTimeText.text = string_format(Language.GetString(3734), math_ceil(self.m_teamInfo.left_time))
        if self.m_teamInfo.left_time <= 0 then
            self.m_teamInfo.left_time = 0
            self.m_leftTimeText.text = ""
        end
    end
end

function UILieZhuanFightTroopView:OnDestroy()
    base.OnDestroy(self)
end

function UILieZhuanFightTroopView:OnAddListener()
    self:AddUIListener(UIMessageNames.MN_LIEZHUAN_EXIT_TEAM, self.OnExitTeam)
    self:AddUIListener(UIMessageNames.MN_LIEZHUAN_TEAM_MEMBER_CHG, self.UpdateView)
    self:AddUIListener(UIMessageNames.MN_LIEZHUAN_TEAM_STAT_TIME_CHG, self.UpdateLeftTime)
    self:AddUIListener(UIMessageNames.MN_LIEZHUAN_RSP_AUTO_FIGHT, self.UpdateAutoFight)
    self:AddUIListener(UIMessageNames.MN_LIEZHUAN_UPDATE_READY_STATE, self.UpdatePlayeNextFightState) 
	base.OnAddListener(self)
end

function UILieZhuanFightTroopView:OnRemoveListener()
    self:RemoveUIListener(UIMessageNames.MN_LIEZHUAN_EXIT_TEAM, self.OnExitTeam)
    self:RemoveUIListener(UIMessageNames.MN_LIEZHUAN_TEAM_MEMBER_CHG, self.UpdateView)
    self:RemoveUIListener(UIMessageNames.MN_LIEZHUAN_TEAM_STAT_TIME_CHG, self.UpdateLeftTime)
    self:RemoveUIListener(UIMessageNames.MN_LIEZHUAN_RSP_AUTO_FIGHT, self.UpdateAutoFight)
    self:RemoveUIListener(UIMessageNames.MN_LIEZHUAN_UPDATE_READY_STATE, self.UpdatePlayeNextFightState)
	base.OnRemoveListener(self)
end

return UILieZhuanFightTroopView