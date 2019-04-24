local string_format = string.format
local UserItemPrefab = TheGameIds.UserItemPrefab
local UIGameObjectLoader = UIGameObjectLoader:GetInstance()
local UserItemClass = require "UI.UIUser.UserItem"

local LieZhuanInviteItem = BaseClass("LieZhuanInviteItem", UIBaseItem)
local base = UIBaseItem

function LieZhuanInviteItem:OnCreate()
    base.OnCreate(self)
    self:InitView()
end

function LieZhuanInviteItem:InitView()

    self.m_nameText, self.m_serverText = UIUtil.GetChildTexts(self.transform, { 
        "nameText",
        "serverText",
    })

    self.m_userContent, self.m_selectImage = UIUtil.GetChildTransforms(self.transform, {
        "userContent",
        "selectImage",
    })

    self.m_userHeadItem = nil
    self.m_userBrief = nil

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self:GetGameObject(), onClick)
end

function LieZhuanInviteItem:OnClick(go)
    if go == self:GetGameObject() and self.m_onClickCallback then
        self.m_onClickCallback(self)
    end
end

function LieZhuanInviteItem:CreatePlayerHead(userBrief)
    if not userBrief then
        return
    end
    self.m_Seq = UIGameObjectLoader:PrepareOneSeq()
    UIGameObjectLoader:GetGameObject(self.m_Seq, UserItemPrefab, function(obj)
        self.m_Seq = 0
        if obj then
            local userItem = UserItemClass.New(obj, self.m_userContent, UserItemPrefab)
            if userItem then
                userItem:SetLocalScale(Vector3.New(1, 1, 1))
                self.m_userHeadItem = userItem
                if userBrief and userBrief.use_icon then
                    self.m_userHeadItem:UpdateData(userBrief.use_icon.icon, userBrief.use_icon.icon_box, userBrief.level)
                end
            end
        end
    end)
end

function LieZhuanInviteItem:UpdateData(userBrief, showType, onClickCallback)
    if userBrief then
        self.m_userBrief = userBrief
        if self.m_userHeadItem then
            if userBrief.use_icon then
                self.m_userHeadItem:UpdateData(userBrief.use_icon.icon, userBrief.use_icon.icon_box, userBrief.level)
            end
        else
            self:CreatePlayerHead(userBrief)
        end
        self.m_nameText.text = userBrief.name
        
        self.m_onClickCallback = onClickCallback

        if showType == 1 then
            self.m_serverText.text = ""
        elseif showType == 2 then
            self.m_serverText.text = string_format(Language.GetString(3732), userBrief.str_dist_id)
        elseif showType == 3 then
            local jobName = userBrief.guild_job_name == "" and Language.GetString(3727) or userBrief.guild_job_name
            self.m_serverText.text = jobName
        end
    end
end

function LieZhuanInviteItem:SetSelectState(show)
    if self.m_selectImage then
        self.m_selectImage.gameObject:SetActive(show)
    end
end

function LieZhuanInviteItem:GetUserBrief()
    return self.m_userBrief
end

function LieZhuanInviteItem:OnDestroy()
    UIUtil.RemoveClickEvent(self:GetGameObject())
    if self.m_userHeadItem then
        self.m_userHeadItem:Delete()
    end
    self.m_userHeadItem = nil
    base.OnDestroy(self)
end

return LieZhuanInviteItem