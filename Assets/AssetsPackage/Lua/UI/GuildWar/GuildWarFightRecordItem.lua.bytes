local ConfigUtil = ConfigUtil
local table_insert = table.insert
local Vector3 = Vector3
local GameObject = CS.UnityEngine.GameObject
local UIUtil = UIUtil

local ImgaeScale = Vector3.New(0.75, 0.75, 0.75)

local base = UIBaseItem
local GuildWarFightRecordItem = BaseClass("GuildWarFightRecordItem", UIBaseItem)

function GuildWarFightRecordItem:OnCreate()
    base.OnCreate(self)

    self:InitView()
end

function GuildWarFightRecordItem:OnDestroy()
    if self.m_guildIconImage then
        self.m_guildIconImage:Delete()
        self.m_guildIconImage = nil
    end
    
    if self.m_winImage then
        self.m_winImage:Delete()
        self.m_winImage = nil
    end

    base.OnDestroy(self)
end

function GuildWarFightRecordItem:InitView()
    self.m_guildIconImage = UIUtil.AddComponent(UIImage, self, "RivalGuildIconItem/GuildIconImage", AtlasConfig.DynamicLoad2)
    self.m_winImage = UIUtil.AddComponent(UIImage, self, "winImage", AtlasConfig.DynamicLoad)

    self.m_timeText = UIUtil.FindText(self.transform, "TimeText")
end

function GuildWarFightRecordItem:UpdateData(cityBattleRecordData)
    if cityBattleRecordData then

        local rival_guild_brief = cityBattleRecordData.rival_guild_brief
        if rival_guild_brief then
            local guildIconCfg = ConfigUtil.GetGuildIconCfgByID(rival_guild_brief.icon)
            if guildIconCfg then
                self.m_guildIconImage:SetAtlasSprite(guildIconCfg.icon..".png", true)
            end
        end
       
        --是否攻城
        if cityBattleRecordData.is_offence then
            if cityBattleRecordData.is_win then
                self.m_winImage:SetAtlasSprite("jtzb10.png")
            else
                self.m_winImage:SetAtlasSprite("jtzb11.png")
            end

            self.m_winImage.transform.localScale = ImgaeScale
        else
            if cityBattleRecordData.is_win then
                self.m_winImage:SetAtlasSprite("jtzb24.png", true)
            else
                self.m_winImage:SetAtlasSprite("jtzb25.png", true)
            end

            self.m_winImage.transform.localScale = Vector3.one 
        end

        self.m_timeText.text = TimeUtil.ToYearMonthDayHourMinSec(cityBattleRecordData.time, 2223)
    end
end

return GuildWarFightRecordItem