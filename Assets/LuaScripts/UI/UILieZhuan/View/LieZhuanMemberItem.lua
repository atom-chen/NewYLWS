local string_format = string.format
local ConfigUtil = ConfigUtil

local UserItemPrefab = TheGameIds.UserItemPrefab
local UIGameObjectLoader = UIGameObjectLoader:GetInstance()
local UserItemClass = require "UI.UIUser.UserItem"
local LieZhuanMgr = Player:GetInstance():GetLieZhuanMgr()
local LieZhuanMemberItem = BaseClass("LieZhuanMemberItem", UIBaseItem)
local base = UIBaseItem

function LieZhuanMemberItem:OnCreate()
    base.OnCreate(self)
    self:InitView()
end

function LieZhuanMemberItem:InitView()
    local kickOutBtnText
    self.m_nameText, self.m_serveText, self.m_waitText, self.m_nextFightText, kickOutBtnText = UIUtil.GetChildTexts(self.transform, {
        "nameText",
        "serveText",
        "waitText",
        "nextFightText",
        "kickOutBtn/kickOutBtnText",
    })
    self.m_captain, self.m_addBtn, self.m_userHeadRoot, self.m_kickOutBtn = UIUtil.GetChildTransforms(self.transform, {
        "captain",
        "addBtn",
        "userHeadRoot",
        "kickOutBtn",
    })

    kickOutBtnText.text = Language.GetString(3775)
    self.m_waitText.text = Language.GetString(3776)
    self.m_nextFightText.text = Language.GetString(3772)
    self.m_userItemPrrefab = nil
    self.m_userBrief = nil

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_addBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_kickOutBtn.gameObject, onClick)
end

function LieZhuanMemberItem:OnClick(go)
    if go.name == "addBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UILieZhuanInvitation)
    elseif go.name == "kickOutBtn" then
        if self.m_userBrief then
            LieZhuanMgr:ReqLieZhuanKickOutMember(self.m_userBrief.uid)
        end
    end
end

function LieZhuanMemberItem:SetData(isCaptain, userBrief, autoNextFight, isShowKickOutBtn)
    self.m_userBrief = userBrief
    local haveMember = userBrief ~= nil
    self.m_captain.gameObject:SetActive(isCaptain and haveMember)
    self.m_nameText.gameObject:SetActive(haveMember)
    self.m_serveText.gameObject:SetActive(haveMember)
    self.m_userHeadRoot.gameObject:SetActive(haveMember)
    self.m_waitText.gameObject:SetActive(not haveMember)
    self.m_addBtn.gameObject:SetActive(not haveMember)
    self:SetNextFfight(autoNextFight)
    self.m_kickOutBtn.gameObject:SetActive(isShowKickOutBtn)
    if haveMember then
        self.m_nameText.text = userBrief.name
        self.m_serveText.text = string_format(Language.GetString(3732), userBrief.str_dist_id)
        if not self.m_userItem then
            self.m_Seq = UIGameObjectLoader:PrepareOneSeq()
            UIGameObjectLoader:GetGameObject(self.m_Seq, UserItemPrefab, function(obj)
                self.m_Seq = 0
                if obj then
                    local userItem = UserItemClass.New(obj, self.m_userHeadRoot, UserItemPrefab)
                    if userItem then
                        userItem:SetLocalScale(Vector3.New(1, 1, 1))
                        self.m_userItem = userItem
                        if userBrief.use_icon then
                            self.m_userItem:UpdateData(userBrief.use_icon.icon, userBrief.use_icon.icon_box, userBrief.level)
                        end
                    end
                end
            end)
        else
            if userBrief.use_icon then
                self.m_userItem:UpdateData(userBrief.use_icon.icon, userBrief.use_icon.icon_box, userBrief.level)
            end
        end
    end
end

function LieZhuanMemberItem:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_addBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_kickOutBtn.gameObject)
    if self.m_userItem then
        self.m_userItem.Delete()
        self.m_userItem = nil
    end
    base.OnDestroy(self)
end

function LieZhuanMemberItem:GetUid()
    local uid = 0
    if self.m_userBrief then
        uid = self.m_userBrief.uid
    end
    return uid
end

function LieZhuanMemberItem:SetNextFfight(is_auto_next_fight)
    self.m_nextFightText.gameObject:SetActive(is_auto_next_fight)
end

return LieZhuanMemberItem