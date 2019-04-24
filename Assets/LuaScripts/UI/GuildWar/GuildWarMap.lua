local GuildWarMap = BaseClass("GuildWarMap" , UIBaseItem)
local base = UIBaseItem

local UIUtil = UIUtil
local Mathf_Random = Mathf.Random
local Mathf_Clamp = Mathf.Clamp
local table_insert = table.insert
local table_remove = table.remove
local GameUtility = CS.GameUtility
local Screen = CS.UnityEngine.Screen
local CalculateRelativeRectTransformBounds = CS.UnityEngine.RectTransformUtility.CalculateRelativeRectTransformBounds

local Vector3 = Vector3
local ConfigUtil = ConfigUtil
local GuildWarMgr = Player:GetInstance():GetGuildWarMgr()
local UIGameObjectLoader = UIGameObjectLoader:GetInstance()

local FarPos = Vector3.New(100000, 100000, 0)

local CityItemPath = "UI/Prefabs/Guild/CityItem.prefab"
local GuildWarCityItem = require "UI.GuildWar.GuildWarCityItem"
local GuildWarHuSongHorse = require "UI.GuildWar.GuildWarHuSongHorse"

function GuildWarMap:OnCreate()
    base.OnCreate(self)

    self.m_momentum = Vector2.zero
    self.m_dragDelta = Vector2.zero
    self.m_cityItemList = {}
    self.m_seq = 0

    self.m_husongHorse = false  --搜索到的护送马
    self.m_updateInterval = 0

    self.m_myHosongHorse = false 
    self.m_owerBrief = nil
    self.m_owerBriefIndex = 0


    self.m_horsePosLit = {
        Vector2.New(-262, 569),
        Vector2.New(182, 252),
        Vector2.New(714, 252),
        Vector2.New(959, 7),
        Vector2.New(26, -281),
        Vector2.New(-671, -194),
        Vector2.New(-1226, -386),
        Vector2.New(-1294, 85),
        Vector2.New(-389, -650),
        Vector2.New(619, -175)
    }

    local randIndex = Mathf_Random(1, #self.m_horsePosLit)
    self.m_myHosongHorsePos = self.m_horsePosLit[randIndex]
    table_remove(self.m_horsePosLit, randIndex) 
    
    self.m_cityParentTrans, self.m_hushouHouseGo, self.m_myHushouHouseGo = UIUtil.GetChildTransforms(self.transform, {
        "CityLayer", 
        "CityLayer/HuShouHouseItem",
        "CityLayer/MyHuShouHouseItem"
    })

    self.m_hushouHouseGo = self.m_hushouHouseGo.gameObject
    self.m_myHushouHouseGo = self.m_myHushouHouseGo.gameObject

    self.m_husongHorse = GuildWarHuSongHorse.New(self.m_hushouHouseGo, nil, '')
    self.m_husongHorse:SetActive(false)

    self.m_myHosongHorse = GuildWarHuSongHorse.New(self.m_myHushouHouseGo, nil, '')
    self.m_myHosongHorse:SetActive(false)

    self:HandleDrag()
end

function GuildWarMap:LateUpdate()
    if not self.m_draging then
        if Vector2.Magnitude(self.m_momentum) > 0.0001 then
            local delta = UIUtil.SpringDampen(self.m_momentum, 9, Time.unscaledDeltaTime)
            self:DoMapMove(delta)
        end
    end

    UIUtil.SpringDampen(self.m_momentum, 9, Time.unscaledDeltaTime)
end

function GuildWarMap:Update()
    if self.m_updateInterval > 0 then
        self.m_updateInterval = self.m_updateInterval - Time.deltaTime
        if self.m_updateInterval <= 0 then
            self.m_updateInterval = 1
            if self.m_husongHorse then
                self.m_husongHorse:Update(1)
            end

            if self.m_myHosongHorse then
                self.m_myHosongHorse:Update(1)
            end
        end
    end
end

function GuildWarMap:OnDestroy()
    if self.m_husongHorse then
        self.m_husongHorse:Delete()
        self.m_husongHorse = nil
    end

    if self.m_myHosongHorse then
        self.m_myHosongHorse:Delete()
        self.m_myHosongHorse = nil
    end
    self.m_owerBrief = nil
    self.m_owerBriefIndex = 0

    base.OnDestroy(self)
end

function GuildWarMap:Release() 
    --取消加载
    UIGameObjectLoader:CancelLoad(self.m_seq)
    self.m_seq = 0

    --回收
    for _, item in ipairs(self.m_cityItemList) do
        item:Delete()
    end
    self.m_cityItemList = {}

    if self.m_myHosongHorse then
        self.m_myHosongHorse:SetActive(false)
    end

    if self.m_husongHorse then
        self.m_husongHorse:SetActive(false)
    end
    
--[[ 
    if self.m_createTmpCity then
        if self.m_tmpCityList then
            for _, item in ipairs(self.m_tmpCityList) do
                item:Delete()
            end
            self.m_tmpCityList = nil
            self.m_createTmpCity = false
        end
    end ]]
end

function GuildWarMap:HandleDrag()
    local function DragBegin(go, x, y, eventData)
        self.m_startDraging = false
        self.m_draging = false
        self.m_momentum =  Vector2.zero
    end

    local function DragEnd(go, x, y, eventData)
        self.m_startDraging = false
        self.m_draging = false
    end

    local function Drag(go, x, y, eventData)
        if not self.m_startDraging then
            self.m_startDraging = true
            self.m_dragStartX = x
            self.m_dragStartY = y

            return
        end

        self.m_draging = true

        local scaleRate = UIManagerInst:GetScaleRate()
        self.m_dragDelta.x = (x - self.m_dragStartX) * scaleRate
        self.m_dragDelta.y = ( y -  self.m_dragStartY) * scaleRate
        self.m_dragStartX = x
        self.m_dragStartY = y

        self:DoMapMove(self.m_dragDelta)
        self.m_momentum = Vector2.Lerp(self.m_momentum, self.m_momentum + self.m_dragDelta * (0.01 * 35), 0.67)
    end

    UIUtil.AddDragBeginEvent(self.m_gameObject, DragBegin)
    UIUtil.AddDragEvent(self.m_gameObject, Drag)
    UIUtil.AddDragEndEvent(self.m_gameObject, DragEnd)
end


function GuildWarMap:DoMapMove(delta)
    local pos = self.transform.localPosition
    pos.x = pos.x + delta.x
    pos.y = pos.y + delta.y
    self:ConstraintMapPos(pos)
    self.transform.localPosition = Vector3.New(pos.x, pos.y, 0)
end

function GuildWarMap:ConstraintMapPos(pos)
    local scaleRate = UIManagerInst:GetScaleRate()
    local height = Screen.height * scaleRate
    local width = Screen.width * scaleRate
    local half_height = height / 2 + 4
    local half_width = width / 2 + 4

    local bounds = CalculateRelativeRectTransformBounds(self.transform)
    pos.x = Mathf_Clamp(pos.x, bounds.min.x + half_width, bounds.max.x - half_width)
    pos.y = Mathf_Clamp(pos.y, bounds.min.y + half_height, bounds.max.y - half_height)
end 

function GuildWarMap:UpdateView()
    local cityDataList = GuildWarMgr:GetCityDataList()

    local count = #cityDataList
    if self.m_seq == 0 then
        self.m_seq = UIGameObjectLoader:PrepareOneSeq()
        UIGameObjectLoader:GetGameObjects(self.m_seq, CityItemPath, count, function(objs)
            self.m_seq = 0
            if objs then
                for i = 1, #objs do
                    local item = GuildWarCityItem.New(objs[i], self.m_cityParentTrans, CityItemPath)
                    table_insert(self.m_cityItemList, item)
                    self:UpdateCityItem(item, i)
                end
            end
        end)
    end
end 

function GuildWarMap:UpdateCityItem(cityItem, index)
    local cityDataList = GuildWarMgr:GetCityDataList()
    if index <= #cityDataList then
        local cityBriefData = cityDataList[index]
        if cityBriefData then

            local guildIcon
            local atkGuildIcon
            if cityBriefData.own_guild_brief then
                guildIcon = cityBriefData.own_guild_brief.icon
            end

            if cityBriefData.atker_guild_brief then
                atkGuildIcon = cityBriefData.atker_guild_brief.icon
            end

            local cityIcon = UILogicUtil.GetGuildWarCityIcon(cityBriefData.own_guild_brief)
            cityItem:UpdateData(cityBriefData.city_id, guildIcon, atkGuildIcon, cityIcon, true)
        end
    end
end

function GuildWarMap:UpdateHuSongHorse(husongInfo)
    if self.m_husongHorse then 
        local owner_brief = husongInfo.owner_brief
        local randIndex = 0
        if self.m_owerBrief == nil or self.m_owerBrief.uid ~= owner_brief.uid then
            randIndex = Mathf_Random(1, #self.m_horsePosLit)
        else
            randIndex = self.m_owerBriefIndex
        end 
        if owner_brief then
            self.m_owerBriefIndex = randIndex
            self.m_owerBrief = owner_brief
            
            self.m_husongHorse:SetLocalPosition(self.m_horsePosLit[randIndex])
            self.m_husongHorse:UpdateData(owner_brief.use_icon.icon, owner_brief.uid, husongInfo.left_time)
            coroutine.start(self.MoveToHorse, self, self.m_husongHorse)
        end
    end
end

function GuildWarMap:UpdateMyHuSongHorse(mission)
    if self.m_myHosongHorse then
        self.m_myHosongHorse:SetActive(false)

        if mission.husong_id > 0 and mission.left_time > 0 then
            local owner_brief = mission.owner_brief
            if owner_brief then
                self.m_myHosongHorse:SetLocalPosition(self.m_myHosongHorsePos)
                self.m_myHosongHorse:UpdateData(owner_brief.use_icon.icon, owner_brief.uid, mission.left_time)
                coroutine.start(self.MoveToHorse, self, self.m_myHosongHorse)
            end
        end
    end
end

function GuildWarMap:MoveToHorse(horse)
    coroutine.waitforframes(1) 

    if horse then
        horse:SetActive(true)
        local horsePos = horse:GetLocalPosition()
        local delta = self.transform.localPosition + horsePos
        self:DoMapMove(-delta)

        if self.m_updateInterval <= 0 then
            self.m_updateInterval = 1
        end
    end
end

--[[ --GM代码
function GuildWarMap:CreateTmpCity()
    local cfgList = ConfigUtil.GetGuildWarCraftCityCfgList()
    if cfgList then
        if not self.m_createTmpCity then
            self.m_createTmpCity = true
            self.m_tmpCityList = {}
            UIGameObjectLoader:GetGameObjects(UIGameObjectLoader:PrepareOneSeq(), CityItemPath, #cfgList, function(objs)
                if objs then
                    for i = 1, #cfgList do
                        local cityConfig = cfgList[i]
                        local item = GuildWarCityItem.New(objs[i], self.m_cityParentTrans, CityItemPath)
                        item:SetAnchoredPosition(Vector3.New(cityConfig.pos[1], cityConfig.pos[2]))
                        table_insert(self.m_tmpCityList, item)
                    end
                end
            end)
        end
    end
end
 ]]

return GuildWarMap