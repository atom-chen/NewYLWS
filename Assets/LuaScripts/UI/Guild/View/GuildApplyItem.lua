local GuildApplyItem = BaseClass("GuildApplyItem", UIBaseItem)
local base = UIBaseItem

local UIUtil = UIUtil
local GuildMgr = Player:GetInstance().GuildMgr
local UserItem = require "UI.UIUser.UserItem"


function GuildApplyItem:OnCreate()
    self.m_seq = 0
    self.m_userIconItem = nil

    self:InitView()
end

function GuildApplyItem:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_agreeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_refuseBtn.gameObject)

    UIGameObjectLoader:GetInstance():CancelLoad(self.m_seq)
    self.m_seq = 0

    self.m_userBriefData = nil

    if self.m_userIconItem then
        self.m_userIconItem:Delete()
        self.m_userIconItem = nil
    end

    base.OnDestroy(self)
end

function GuildApplyItem:InitView()

    local agreeBtnText, refuseBtnText
    self.m_playerNameText, self.m_applyTimeText, agreeBtnText, refuseBtnText = UIUtil.GetChildTexts(self.transform, {
        "PlayerNameText" , 
        "PlayerNameText/ApplyTimeText", 
        "Agree_BTN/AgreeBtnText", 
        "Refuse_BTN/RefuseBtnText"})

    self.m_agreeBtn, self.m_refuseBtn, self.m_iconParent = UIUtil.GetChildTransforms(self.transform, {
        "Agree_BTN",
        "Refuse_BTN",
        "IconParent"
    })

    agreeBtnText.text = Language.GetString(1367)
    refuseBtnText.text = Language.GetString(1368)

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_agreeBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_refuseBtn.gameObject, onClick)
end

function GuildApplyItem:OnClick(go)
    if go.name == "Agree_BTN" then
        if self.m_userBriefData then
            GuildMgr:ReqExamine(self.m_userBriefData.uid, 1)
        end
    elseif go.name == "Refuse_BTN" then
        if self.m_userBriefData then
            GuildMgr:ReqExamine(self.m_userBriefData.uid, 0)
        end
    end
end


function GuildApplyItem:UpdateData(applyDetailData)
    if applyDetailData then      
        local userBriefData = applyDetailData.user_brief
        if not userBriefData then
            return
        end

        self.m_userBriefData = userBriefData
        self.m_playerNameText.text = userBriefData.name

        if self.m_userIconItem == nil then
            if self.m_seq == 0 then
                self.m_seq = UIGameObjectLoader:GetInstance():PrepareOneSeq() 
                UIGameObjectLoader:GetInstance():GetGameObject(self.m_seq, TheGameIds.UserItemPrefab, function(obj)
                    self.m_seq = 0
                    if not IsNull(obj) then
                        if self.m_userBriefData then
                            self.m_userIconItem = UserItem.New(obj, self.m_iconParent, TheGameIds.UserItemPrefab)
                            self.m_userIconItem:UpdateData(self.m_userBriefData.use_icon.icon, self.m_userBriefData.use_icon.icon_box, self.m_userBriefData.level)
                        end
                    end
                end)
            end
        else
            self.m_userIconItem:UpdateData(userBriefData.use_icon.icon, self.m_userBriefData.use_icon.icon_box, self.m_userBriefData.level)
        end 

        --self.m_applyTimeText.text = TimeUtil.GetTimePassStr(applyDetailData.apply_time)
    end
end


return GuildApplyItem