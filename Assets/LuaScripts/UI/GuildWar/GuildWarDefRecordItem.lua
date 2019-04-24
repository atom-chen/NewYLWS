local GuildWarDefRecordItem = BaseClass("GuildWarDefRecordItem", UIBaseItem)
local base = UIBaseItem

local ConfigUtil = ConfigUtil
local UserItemPrefab = TheGameIds.UserItemPrefab
local UserItemClass = require("UI.UIUser.UserItem")

local winImageName = "jtzb8.png"
local winImageName2 = "jtzb9.png"

function GuildWarDefRecordItem:OnCreate()
    base.OnCreate(self)

    self.m_userItemSeq = 0
    
    self:InitView()
end

function GuildWarDefRecordItem:OnDestroy()

    UIGameObjectLoader:GetInstance():CancelLoad(self.m_userItemSeq)
    self.m_userItemSeq = 0

    if self.m_userItem then
        self.m_userItem:Delete()
        self.m_userItem = nil
    end

    if self.m_winImage then
        self.m_winImage:Delete()
        self.m_winImage = nil
    end

    if self.m_guildIconImage then
        self.m_guildIconImage:Delete()
        self.m_guildIconImage = nil
    end
    
    base.OnDestroy(self)
end

function GuildWarDefRecordItem:InitView()

    self.m_playerNameText, self.m_guildNameText 
    = UIUtil.GetChildTexts(self.transform, {
        "PlayerNameText",
        "GuildNameText"
    })
   
    self.m_userIconRoot = UIUtil.GetChildTransforms(self.transform, {
        "UserIconRoot",
    }) 

    self.m_winImage = UIUtil.AddComponent(UIImage, self, "winImage", AtlasConfig.DynamicLoad)
    self.m_guildIconImage = UIUtil.AddComponent(UIImage, self, "GuildIconItem/GuildIconImage", AtlasConfig.DynamicLoad2)
end

function GuildWarDefRecordItem:UpdateData(userDefendCityRecordData)

    if userDefendCityRecordData then
        local userBreif = userDefendCityRecordData.rival_brief
        if not userBreif then
            return
        end
    
        self.m_playerNameText.text = userBreif.user_name
        self.m_guildNameText.text = userBreif.guild_name
    
        function loadCallBack()
            if self.m_userItem then
                self.m_userItem:UpdateData(userBreif.use_icon.icon, userBreif.use_icon.icon_box, userBreif.level)
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
                    if not obj then
                        return
                    end
                    self.m_userItem = UserItemClass.New(obj, self.m_userIconRoot, UserItemPrefab)
                    loadCallBack()
                end)
            end
        end
    
        local guildIconCfg = ConfigUtil.GetGuildIconCfgByID(userBreif.guild_icon)
        if guildIconCfg then
            self.m_guildIconImage:SetAtlasSprite(guildIconCfg.icon..".png", true)
        end

        self.m_winImage:SetAtlasSprite(userDefendCityRecordData.is_win and winImageName or winImageName2, true)
    end
end

return GuildWarDefRecordItem