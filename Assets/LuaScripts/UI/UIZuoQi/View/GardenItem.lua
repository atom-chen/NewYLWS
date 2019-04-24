
local ImageConfig = ImageConfig
local UILogicUtil = UILogicUtil
local CommonDefine = CommonDefine
local UIUtil = UIUtil
local Language = Language
local GameUtility = CS.GameUtility
local string_format = string.format
local math_ceil = math.ceil
local math_floor = math.floor
local Type_Canvas = typeof(CS.UnityEngine.Canvas)
local Vector3 = Vector3
local MountMgr = Player:GetInstance():GetMountMgr()
local ItemMgr = Player:GetInstance():GetItemMgr()
local UserMgr = Player:GetInstance():GetUserMgr()

local UpdatingPath = "UI/Effect/Prefabs/Ui_lieyuan_Upgrading"
local LevelUpPath = "UI/Effect/Prefabs/Ui_lieyuan_Levelup"

local GardenItem = BaseClass("GardenItem", UIBaseItem)
local base = UIBaseItem

function GardenItem:OnCreate()
    base.OnCreate(self)

    self.m_gardenNameText, self.m_levelUpTimeText, self.m_conditionText = UIUtil.GetChildTexts(self.transform, {
        "GardenBg/Text",
        "Canvas/LevelUpTiembg/Text",
        "GardenBg/conditionText",
    })

    self.m_redPointGo, self.m_maintainGo, self.m_LevelUpTimeGo, self.m_inputBtn = UIUtil.GetChildTransforms(self.transform, {
        "GardenBg/redPoint",
        "GardenBg/maintain",
        "Canvas/LevelUpTiembg",
        "Input"
    })
    self.m_redPointGo = self.m_redPointGo.gameObject
    self.m_maintainGo = self.m_maintainGo.gameObject
    self.m_LevelUpTimeGo = self.m_LevelUpTimeGo.gameObject

    self.m_redPointGo:SetActive(false)
    self.m_maintainGo:SetActive(false)
    self.m_LevelUpTimeGo:SetActive(false)
    
    self.m_gardenImg = UIUtil.AddComponent(UIImage, self, "", AtlasConfig.Common)

    self.m_id = 0
    self.m_level = 0
    self.m_status = 0
    self.m_finishTime = 0
    self.m_isLevelUp = true
    self.m_levelUpGardenId = nil
    self.m_levelUpGardenFinishTime = nil

    local parentCanvas = self:GetTransform():GetComponentInParent(Type_Canvas)
    local selfCanvas = self:GetTransform():GetComponentInChildren(Type_Canvas)
    selfCanvas.sortingOrder = parentCanvas.sortingOrder + 5
    
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_inputBtn.gameObject, onClick)
end

function GardenItem:GetStatus()
    return self.m_status
end

function GardenItem:GetID()
    return self.m_id
end

function GardenItem:GetFinishTime()
    return self.m_finishTime
end

function GardenItem:OnClick(go)
    if self.m_status == 1 then
        return
    end
    if go.name == "Input" then
 
        TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.CLICK_UI, "GardenItem")
        if self.m_status == CommonDefine.Hunt_Updating_AlreadyMaintain or self.m_status == CommonDefine.Hunt_Updating_NeedMaintain then
            local gameSetting = UserMgr:GetSettingData()
            local serverTime = Player:GetInstance():GetServerTime()
            if gameSetting.hunt_levelup_reduce_cd_per_yuanbao == 0 then
                return
            end
            local yuanbaoCount = math_ceil((self.m_finishTime - serverTime) / gameSetting.hunt_levelup_reduce_cd_per_yuanbao)
            UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(3537), string_format(Language.GetString(3538), yuanbaoCount),
            Language.GetString(10), Bind(MountMgr, MountMgr.ReqClearLevelUpCD, self.m_id), Language.GetString(5))
        else
            UIManagerInst:OpenWindow(UIWindowNames.UIHuntLevelUp, self.m_id, self.m_level, self.m_levelUpGardenId, self.m_levelUpGardenFinishTime)
            
        end

    end
end

function GardenItem:OnDestroy()
    self:ClearEffect(true, true)
    UIUtil.RemoveClickEvent(self.m_inputBtn.gameObject)
    base.OnDestroy(self)
