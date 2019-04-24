local UIUtil = UIUtil
local Language = Language
local string_len = string.len
local UserItemPrefab = TheGameIds.UserItemPrefab
local UserItemClass = require("UI.UIUser.UserItem")
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()

local FriendTaskInviteItem = BaseClass("FriendTaskInviteItem", UIBaseItem)
local base = UIBaseItem

function FriendTaskInviteItem:OnCreate()
    base.OnCreate(self)

    self:InitView()

    self:HandleClick()
end

function FriendTaskInviteItem:InitView()
    self.m_bgSptTrans,
    self.m_userIconPosTrans, 
    self.m_selectSptTrans
    = UIUtil.GetChildRectTrans(self.transform, {
        "bgSpt",
        "userIconPos", 
        "selectSpt",
    })
    self.m_playerNameText,
    self.m_guildNameText
    = UIUtil.GetChildTexts(self.transform, {
        "playerNameText",
        "guildNameText",
    })
    self.m_guildIconSptImage = UIUtil.AddComponent(UIImage, self, "guildIconSpt", AtlasConfig.DynamicLoad2)
    self.m_isSelected = false
    self.m_data = nil
end

function FriendTaskInviteItem:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_bgSptTrans.gameObject)

    self.m_bgSptTrans = nil
    self.m_userIconPosTrans = nil 
    self.m_selectSptTrans = nil
    
    self.m_playerNameText = nil 
    
    if self.m_userItemSeq ~= 0 then
        UIGameObjectLoaderInst:CancelLoad(self.m_userItemSeq)
        self.m_userItemSeq = nil
    end
    if self.m_userItem then
        self.m_userItem:Delete()
        self.m_userItem = nil
    end
    
    self.m_guildIconSptImage:Delete()
    self.m_guildIconSptImage = nil    

    self.m_data = nil

    base.OnDestroy(self)
end

function FriendTaskInviteItem:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_bgSptTrans.gameObject, onClick)
end

function FriendTaskInviteItem:OnClick(go, x, y)
    if not go then
        return
    end
    local goName = go.name
    if goName == "bgSpt" then
        if self.m_selfOnClick then
            self.m_selfOnClick(self)
        end
    end
end

function FriendTaskInviteItem:UpdateData(data, selfOnClick)
    if not data then
        return
    end

    local friend_brief = data.friend_brief
    if not friend_brief then
        return
    end
    self.m_data = data
    self.m_selfOnClick = selfOnClick

    self.m_playerNameText.text = friend_brief.name
    local haveGuild = friend_brief.guild_name and string_len(friend_brief.guild_name) > 0 

    local index = 1
    local friendship = self.m_data.friendship 
    local color = "FFFEFE"
    friendship = friendship > 180 and 180 or friendship
    if friendship >= 0 and friendship < 30 then
        index = 1
        color = "FFFEFE"
    elseif friendship >= 30 and friendship < 60 then
        index = 2
        color = "3774E5"
    elseif friendship >= 60 and friendship < 180 then
        index = 3
        color = "E533D0"
    elseif friendship >= 180 then
        index = 4
        color = "C59017"
    end

    local cfg = ConfigUtil.GetFriendRelationCfgByID(index)
    if cfg then
        self.m_guildNameText.text = string.format(Language.GetString(3072), color, cfg.sName, friendship) 
    end  

    --更新玩家头像信息
    if self.m_userItem then
        if friend_brief.use_icon then
            self.m_userItem:UpdateData(friend_brief.use_icon.icon, friend_brief.use_icon.icon_box, friend_brief.level)
        end
    else
        self.m_userItemSeq = UIGameObjectLoaderInst:PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObject(self.m_userItemSeq, UserItemPrefab, function(obj)
            self.m_userItemSeq = 0
            if not obj then
                return
            end
            local userItem = UserItemClass.New(obj, self.m_userIconPosTrans, UserItemPrefab)
            if userItem then
                userItem:SetLocalScale(Vector3.New(0.9, 0.9, 0.9))
                if friend_brief.use_icon then
                    userItem:UpdateData(friend_brief.use_icon.icon, friend_brief.icon_box, friend_brief.level)
                end
                self.m_userItem = userItem
            end
        end)
    end

    local guildIconCfg = ConfigUtil.GetGuildIconCfgByID(friend_brief.guild_icon)
    if guildIconCfg then
        self.m_guildIconSptImage:SetAtlasSprite(guildIconCfg.icon..".png",false)
    end
    
    self:SetSelectState(self.m_isSelected)
end

function FriendTaskInviteItem:SetSelectState(isSelected)
    self.m_isSelected = isSelected
    self.m_selectSptTrans.gameObject:SetActive(isSelected)
end

function FriendTaskInviteItem:ChgSelectState()
    self.m_isSelected = not self.m_isSelected
    self.m_selectSptTrans.gameObject:SetActive(self.m_isSelected)
end

function FriendTaskInviteItem:GetSelectState()
    return self.m_isSelected
end

function FriendTaskInviteItem:GetUID()
    if self.m_data and self.m_data.friend_brief then
        return self.m_data.friend_brief.uid
    end
    return 0
end

return FriendTaskInviteItem