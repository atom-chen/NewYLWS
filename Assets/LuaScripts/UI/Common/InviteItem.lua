local UIUtil = UIUtil
local table_insert = table.insert
local string_format = string.format
local string_split = CUtil.SplitString
local LieZhuanMgr = Player:GetInstance():GetLieZhuanMgr()
local InviteItem = BaseClass("InviteItem", UIBaseItem)
local base = UIBaseItem

function InviteItem:OnCreate()
    self.m_detailsText, self.m_timeText = UIUtil.GetChildTexts(self.transform, {
        "BgRoot/detailsText",
        "BgRoot/timeText",
    })

    self.m_agreeBtn, self.m_rejectBtn = UIUtil.GetChildTransforms(self.transform, {
        "BgRoot/agreeBtn",
        "BgRoot/rejectBtn",
    })

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_agreeBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_rejectBtn.gameObject, onClick)

    self.m_realIndex = 0
    self.m_onAcceptFun = false
    self.m_sCountryNameList = string_split(Language.GetString(3750), ",")
end

function InviteItem:OnClick(go, x, y)
    if go.name == "agreeBtn" then
        if self.m_teamInfo and self.m_inviteUid then
            LieZhuanMgr:ReqLiezhuanJoinTeam(self.m_teamInfo.team_base_info.team_id, self.m_inviteUid, false, self.m_teamInfo.team_base_info.copy_id)
            if self.m_onAcceptFun then
                self.m_onAcceptFun(self.m_teamInfo.team_base_info.team_id,true)
            end
        end
    elseif go.name == "rejectBtn" then
        if self.m_teamInfo and self.m_inviteUid then
            LieZhuanMgr:ReqLiezhuanJoinTeam(self.m_teamInfo.team_base_info.team_id, self.m_inviteUid, true, self.m_teamInfo.team_base_info.copy_id)
            if self.m_onAcceptFun then
                self.m_onAcceptFun(self.m_teamInfo.team_base_info.team_id,false)
            end
        end
    end
end

function InviteItem:SetData(realIndex, inviteData, onAcceptFun)
    self.m_onAcceptFun = onAcceptFun
    self.m_realIndex = realIndex
    if inviteData then
        self.m_teamInfo = inviteData.team_info
        self.m_inviteUid = inviteData.inviter_uid
        local inviteName = ""
        for _,v in ipairs(self.m_teamInfo.member_list) do
            if v.user_brief.uid == self.m_inviteUid then
                inviteName = v.user_brief.name
                break
            end
        end
        local country = self.m_sCountryNameList[self.m_teamInfo.team_base_info.country]
        local sCopyId = self.m_teamInfo.team_base_info.copy_id % 100
        self.m_detailsText.text = string_format(Language.GetString(3798), inviteName, country, sCopyId)
    end
end

function InviteItem:UpdateLeftTime(left_time)
    self.m_timeText.text = string_format(Language.GetString(3736), left_time)
end

function InviteItem:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_agreeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_rejectBtn.gameObject)

    self.m_teamInfo = nil
    self.m_onAcceptFun = nil
    base.OnDestroy(self)
end

function InviteItem:GetRealIndex()
    return self.m_realIndex
end

return InviteItem