end

function GardenItem:GetID()
    return self.m_id
end

function GardenItem:GetLevel()
    return self.m_level
end

function GardenItem:GetStatus()
    return self.m_status
end

-- function GardenItem:MaintainGarden()
--     if self.m_status == CommonDefine.Hunt_Updating_NeedMaintain then
--         UILogicUtil.FloatAlert(Language.GetString(3534))
--         return
--     end
--     local huntCfg = ConfigUtil.GetHuntCfgByID(self.m_id)
--     UIManagerInst:OpenWindow(UIWindowNames.UIHuntMaintain, self.m_id * 100 + self.m_level, huntCfg.name, Bind(MountMgr, MountMgr.ReqMaintain, self.m_id))
-- end

-- function GardenItem:LevelUpGarden()
--     if self.m_status == CommonDefine.Hunt_Updating_AlreadyMaintain or self.m_status == CommonDefine.Hunt_Updating_NeedMaintain then
--         local gameSetting = UserMgr:GetSettingData()
--         if gameSetting.hunt_levelup_reduce_cd_per_yuanbao == 0 then
--             return
--         end
--         local yuanbaoCount = math_ceil((self.m_finishTime - Player:GetInstance():GetServerTime()) / gameSetting.hunt_levelup_reduce_cd_per_yuanbao)
--         UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(3537), string_format(Language.GetString(3538), yuanbaoCount),
--         Language.GetString(10), Bind(MountMgr, MountMgr.ReqClearLevelUpCD, self.m_id), Language.GetString(5))
--     else
--         local huntCfg = ConfigUtil.GetHuntCfgByID(self.m_id)
--         UIManagerInst:OpenWindow(UIWindowNames.UIHuntLevelUp, self.m_id, self.m_level)
--     end
-- end

function GardenItem:SetLevelUpGardenInfo(id, time)
    self.m_levelUpGardenId = id
    self.m_levelUpGardenFinishTime = time
end

function GardenItem:SetData(id, level, status, time, sortOrder)
    if not id then
        return
    end
    local huntCfg = ConfigUtil.GetHuntCfgByID(id)
    if not huntCfg then
        return
    end
    self.m_id = id
    self.m_level = level or 0
    self.m_status = status or 0
    local levelUpCfg = ConfigUtil.GetHuntLevelUpCfgByID(id * 100 + level)
    self.m_gardenImg:SetAtlasSprite(math_ceil(id)..".png", true, ImageConfig.Hunt)
    GameUtility.SetUIGray(self.m_gardenImg.gameObject, false)
    self.m_gardenNameText.text = string_format(Language.GetString(3528), huntCfg.name, level)
    self.m_conditionText.text = ""
    self.m_maintainGo:SetActive(false)
    self.m_LevelUpTimeGo:SetActive(false)
    self.m_redPointGo:SetActive(false)
    if status == 1 then
        GameUtility.SetUIGray(self.m_gardenImg.gameObject, true)
        self.m_gardenNameText.text = Language.GetString(3564)
        local curHuntCfg = ConfigUtil.GetHuntCfgByID(self.m_id)
        local openHuntCfg = nil
        if curHuntCfg and curHuntCfg.ground_id > 0 then
            openHuntCfg = ConfigUtil.GetHuntCfgByID(curHuntCfg.ground_id)
        end
        if openHuntCfg then
            self.m_conditionText.text = string_format(Language.GetString(3527), openHuntCfg.name, curHuntCfg.level)
        end
    elseif status == 2 then
        self.m_maintainGo:SetActive(true)
    elseif status == 3 then
        self.m_LevelUpTimeGo:SetActive(true)
        self.m_finishTime = time 
        self.m_isLevelUp = false
    elseif status == 4 then
        self.m_LevelUpTimeGo:SetActive(true)
        self.m_finishTime = time 
        self.m_isLevelUp = false
    elseif status == 10 then
        if self:CanLevelUp(levelUpCfg) then
            self.m_redPointGo:SetActive(true)
        else
            self.m_redPointGo:SetActive(false)
        end
        self.m_maintainGo:SetActive(false)
    elseif status == 12 then
        self.m_maintainGo:SetActive(true)
        self.m_redPointGo:SetActive(false)
    end

    if time > Player:GetInstance():GetServerTime() then
        if not self.m_updatingEffect then
            UIUtil.AddComponent(UIEffect, self, "", sortOrder, UpdatingPath, function(effect)
                if self.m_id == 5 then
                    effect:SetLocalPosition(Vector3.New(1, 65, 0))
                elseif self.m_id == 4 or self.m_id == 6 then
                    effect:SetLocalPosition(Vector3.New(0, 95, 0))
                elseif self.m_id == 2 or self.m_id == 1 then
                    effect:SetLocalPosition(Vector3.New(0, 115, 0))
                else
                    effect:SetLocalPosition(Vector3.New(14, 95, 0))
                end
                effect:SetLocalScale(Vector3.one)
                self.m_updatingEffect = effect
            end)
        end
    else
        self:ClearEffect(true, false)
    end

    if time == 0 then
        self:ClearEffect(true, true)
    else
        if time < Player:GetInstance():GetServerTime() then
            if not self.m_levelUpEffect then
                UIUtil.AddComponent(UIEffect, self, "", sortOrder, LevelUpPath, function(effect)
                    effect:SetLocalPosition(Vector3.zero)
                    effect:SetLocalScale(Vector3.one)
                    self.m_levelUpEffect = effect
                end)
            end
        else
            self:ClearEffect(false, true)
        end
    end

