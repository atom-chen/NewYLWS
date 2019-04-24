local string_format = string.format
local ConfigUtil = ConfigUtil
local table_insert = table.insert
local string_split = CUtil.SplitString
local UserItemPrefab = TheGameIds.UserItemPrefab
local UIGameObjectLoader = UIGameObjectLoader:GetInstance()
local UserItemClass = require "UI.UIUser.UserItem"
local LieZhuanMgr = Player:GetInstance():GetLieZhuanMgr()

local LieZhuanLineupItem = BaseClass("LieZhuanLineupItem", UIBaseItem)
local base = UIBaseItem

function LieZhuanLineupItem:OnCreate()
    base.OnCreate(self)
    self:InitView()
end

function LieZhuanLineupItem:InitView() 

    self.m_nameText, self.m_serverText = UIUtil.GetChildTexts(self.transform, { 
        "nameText",
        "serverText",
    })

    self.m_captainImage, self.m_readyImage, self.m_roleContainer = UIUtil.GetChildTransforms(self.transform, {
        "captainImage",
        "readyImage",
        "roleContainer",
     })

    self.m_userHeadItem = nil
    self.m_userBrief = nil
end

function LieZhuanLineupItem:CreatePlayerHead(user_brief)
    if not user_brief then
        return
    end
    if not self.m_userHeadItem then
        self.m_Seq = UIGameObjectLoader:PrepareOneSeq()
        UIGameObjectLoader:GetGameObject(self.m_Seq, UserItemPrefab, function(objs)
            self.m_Seq = 0
            if objs then
                local userItem = UserItemClass.New(objs, self.m_roleContainer, UserItemPrefab)
                if userItem then
                    userItem:SetLocalScale(Vector3.New(1, 1, 1))
                    if user_brief.use_icon then
                        userItem:UpdateData(user_brief.use_icon.icon, user_brief.use_icon.icon_box, user_brief.level)
                    end
                    self.m_userHeadItem = userItem
                end
            end
        end)
    else
        self.m_userHeadItem:UpdateData(user_brief.use_icon, user_brief.icon_box, user_brief.level)
    end
end

function LieZhuanLineupItem:UpdateData(is_captain, user_brief)
    self.m_userBrief = user_brief
    self:CreatePlayerHead(user_brief)
    self.m_captainImage.gameObject:SetActive(is_captain)
    self.m_nameText.text = user_brief.name
    self.m_serverText.text = string_format(Language.GetString(3732), user_brief.str_dist_id)
end

function LieZhuanLineupItem:OnSetReadyState(is_ready)
    self.m_readyImage.gameObject:SetActive(is_ready)
end

function LieZhuanLineupItem:GetUid()
    if self.m_userBrief then
        return self.m_userBrief.uid
    end
end

function LieZhuanLineupItem:OnDestroy()
    if self.m_userHeadItem then
        self.m_userHeadItem:Delete()
        self.m_userHeadItem = nil
    end
    self.m_userBrief = nil
    base.OnDestroy(self)
end

return LieZhuanLineupItem