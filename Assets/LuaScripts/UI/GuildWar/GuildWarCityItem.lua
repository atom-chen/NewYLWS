local GuildWarCityItem = BaseClass("GuildWarCityItem", UIBaseItem)
local base = UIBaseItem

local ConfigUtil = ConfigUtil
local IconScale = Vector3.New(0.5, 0.5, 0.5)

function GuildWarCityItem:OnCreate()
    base.OnCreate(self)

    self.m_cityIconImage = UIUtil.AddComponent(UIImage, self, "CityIconImage", AtlasConfig.DynamicLoad2)
    self.m_ownGuildIconImage = UIUtil.AddComponent(UIImage, self, "OwnGuildIconImage", AtlasConfig.DynamicLoad2)
    self.m_atkGuildIconImage = UIUtil.AddComponent(UIImage, self, "AtkGuildIconImage", AtlasConfig.DynamicLoad2)

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_gameObject, onClick)

    self.m_cityID = 0
    self.m_canClick = true
end

function GuildWarCityItem:UpdateData(cityID, own_guild_icon, atk_guild_icon, cityIcon, setPos) -- index保留
    if setPos == nil then
        setPos = false
    end

    local cityConfig = ConfigUtil.GetGuildWarCraftCityCfgByID(cityID)
    if cityConfig then
        self.m_cityID = cityID

        local guildIconCfg = ConfigUtil.GetGuildIconCfgByID(own_guild_icon)
        self.m_ownGuildIconImage.gameObject:SetActive(guildIconCfg ~= nil)
        if guildIconCfg then
            self.m_ownGuildIconImage:SetAtlasSprite(guildIconCfg.icon..".png", true)
            self.m_ownGuildIconImage.transform.localScale = IconScale
        end

        guildIconCfg = ConfigUtil.GetGuildIconCfgByID(atk_guild_icon)
        self.m_atkGuildIconImage.gameObject:SetActive(guildIconCfg ~= nil)
        if guildIconCfg then
            self.m_atkGuildIconImage:SetAtlasSprite(guildIconCfg.icon..".png", true)
            self.m_atkGuildIconImage.transform.localScale = IconScale
        end

        if setPos then
            self:SetAnchoredPosition(Vector3.New(cityConfig.pos[1], cityConfig.pos[2]))
        end

        if cityIcon then
            self.m_cityIconImage:SetAtlasSprite(cityIcon, true)
        end
    end
end

function GuildWarCityItem:OnDestroy()
    if self.m_cityIconImage then
        self.m_cityIconImage:Delete()
        self.m_cityIconImage = nil
    end

    if self.m_ownGuildIconImage then
        self.m_ownGuildIconImage:Delete()
        self.m_ownGuildIconImage = nil
    end
    UIUtil.RemoveClickEvent(self.m_gameObject)
    
    base.OnDestroy(self)
end

function GuildWarCityItem:OnClick(go, x, y)
    if not self.m_canClick then
        return
    end

    if go == self.m_gameObject then
        if self.m_cityID > 0 then
            UIManagerInst:OpenWindow(UIWindowNames.UIGuildWarCityDetail, self.m_cityID)
        end
    end
end

function GuildWarCityItem:SetClickable(canClick)
    self.m_canClick = canClick
end

return GuildWarCityItem