end

function GardenItem:ClearEffect(isUpdating, isLevelUp)
    if isUpdating then
        if self.m_updatingEffect then
            self.m_updatingEffect:Delete()
            self.m_updatingEffect = nil
        end
    elseif isLevelUp then
        if self.m_levelUpEffect then
            self.m_levelUpEffect:Delete()
            self.m_levelUpEffect = nil
        end
    end
end

function GardenItem:CanLevelUp(levelUpCfg)
    local itemOneCount, itemTwoCount, itemThreeCount, needOneCount, needTwoCount, needThreeCount
    local canLevelUp = true
    if levelUpCfg.levelup_item_id1 > 0 then
        itemOneCount = ItemMgr:GetItemCountByID(levelUpCfg.levelup_item_id1)
        needOneCount = levelUpCfg.levelup_item_count1
    end
    if levelUpCfg.levelup_item_id2 > 0 then
        itemTwoCount = ItemMgr:GetItemCountByID(levelUpCfg.levelup_item_id2)
        needTwoCount = levelUpCfg.levelup_item_count2
    end
    if levelUpCfg.levelup_item_id3 > 0 then
        itemThreeCount = ItemMgr:GetItemCountByID(levelUpCfg.levelup_item_id3)
        needThreeCount = levelUpCfg.levelup_item_count3
    end
    if itemOneCount then
        if needOneCount > itemOneCount then
            canLevelUp = false
        end
    end
    if itemTwoCount then
        if needTwoCount > itemTwoCount then
            canLevelUp = false
        end
    end
    if itemThreeCount then
        if needThreeCount > itemThreeCount then
            canLevelUp = false
        end
    end
    return canLevelUp
end

function GardenItem:Update()

    local curtime = Player:GetInstance():GetServerTime()
    if self.m_finishTime > curtime then
        local leftTime = self.m_finishTime - curtime
        self.m_levelUpTimeText.text = string_format(Language.GetString(3526), self:GetLeftTimeText(leftTime))
    else
        if not self.m_isLevelUp then
            self:ClearEffect(true, false)
            self.m_isLevelUp = true
            MountMgr:ReqHuntPanel()
        end
    end
end

function GardenItem:GetLeftTimeText(time)
    local hour = math_floor(time / 3600)
    time = time - hour * 3600
    local minute = math_floor(time / 60)
    time = time - minute * 60
    local second = math_floor(time)
    if hour < 24 then
        if hour == 0 then
            if minute == 0 then
                return string_format(Language.GetString(3584), second)
            else
                return string_format(Language.GetString(3585), minute, second)
            end
        else
            return string_format(Language.GetString(3586), hour, minute, second)
        end
    else
        return string_format(Language.GetString(3587), math_floor(hour / 24), (hour % 24), minute, second)
    end
end

return GardenItem
