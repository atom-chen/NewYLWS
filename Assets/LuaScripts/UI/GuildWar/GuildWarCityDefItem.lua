local ConfigUtil = ConfigUtil
local table_insert = table.insert
local Vector3 = Vector3
local GameObject = CS.UnityEngine.GameObject
local UIUtil = UIUtil
local UILogicUtil = UILogicUtil
local GuildMgr = Player:GetInstance().GuildMgr
local UserMgr = Player:GetInstance():GetUserMgr()
local UserItemPrefab = TheGameIds.UserItemPrefab
local UserItemClass = require("UI.UIUser.UserItem")
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()

local base = UIBaseItem
local GuildWarCityDefItem = BaseClass("GuildWarCityDefItem", UIBaseItem)

function GuildWarCityDefItem:OnCreate()
    base.OnCreate(self)

    self:InitView()

    self:InitVariable()

    self:HandleClick()
end

function GuildWarCityDefItem:OnDestroy()
    if self.m_userTitleIconImage then
        self.m_userTitleIconImage:Delete()
        self.m_userTitleIconImage = nil
    end

    if self.m_postImage then
        self.m_postImage:Delete()
        self.m_postImage = nil
    end

    UIGameObjectLoaderInst:CancelLoad(self.m_userItemSeq)
    self.m_userItemSeq = 0

    if self.m_userItem then
        self.m_userItem:Delete()
        self.m_userItem = nil
    end

    UIUtil.RemoveClickEvent(self.m_checkBtn)
 
    base.OnDestroy(self)
end

function GuildWarCityDefItem:OnClick(go, x, y)
    if go.name == "CheckBtn" then
       
    end
end

function GuildWarCityDefItem:InitVariable()
    self.m_userItem = false
    self.m_userItemSeq = 0
end

function GuildWarCityDefItem:InitView()
    self.m_checkBtn, self.m_userIconRoot, self.m_cannotViewTextGo = UIUtil.GetChildTransforms(self.transform, {
        "CheckBtn",
        "IconParent",
        "CannotViewText"
    })

    self.m_checkBtn = self.m_checkBtn.gameObject
    self.m_cannotViewTextGo = self.m_cannotViewTextGo.gameObject

    self.m_achievementText,
    self.m_postNameText,
    self.m_playerNameText,
    self.m_cannotViewText
    = UIUtil.GetChildTexts(self.transform, {
        "AchievementText",
        "PostImage/PostNameText",
        "PlayerNameText", 
        "CannotViewText"
    })

    self.m_cannotViewText.text = Language.GetString(2328)
    

    self.m_postImage = UIUtil.AddComponent(UIImage, self, "PostImage", AtlasConfig.DynamicLoad)
    self.m_userTitleIconImage = UIUtil.AddComponent(UIImage, self, "UserTitleIconImage", AtlasConfig.DynamicLoad)
end

function GuildWarCityDefItem:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_checkBtn, onClick)
end

function GuildWarCityDefItem:UpdateData(guildUserBriefData, isOwn)
    if guildUserBriefData then
     
        --更新玩家头像
        self.m_playerNameText.text = guildUserBriefData.user_name
        self:UpdateUserIcon(guildUserBriefData)

        --军团职称
        self.m_postImage.gameObject:SetActive(guildUserBriefData.post > 0)
        UILogicUtil.SetGuildPostImage(self.m_postImage, guildUserBriefData.post)
        self.m_postNameText.text = guildUserBriefData.post_name

        --军功
        self.m_achievementText.text = guildUserBriefData.jungong
        local guildWarCraftDefTitleCfg = ConfigUtil.GetGuildWarCraftDefTitleCfgByID(guildUserBriefData.user_title)
        if guildWarCraftDefTitleCfg then
            self.m_userTitleIconImage:SetAtlasSprite(guildWarCraftDefTitleCfg.icon..".png")
        end

        self.m_checkBtn:SetActive(isOwn)
        self.m_cannotViewTextGo:SetActive(not isOwn)
    end
end

function GuildWarCityDefItem:UpdateUserIcon(guildUserBriefData)
    function loadCallBack()
        if self.m_userItem then
            self.m_userItem:UpdateData(guildUserBriefData.use_icon.icon, guildUserBriefData.use_icon.icon_box, guildUserBriefData.level)
        end
    end

    --更新玩家头像信息
    if self.m_userItem then
        loadCallBack()
    else
        if self.m_userItemSeq == 0 then
            self.m_userItemSeq = UIGameObjectLoaderInst:PrepareOneSeq()
            UIGameObjectLoaderInst:GetGameObject(self.m_userItemSeq, UserItemPrefab, function(obj)
                self.m_userItemSeq = 0
                if IsNull(obj) then
                    return
                end
                self.m_userItem = UserItemClass.New(obj, self.m_userIconRoot, UserItemPrefab)
                loadCallBack()
            end)
        end
    end
end

return GuildWarCityDefItem