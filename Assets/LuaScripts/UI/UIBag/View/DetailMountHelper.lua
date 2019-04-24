local Vector3 = Vector3
local Vector2 = Vector2
local string_format = string.format
local math_min = math.min
local math_ceil = math.ceil
local tonumber = tonumber
local ConfigUtil = ConfigUtil
local UIUtil = UIUtil
local UILogicUtil = UILogicUtil
local Language = Language
local CommonDefine = CommonDefine
local UIWindowNames = UIWindowNames
local ItemData = ItemData
local UIManagerInstance = UIManagerInst
local UIGameObjectLoaderInstance = UIGameObjectLoader:GetInstance()
local MountMgr = Player:GetInstance():GetMountMgr()

local BagItemPrefabPath = TheGameIds.CommonBagItemPrefab
local BagItemClass = require("UI.UIBag.View.BagItem")
local ItemIconParam = require "DataCenter.ItemData.ItemIconParam"

local DetailMountHelper = BaseClass("DetailMountHelper")

function DetailMountHelper:__init(bagTr, bagView)
    self.m_bagView = bagView

    self.m_mountDetailContainer, self.m_itemCreatePos = 
    UIUtil.GetChildTransforms(bagTr, { 
        "MountDetailContainer",
        "MountDetailContainer/IconRoot"
    })

    local improveBtnText
    self.m_mountNameText, self.m_mountStageText, self.m_mountTypeText,
    self.m_mountAttrText, self.m_mountSkillText = UIUtil.GetChildTexts(bagTr, {
        "MountDetailContainer/IconRoot/MountNameText",
        "MountDetailContainer/IconRoot/MountStageText",
        "MountDetailContainer/IconRoot/MountTypeText",
        "MountDetailContainer/MountAttrText",
        "MountDetailContainer/MountSkillText",
    })
    
    self.m_itemLockSpt = bagView:AddComponent(UIImage, "MountDetailContainer/MountLockSpt", AtlasConfig.DynamicLoad)

    self.m_itemDetailTmpItem = nil      --用于展示新品详细信息的临时item
    self.m_bagItemSeq = 0

    self.m_showing = false
    self:HandleClick()
end

function DetailMountHelper:__delete()
    self:RemoveClick()
    self:Close()
    self.m_bagView = nil
end

function DetailMountHelper:Close()
    self.m_mountDetailContainer.gameObject:SetActive(false)

    if self.m_itemDetailTmpItem then
        self.m_itemDetailTmpItem:Delete()
        self.m_itemDetailTmpItem = nil
    end
    
    UIGameObjectLoader:GetInstance():CancelLoad(self.m_bagItemSeq)
    self.m_bagItemSeq = 0
    self.m_showing = false
end

function DetailMountHelper:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_itemLockSpt.gameObject, onClick)
end

function DetailMountHelper:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_itemLockSpt.gameObject)
end

function DetailMountHelper:OnClick(go, x, y)
    local goName = go.name

    if goName == "MountLockSpt" then
        self:OnItemLockSptClick()
    end
end


--点击物品详细信息界面的锁按钮
function DetailMountHelper:OnItemLockSptClick()
    if self.m_bagView:GetCurrSelectBagItem() then
        self.m_bagView:GetCurrSelectBagItem():ChgLockState()
    end
end

function DetailMountHelper:UpdateInfo()
    local selectItem = self.m_bagView:GetCurrSelectBagItem()
    if not selectItem then
        return
    end

    local itemCfg = selectItem:GetItemCfg()
    if not itemCfg then
        return
    end

    local index = selectItem:GetIndex()
    local mountData = MountMgr:GetDataByIndex(index)
    if not mountData then
        return
    end

    local stage = mountData.m_stage

    self.m_showing = true

    self.m_mountDetailContainer.gameObject:SetActive(true)

    --显示物品图标
    if not self.m_itemDetailTmpItem then
        self.m_bagItemSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoaderInstance:GetGameObject(self.m_bagItemSeq, BagItemPrefabPath, function(go)
            self.m_bagItemSeq = 0
            if not go then
                return
            end
            
            self.m_itemDetailTmpItem = BagItemClass.New(go, self.m_itemCreatePos, BagItemPrefabPath)
            local itemIconParam = ItemIconParam.New(itemCfg, 1, stage, index)
            self.m_itemDetailTmpItem:UpdateData(itemIconParam)
        end)
    else
        local itemIconParam = ItemIconParam.New(itemCfg, 1, stage, index)
        self.m_itemDetailTmpItem:UpdateData(itemIconParam)
    end
    
    --更新锁的状态
    local canLock = selectItem:NeedShowLock()
    local isLocked = selectItem:GetLockState() or false
    self:ChangeLock(canLock, isLocked)

    local mountCfg = ConfigUtil.GetZuoQiCfgByID(selectItem:GetItemID())
    if mountCfg then
        self.m_mountNameText.text = UILogicUtil.GetZuoQiNameByStage(stage, mountCfg)
        self.m_mountStageText.text = string_format(Language.GetString(3539), stage, mountData.m_max_stage)
        self.m_mountTypeText.text = string_format(Language.GetString(3540), mountCfg.horse_name)
        
        local baseAttr = mountData.m_base_first_attr
        local extraAttr = mountData.m_extra_first_attr
        if baseAttr and extraAttr then
            local attrNameList = CommonDefine.first_attr_name_list
            local attrStr = ""
            for i, v in pairs(attrNameList) do
                local val = baseAttr[v]
                local val2 = extraAttr[v]
                if val and val2 then
                    local attrType = CommonDefine[v]
                    if attrType then
                        if val2 == 0 then
                            attrStr = attrStr..string_format(Language.GetString(3513), Language.GetString(attrType + 10), val)
                        else
                            attrStr = attrStr..string_format(Language.GetString(3541), Language.GetString(attrType + 10), val, val2)
                        end
                    end
                end
            end
            self.m_mountAttrText.text =  attrStr
        end

        local skillCfg = ConfigUtil.GetInscriptionAndHorseSkillCfgByID(mountCfg.skill_id)
        if skillCfg then
            local stage = math_ceil(mountData.m_stage)
            local desc = skillCfg["exdesc"..stage]
            if desc and desc ~= "" then
                local exdesc = desc:gsub("{(.-)}", function(m)
                    local v = skillCfg[m]
                    if v then
                        return v
                    end
                end)
                self.m_mountSkillText.text = string_format(Language.GetString(3514), exdesc)
            end
        end
    end
end

function DetailMountHelper:ChangeLock(canLock, isLocked)
    if not self.m_showing then
        return
    end

    if canLock then
        UILogicUtil.SetLockImage(self.m_itemLockSpt, isLocked)
    else
        self.m_itemLockSpt:SetAtlasSprite("realempty.tga", false, AtlasConfig.DynamicLoad)
    end
end

return DetailMountHelper