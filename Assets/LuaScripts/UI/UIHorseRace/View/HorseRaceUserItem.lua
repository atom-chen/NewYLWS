local Vector3 = Vector3
local UserItemPrefab = TheGameIds.UserItemPrefab
local UIGameObjectLoader = UIGameObjectLoader:GetInstance()
local UserItemClass = require "UI.UIUser.UserItem"

local HorseRaceUserItem = BaseClass("HorseRaceUserItem", UIBaseItem)
local base = UIBaseItem

function HorseRaceUserItem:OnCreate()
    base.OnCreate(self)
    self:InitView()
end

function HorseRaceUserItem:InitView()
    self.m_userNameText = UIUtil.GetChildTexts(self.transform, {
        "userNameText",
    })

    self.m_userRoot = UIUtil.GetChildTransforms(self.transform, {
        "userRoot",
    })

    self.m_userItem = nil
end

function HorseRaceUserItem:SetData(userBrief)
    if userBrief then
        self.m_userNameText.text = userBrief.name
        if not self.m_userItem then
            self.m_Seq = UIGameObjectLoader:PrepareOneSeq()
            UIGameObjectLoader:GetGameObject(self.m_Seq, UserItemPrefab, function(obj)
                self.m_Seq = 0
                if obj then
                    local userItem = UserItemClass.New(obj, self.m_userRoot, UserItemPrefab)
                    if userItem then
                        userItem:SetLocalScale(Vector3.New(1, 1, 1))
                        self.m_userItem = userItem
                        if userBrief and userBrief.use_icon then
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
    else
        if self.m_userItem then
            self.m_userItem:Delete()
            self.m_userItem = nil
        end
        self.m_userNameText.text = ""
    end
end

function HorseRaceUserItem:OnDestroy()
    base.OnDestroy(self)
    if self.m_userItem then
        self.m_userItem:Delete()
        self.m_userItem = nil
    end
end

return HorseRaceUserItem