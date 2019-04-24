local ConfigUtil = ConfigUtil
local table_insert = table.insert
local Vector3 = Vector3
local GameObject = CS.UnityEngine.GameObject
local UIUtil = UIUtil

local GuildWarUserTitleBriefItem = require("UI.GuildWar.GuildWarUserTitleBriefItem")

local base = UIBaseItem
local GuildWarAtkRecordItem = BaseClass("GuildWarAtkRecordItem", UIBaseItem)

function GuildWarAtkRecordItem:OnCreate()
    base.OnCreate(self)

    self:InitView()

    self.m_breakItemList = {}
end

function GuildWarAtkRecordItem:OnDestroy()
    if self.m_guildIconImage then
        self.m_guildIconImage:Delete()
        self.m_guildIconImage = nil
    end
    
    for i, v in ipairs(self.m_breakItemList) do
        v:Delete()
    end
    self.m_breakItemList = nil

    base.OnDestroy(self)
end

function GuildWarAtkRecordItem:InitView()
    self.m_guildIconImage = UIUtil.AddComponent(UIImage, self, "GuildIconItem/GuildIconImage", AtlasConfig.DynamicLoad2)
end

function GuildWarAtkRecordItem:CreateUserTitleBriefItem(breakItemprefab)
    local defTitleCfgList = ConfigUtil.GetGuildWarCraftDefTitleCfgList()
    if defTitleCfgList then
        for i = 1, #defTitleCfgList do
            local go = GameObject.Instantiate(breakItemprefab)
            local breakItem = GuildWarUserTitleBriefItem.New(go, self.transform)
            if breakItem then
                breakItem:SetLocalPosition(Vector3.New(-85.8 + (i - 1) * 110, 0, 0))
                breakItem:UpdateData(defTitleCfgList[i].id, 0)
                table_insert(self.m_breakItemList, breakItem)
            end
        end
    end
end

function GuildWarAtkRecordItem:UpdateData(userOffenceCityRecordData, breakItemprefab)
    if userOffenceCityRecordData and breakItemprefab then

        local rival_guild_brief = userOffenceCityRecordData.rival_guild_brief
        if rival_guild_brief then
            local guildIconCfg = ConfigUtil.GetGuildIconCfgByID(rival_guild_brief.icon)
            if guildIconCfg then
                self.m_guildIconImage:SetAtlasSprite(guildIconCfg.icon..".png", true)
            end
        end

        if #self.m_breakItemList == 0 then
            self:CreateUserTitleBriefItem(breakItemprefab)
        end
        
        local break_info_list = userOffenceCityRecordData.break_info_list
        if break_info_list then
            for i = 1, #break_info_list do
                for _, v in ipairs(self.m_breakItemList) do
                    if v:GetUserTitle() == break_info_list[i].user_title then
                        v:UpdateData(break_info_list[i].user_title, break_info_list[i].break_count)
                    end
                end
            end
        end
    end
end

return GuildWarAtkRecordItem