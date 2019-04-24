
local UIUtil = UIUtil
local Language = Language
local ConfigUtil = ConfigUtil
local string_format = string.format
local table_insert = table.insert
local GameObject = CS.UnityEngine.GameObject
local attrItem = require "UI.UIZuoQi.View.ImproveAttrItem"
local MountMgr = Player:GetInstance():GetMountMgr()

local ImproveItem = BaseClass("ImproveItem", UIBaseItem)
local base = UIBaseItem

function ImproveItem:OnCreate()
    base.OnCreate(self)

    self.m_gardenLevelText = UIUtil.GetChildTexts(self.transform, {"gardenLevelText"})
    self.m_gridTr, self.m_attrItemPrefab = UIUtil.GetChildTransforms(self.transform, {"Grid", "ImproveAttrPrefab"})

    self.m_attrItemPrefab = self.m_attrItemPrefab.gameObject
    self.m_attrItemList = {}
    self.m_huntId = 0
    self.m_huntLevel = 0
    self.m_level = 0
    for i = 1, 4 do
        local go = GameObject.Instantiate(self.m_attrItemPrefab)
        local item = attrItem.New(go, self.m_gridTr)
        table_insert(self.m_attrItemList, item)
    end

end

function ImproveItem:SetData(huntId, huntLevel, level, attrList)
    if not huntId or not attrList then
        return
    end

    self.m_huntId = huntId
    self.m_huntLevel = huntLevel
    self.m_level = level
    local huntCfg = ConfigUtil.GetHuntCfgByID(huntId)
    self.m_gardenLevelText.text = string_format(Language.GetString(3561), huntCfg.name, level)

    for i , v in ipairs(attrList) do
        local item = self.m_attrItemList[i]
        if item then
            item:SetData(v, self.m_huntId * 100 + self.m_level, self.m_huntId, self.m_level)
            item:SetActive(true)
        end
    end

    for i, v in ipairs(self.m_attrItemList) do
        if i > #attrList then
            -- print(v:GetGameObject().name)
            v:SetActive(false)
        end
    end
end

function ImproveItem:OnDestroy()
    for _, v in ipairs(self.m_attrItemList) do
        v:Delete()
    end
    self.m_attrItemList = {}
    
    base.OnDestroy(self)
end
 
return ImproveItem