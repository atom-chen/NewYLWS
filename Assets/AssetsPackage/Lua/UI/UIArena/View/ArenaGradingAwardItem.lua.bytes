local UIUtil = UIUtil
local UIImage = UIImage
local Language = Language
local AtlasConfig = AtlasConfig
local table_insert = table.insert
local string_format = string.format
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()
local AwardItemPrefabPath = TheGameIds.SimpleAwardItemPrefab
local SimpleAwardItem = require("UI/Common/SimpleAwardItem")

local ArenaGradingAwardItem = BaseClass("ArenaGradingAwardItem", UIBaseItem)
local base = UIBaseItem

local MAX_AWARD_COUNT = 2

function ArenaGradingAwardItem:OnCreate()
    base.OnCreate(self)

    self.m_rankDanAwardGridTrans, self.m_rankBaseAwardGridTrans
    = UIUtil.GetChildRectTrans(self.transform, {
        "rankDanAwardGrid",
        "rankBaseAwardGrid",
    })

    self.m_rankDanAwardText, self.m_rankBaseAwardText, self.m_rankNameText
    = UIUtil.GetChildTexts(self.transform, {
        "rankDanAwardText",
        "rankBaseAwardText",
        "rankNameBg/rankNameText"
    })

    self.m_rankDanSpt = UIUtil.AddComponent(UIImage, self, "rankDanSpt", AtlasConfig.DynamicLoad)

    self.m_rankDanAwardText.text = Language.GetString(2219)
    self.m_rankBaseAwardText.text = Language.GetString(2220)

    self.m_rankDanAwardDataCount = 0
    self.m_rankDanAwardItemListSeq = 0
    self.m_rankDanAwardItemList = {}
    self.m_rankBaseAwardDataCount = 0
    self.m_rankBaseAwardItemListSeq = 0
    self.m_rankBaseAwardItemList = {}
end

function ArenaGradingAwardItem:OnDestroy()

    self.m_rankDanAwardGridTrans = nil
    self.m_rankBaseAwardGridTrans = nil

    self.m_rankDanAwardText = nil
    self.m_rankBaseAwardText = nil
    self.m_rankNameText = nil

    if self.m_rankDanSpt then
        self.m_rankDanSpt:Delete()
        self.m_rankDanSpt = nil
    end
    
    self:RecycleRankDanAwardItemList()
    self:RecycleRankBaseAwardItemList()
    self.m_rankDanAwardItemList = nil
    self.m_rankBaseAwardItemList = nil

    base.OnDestroy(self)
end

function ArenaGradingAwardItem:UpdateData(arena_dan_award_cfg)
    if not arena_dan_award_cfg then
        return
    end
    --更新组名和排名组图标
    if arena_dan_award_cfg then
        self.m_rankNameText.text = arena_dan_award_cfg.dan_name
        self.m_rankDanSpt:SetAtlasSprite(arena_dan_award_cfg.sIcon, false, AtlasConfig[arena_dan_award_cfg.sAtlas])
    end

    local danAwardDataList = {}
    self.m_rankDanAwardDataCount = 0
    for i = 1, MAX_AWARD_COUNT do
        local id = arena_dan_award_cfg["weekly_award_id"..i]
        local count = arena_dan_award_cfg["weekly_award_count"..i]
        if id > 0 and count > 0 and not danAwardDataList[id] then
            danAwardDataList[id] = count
            self.m_rankDanAwardDataCount = self.m_rankDanAwardDataCount + 1
        end
    end
    self:CreateArenaDanAwardItemList(danAwardDataList)

    local baseAwardDataList = nil
    baseAwardDataList, self.m_rankBaseAwardDataCount = UILogicUtil.GetArenaAwardListByRank(99999, arena_dan_award_cfg.id)
    -- for i = 1, MAX_AWARD_COUNT do
    --     local id = arena_dan_award_cfg["advance_award_id"..i]
    --     local count = arena_dan_award_cfg["advance_award_count"..i]
    --     if id > 0 and count > 0 and not baseAwardDataList[id] then
    --         baseAwardDataList[id] = count
    --         self.m_rankBaseAwardDataCount = self.m_rankBaseAwardDataCount + 1
    --     end
    -- end
    if baseAwardDataList then
        self:CreateArenaBaseAwardItemList(baseAwardDataList)
    end
end

--创建段位奖励物品列表
function ArenaGradingAwardItem:CreateArenaDanAwardItemList(danAwardDataList)
    self:RecycleRankDanAwardItemList()

    if danAwardDataList then
        self.m_rankDanAwardItemListSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObjects(self.m_rankDanAwardItemListSeq, AwardItemPrefabPath, self.m_rankDanAwardDataCount, 
        function(objs)
            self.m_rankDanAwardItemListSeq = 0
            if not objs then
                return
            end
            local index = 1
            for id, count in pairs(danAwardDataList) do
                objs[index].name = "AwardItem_"..index
                local awardItem = SimpleAwardItem.New(objs[index], self.m_rankDanAwardGridTrans, AwardItemPrefabPath)
                if awardItem then
                    awardItem:UpdateData(id, count)
                    table_insert(self.m_rankDanAwardItemList, awardItem)
                end
                index = index + 1
            end
        end)
    end
end

--创建基础奖励物品列表
function ArenaGradingAwardItem:CreateArenaBaseAwardItemList(baseAwardDataList)
    self:RecycleRankBaseAwardItemList()

    if baseAwardDataList then
        self.m_rankBaseAwardItemListSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObjects(self.m_rankBaseAwardItemListSeq, AwardItemPrefabPath, self.m_rankBaseAwardDataCount, 
        function(objs)
            self.m_rankBaseAwardItemListSeq = 0
            if not objs then
                return
            end
            local index = 1
            for id, count in pairs(baseAwardDataList) do
                objs[index].name = "AwardItem_"..index
                local awardItem = SimpleAwardItem.New(objs[index], self.m_rankBaseAwardGridTrans, AwardItemPrefabPath)
                if awardItem then
                    awardItem:UpdateData(id, count)
                    table_insert(self.m_rankBaseAwardItemList, awardItem)
                end
                index = index + 1
            end
        end)
    end
end

function ArenaGradingAwardItem:RecycleRankDanAwardItemList()
    if self.m_rankDanAwardItemListSeq ~= 0 then
        UIGameObjectLoaderInst:CancelLoad(self.m_rankDanAwardItemListSeq)
        self.m_rankDanAwardItemListSeq = 0
    end
    for i = 1, #self.m_rankDanAwardItemList do
        self.m_rankDanAwardItemList[i]:Delete()
    end
    self.m_rankDanAwardItemList = {}
end

function ArenaGradingAwardItem:RecycleRankBaseAwardItemList()
    if self.m_rankBaseAwardItemListSeq ~= 0 then
        UIGameObjectLoaderInst:CancelLoad(self.m_rankBaseAwardItemListSeq)
        self.m_rankBaseAwardItemListSeq = 0
    end
    for i = 1, #self.m_rankBaseAwardItemList do
        self.m_rankBaseAwardItemList[i]:Delete()
    end
    self.m_rankBaseAwardItemList = {}
end

return ArenaGradingAwardItem