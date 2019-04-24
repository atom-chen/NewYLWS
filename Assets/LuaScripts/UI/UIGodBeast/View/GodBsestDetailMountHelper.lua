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

local DoTween = CS.DOTween.DOTween
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local Type_CanvasGroup = typeof(CS.UnityEngine.CanvasGroup)

local BagItemPrefabPath = TheGameIds.CommonBagItemPrefab
local BagItemClass = require("UI.UIBag.View.BagItem")
local ItemIconParam = require "DataCenter.ItemData.ItemIconParam"
local TweenTime = 0.3
local ScaleSize = Vector3.New(1.3, 1.3, 1.3)

local GodBsestDetailMountHelper = BaseClass("GodBsestDetailMountHelper")

function GodBsestDetailMountHelper:__init(bagTr, bagView)
    self.m_bagView = bagView

    self.m_mountDetailContainer, self.m_itemCreatePos = 
    UIUtil.GetChildTransforms(bagTr, { 
        "Container/comentRoot/talentContent/MountDetailContainer",
        "Container/comentRoot/talentContent/MountDetailContainer/IconRoot"
    })
    
    self.m_mountNameText, self.m_mountStageText, self.m_mountTypeText,
    self.m_mountAttrText, self.m_mountSkillText = UIUtil.GetChildTexts(bagTr, {
        "Container/comentRoot/talentContent/MountDetailContainer/IconRoot/MountNameText",
        "Container/comentRoot/talentContent/MountDetailContainer/IconRoot/MountStageText",
        "Container/comentRoot/talentContent/MountDetailContainer/IconRoot/MountTypeText",
        "Container/comentRoot/talentContent/MountDetailContainer/MountAttrText",
        "Container/comentRoot/talentContent/MountDetailContainer/MountSkillText",
    })
    
    self.m_canvasGroup = self.m_mountDetailContainer:GetComponent(Type_CanvasGroup)
    self.m_canvasGroup.alpha = 0.1
    
    self.m_itemDetailTmpItem = nil      --用于展示新品详细信息的临时item
    self.m_bagItemSeq = 0
    self.m_showing = false
end

function GodBsestDetailMountHelper:__delete()
    self:Close()
    self.m_bagView = nil
end

function GodBsestDetailMountHelper:Close()
    self.m_mountDetailContainer.gameObject:SetActive(false)

    if self.m_itemDetailTmpItem then
        self.m_itemDetailTmpItem:Delete()
        self.m_itemDetailTmpItem = nil
    end
    
    UIGameObjectLoader:GetInstance():CancelLoad(self.m_bagItemSeq)
    self.m_bagItemSeq = 0
    self.m_showing = false
end

function GodBsestDetailMountHelper:UpdateInfo()
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

    if not self.m_showing then
        self:TweenShow()
    end
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

function GodBsestDetailMountHelper:IsShow()
    return self.m_showing
end

function GodBsestDetailMountHelper:TweenShow()
    --缩放
    self.m_mountDetailContainer.localScale = ScaleSize
    DOTweenShortcut.DOScale(self.m_mountDetailContainer, 1, TweenTime)
 
    --移动

    local offsetY = 50  
    local oldPos = self.m_mountDetailContainer.localPosition
    self.m_mountDetailContainer.localPosition = oldPos + Vector3.New(0, offsetY, 0)
    DOTweenShortcut.DOLocalMoveY(self.m_mountDetailContainer, oldPos.y, TweenTime)

     --渐变
     local function setterFunc(alpha)
         self.m_canvasGroup.alpha = alpha
     end
     local tweener = DoTween.To(setterFunc, 0.1, 1, TweenTime)
 end

return GodBsestDetailMountHelper