local UIUtil = UIUtil
local AtlasConfig = AtlasConfig
local ConfigUtil = ConfigUtil
local UILogicUtil = UILogicUtil
local CommonDefine = CommonDefine
local math_floor = math.floor
local string_format = string.format
local math_ceil = math.ceil
local Language = Language
local ItemMgr = Player:GetInstance():GetItemMgr()
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local DOTween = CS.DOTween.DOTween
local Vector2 = Vector2
local Color = Color
local TypeMask = typeof(CS.UnityEngine.UI.Mask)
local UIEffect = UIEffect

local BagItem = BaseClass("BagItem", UIBaseItem)
local base = UIBaseItem

function BagItem:OnCreate()
    self.m_itemLowLightBgTrans, self.m_itemHighLightBgTrans, self.m_lockSpt,
    self.m_isEquip, self.m_isRebuildGo, self.m_checkSptGo , self.m_itemFrame =  UIUtil.GetChildRectTrans(self.transform, {
        "ItemIconMask/ItemLowLightBg",
        "ItemIconMask/ItemHighLightBg",
        "LockSpt",
        "IsEquip",
        "hongdian",
        "CheckSpt",
        "ItemFrame",
    })

    self.m_itemCfg = nil
    self.m_itemCount = 0
    self.m_isLocked = false
    self.m_canSelect = false         --能否显示选中状态
    self.m_isOnSelected = false       --是否选中状态
    self.m_needShowLock = false      --是否需要显示锁
    self.m_selfOnClickCallback = nil    --点击自身，显示item的详细信息界面
    
    self.m_itemCountText, self.m_newFlagText, self.m_levelText, self.m_equipText, self.m_improveMaterialText,
    self.m_mountNameText, self.m_iconMsgText = UIUtil.GetChildTexts(self.transform, {
        "ItemCountText",
        "newFlagText",
        "LevelImg/LevelText",
        "IsEquip/Text",
        "improveMaterial",
        "MountNameText",
        "iconMsgText"
    })
    self.m_itemIconSpt = UIUtil.AddComponent(UIImage, self, "ItemIconMask/ItemIconSpt", AtlasConfig.DynamicLoad)
    self.m_itemLowLightBg = UIUtil.AddComponent(UIImage, self, "ItemIconMask/ItemLowLightBg", AtlasConfig.DynamicLoad)
    self.m_itemHighLightBg = UIUtil.AddComponent(UIImage, self, "ItemIconMask/ItemHighLightBg", AtlasConfig.DynamicLoad)
    self.m_itemLowLightFrame = UIUtil.AddComponent(UIImage, self, "ItemFrame/ItemLowLightFrame", AtlasConfig.DynamicLoad)
    self.m_itemHighLightFrame = UIUtil.AddComponent(UIImage, self, "ItemFrame/ItemHighLightFrame", AtlasConfig.DynamicLoad)
    self.m_mingqianBgSpt = UIUtil.AddComponent(UIImage, self, "mingqianBgSpt", AtlasConfig.ItemIcon)
    self.m_mingqianIcon = UIUtil.AddComponent(UIImage, self, "mingqianBgSpt/mingqianIconSpt", AtlasConfig.DynamicLoad)
    self.m_levelImg = UIUtil.AddComponent(UIImage, self, "LevelImg", AtlasConfig.DynamicLoad)
    self.m_lockSpt = UIUtil.AddComponent(UIImage, self, "LockSpt", AtlasConfig.DynamicLoad)
    self.m_itemIconMask = UIUtil.FindComponent(self.transform, TypeMask, "ItemIconMask")

    self.m_newFlagText.text = Language.GetString(52)
    self.m_equipText.text = Language.GetString(2930)
    self.m_isRebuildGo = self.m_isRebuildGo.gameObject
    self.m_checkSptGo = self.m_checkSptGo.gameObject

    self:HandleClick()
    self.m_onclickShowDetail = false

    self.m_itemDetailPosZ = 0

    self.m_effect = false
    self.m_effectPath = nil
end

function BagItem:UpdateData(...)

    local itemIconParam = ...

    if not itemIconParam then
        self.m_levelImg.gameObject:SetActive(false)
        self.m_isEquip.gameObject:SetActive(false)
        self.m_isRebuildGo:SetActive(false)
        return
    end

    --赋值
    self.m_itemCfg = itemIconParam.itemCfg
    self.m_selfOnClickCallback = itemIconParam.selfOnClickCallback

    self.m_needShowLock = itemIconParam.needShowLock

    self.m_canSelect = itemIconParam.canSelect
    self.m_isOnSelected = itemIconParam.isOnSelected
    self.m_stage = itemIconParam.stage
    self.m_index = itemIconParam.index
    self.m_isShowCheck = itemIconParam.isShowCheck or false
    
    --更新数量(神兵、坐骑不显示数量)
    self.m_itemCount = math_floor(itemIconParam.itemCount)
    local itemMainType = itemIconParam.itemCfg.sMainType
    if UILogicUtil.IsNormalItem(itemMainType) and self.m_itemCount > 1 then
        self.m_itemCountText.text = self.m_itemCount
    else
        self.m_itemCountText.text = ""
    end
    --更新图标和底框
    UILogicUtil.SetItemBgNormalImage(self.m_itemLowLightBg, itemIconParam.stage, false)
    UILogicUtil.SetItemBgHighLightImage(self.m_itemHighLightBg, itemIconParam.stage, false)
    UILogicUtil.SetItemFrameNormalImage(self.m_itemLowLightFrame, itemIconParam.stage, itemIconParam.itemCfg.sMainType, false)
    UILogicUtil.SetItemFrameHighLightImage(self.m_itemHighLightFrame, itemIconParam.stage, itemIconParam.itemCfg.sMainType, false)
    UILogicUtil.SetItemLevelImage(self.m_levelImg, itemIconParam.stage, false)

    local isMingQian = itemIconParam.itemCfg.sMainType == CommonDefine.ItemMainType_MingQian
    local isRandMingQian = itemIconParam.itemCfg.sMainType == CommonDefine.ItemMainType_LiBao and itemIconParam.itemCfg.sSubType == CommonDefine.OtherItem_SubType_Mingqin

    --随机命签和命签表现一样
    if isRandMingQian then
        isMingQian = true
    end

    self.m_itemIconSpt.gameObject:SetActive(not isMingQian)
    self.m_mingqianBgSpt.gameObject:SetActive(isMingQian)
    local isShenBing = itemIconParam.itemCfg.sMainType == CommonDefine.ItemMainType_ShenBing
    local isZuoqi = itemIconParam.itemCfg.sMainType == CommonDefine.ItemMainType_Mount

    local icon = self.m_itemCfg.sIcon
    local atlasConfig = AtlasConfig[self.m_itemCfg.sAtlas]
    if icon and atlasConfig then
        if isMingQian then
            self.m_mingqianIcon:SetAtlasSprite(icon, true, atlasConfig)
            UILogicUtil.SetMingQianBgImage(self.m_mingqianBgSpt, self.m_stage, true)
        elseif isShenBing then
            self.m_itemIconSpt:SetAtlasSprite(string_format(Language.GetString(3588), icon, math_ceil(itemIconParam.stage)), true, atlasConfig)
        elseif isZuoqi then
            self.m_itemIconSpt:SetAtlasSprite(string_format(Language.GetString(3589), icon, math_ceil(itemIconParam.stage)), true, atlasConfig)
        else
            self.m_itemIconSpt:SetAtlasSprite(icon, true, atlasConfig)
        end
    end
    
    self:SetLockState(itemIconParam.isLocked)
    self:SetOnSelectState(self.m_isOnSelected)

    self.stageText = itemIconParam.stageText
    self.m_levelImg.gameObject:SetActive(self.stageText > 0)
    self.m_levelText.text = math_ceil(self.stageText)
    self.m_isEquip.gameObject:SetActive(itemIconParam.isEquip)
    self.m_improveMaterialText.text = itemIconParam.improveMaterialText
    self.m_mountNameText.text = itemIconParam.horseNameText
    self.m_isRebuildGo:SetActive(itemIconParam.isRebuild)
    self.m_newFlagText.gameObject:SetActive(itemIconParam.isShowNew)
    self.m_onclickShowDetail = itemIconParam.onClickShowDetail
    self.m_iconMsgText.text = itemIconParam.itemCfg.iconMsg
    if itemIconParam.equipText ~= "" then
        self.m_equipText.text = itemIconParam.equipText
    end
    self.m_itemIconMask.enabled = itemIconParam.itemCfg.sMainType == CommonDefine.ItemMainType_XinWu    
end

function BagItem:SetIconImgActive(active)
    self.m_itemIconSpt.gameObject:SetActive(active)
end

function BagItem:GetStageText()
    return self.stageText
end

function BagItem:GetItemCfg()
    return self.m_itemCfg
end

function BagItem:GetItemID()
    return self.m_itemCfg and self.m_itemCfg.id or 0
end

function BagItem:GetItemMainType()
    return self.m_itemCfg and self.m_itemCfg.sMainType or 0
end

function BagItem:GetItemCount()
    return self.m_itemCount
end

function BagItem:GetStage()
    return self.m_stage
end

function BagItem:GetIndex()
    return self.m_index
end

function BagItem:GetLockState()
    return self.m_isLocked
end

function BagItem:IsOnSelected()
    return self.m_isOnSelected
end

function BagItem:GetUniqueID()
    local uniqueID = 0
    if self.m_itemCfg then
        local itemMainType = self.m_itemCfg.sMainType
        if itemMainType == CommonDefine.ItemMainType_ShenBing or itemMainType == CommonDefine.ItemMainType_Mount then
            uniqueID = self.m_index
        else
            uniqueID = self.m_itemCfg.id
        end
    end
    return uniqueID
end

function BagItem:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_gameObject, onClick)
    UIUtil.AddClickEvent(self.m_lockSpt.gameObject, onClick)
end

function BagItem:OnClick(go, x, y)
    if IsNull(go) then
        return
    end

    if self.m_onclickShowDetail then
        UIManagerInst:OpenWindow(UIWindowNames.UIItemDetail, self)
    end

    if go == self.m_gameObject then
        if self.m_canSelect then
            self:SetOnSelectState(not self.m_isOnSelected)
        end
        if self.m_selfOnClickCallback then
            self.m_selfOnClickCallback(self)  
        end
    else
        -- local goName = go.name
        -- if goName == "LockSpt" or goName == "UnlockSpt" then
        --     self:ChgLockState()
        -- end
    end
end

function BagItem:SetClickScaleChg(isScale, originS, targetS, duration) 
    local originScale = originS or 1
    local targetScale = targetS or 1.2
    local duration = duration or 0.2
    if isScale then
        local touchBegin = function(go,x,y)
            DOTweenShortcut.DOScale(self.transform, targetScale, duration)
    
        end
        local touchEnd = function(go,x,y)
            DOTweenShortcut.DOScale(self.transform, originScale, duration)
        end
    
        UIUtil.AddDownEvent(self.transform.gameObject, touchBegin)
        UIUtil.AddUpEvent(self.transform.gameObject, touchEnd)
    end
end 

function BagItem:NeedShowLock()
    return self.m_needShowLock
end

function BagItem:SetLockState(isLocked)
    if self.m_needShowLock then
        if isLocked then
            self.m_lockSpt:SetAtlasSprite("ty81.png")
        else
            self.m_lockSpt:SetAtlasSprite("realempty.tga", false, AtlasConfig.DynamicLoad)
        end
        self.m_isLocked = isLocked
    else 
        self.m_lockSpt:SetAtlasSprite("realempty.tga", false, AtlasConfig.DynamicLoad)
    end
end

function BagItem:SetOnSelectState(isOnSelected)
    self.m_itemHighLightFrame.gameObject:SetActive(isOnSelected)
    self.m_itemLowLightFrame.gameObject:SetActive(not isOnSelected)
    self.m_itemHighLightBgTrans.gameObject:SetActive(isOnSelected)
    self.m_itemLowLightBgTrans.gameObject:SetActive(not isOnSelected)
    if self.m_isShowCheck then
        self.m_checkSptGo:SetActive(isOnSelected)
    end
    
    self.m_isOnSelected = isOnSelected
end

function BagItem:ChgLockState()
    if self.m_itemCfg then
        ItemMgr:ReqLock(self.m_itemCfg.id, not self.m_isLocked, self.m_itemCfg.sMainType, self.m_index)
    end
end

-- function BagItem:OnLockChg(param)
--     if param.item_id == self.m_itemCfg.id and param.index == self.m_index then
--         self:SetLockState(param.lock == 1 and true or false)
--     end
-- end

function BagItem:UpdateItemCount(count)
    count = math_floor(count)
    if count > 1 then
        self.m_itemCountText.text = count
    else
        self.m_itemCountText.text = ""
    end
end

function BagItem:SetIconColor(isWhite)
    local whiteOrBlack = isWhite and Color.white or Color.black
    self.m_itemLowLightBg:SetColor(whiteOrBlack)
    self.m_itemHighLightBg:SetColor(whiteOrBlack)
    self.m_itemIconSpt:SetColor(whiteOrBlack)
    self.m_itemLowLightFrame:SetColor(whiteOrBlack)
    self.m_itemHighLightFrame:SetColor(whiteOrBlack)
    self.m_mingqianBgSpt:SetColor(whiteOrBlack)
    self.m_mingqianIcon:SetColor(whiteOrBlack)
    self.m_levelImg:SetColor(whiteOrBlack)

    local whiteOrGray = isWhite and Color.white or Color.gray
    self.m_equipText.color = whiteOrGray
    self.m_levelText.color = whiteOrGray
    self.m_newFlagText.color = whiteOrGray
    self.m_itemCountText.color = whiteOrGray
    self.m_improveMaterialText.color = whiteOrGray
end

function BagItem:SetItemDetailPosZ(z)
    self.m_itemDetailPosZ = z
end

function BagItem:GetItemDetailPosZ()
    return self.m_itemDetailPosZ
end

--在Item上播放特效
function BagItem:ShowEffect(isShow, sortOrder, effectPath)
    if isShow then
        if effectPath then
            --不是同一个特效
            if self.m_effectPath ~= effectPath then
               self:ShowEffect(false)
            end

            if not self.m_effect then
                UIUtil.AddComponent(UIEffect, self, "", sortOrder, effectPath, function(effect)
                    self.m_effect = effect
                    self.m_effectPath = effectPath
                end)
            else
                self.m_effect:Play()
            end
        end
    else
        if self.m_effect then
            self.m_effect:Delete()
            self.m_effect = nil
            self.m_effectPath = nil
        end
    end
end

function BagItem:ShowFrame(isShow)
    if self.m_itemFrame then
        self.m_itemFrame.gameObject:SetActive(isShow)
    end
end

function BagItem:ShowIconMask(isShow)
    if self.m_itemIconMask then
        self.m_itemIconMask.gameObject:SetActive(isShow)
    end
end

function BagItem:OnDestroy()
    
    UIUtil.RemoveClickEvent(self.m_gameObject)
    UIUtil.RemoveClickEvent(self.m_lockSpt.gameObject)

    UIUtil.RemoveEvent(self.transform.gameObject)

    if self.m_isShowCheck then
        self.m_checkSptGo:SetActive(false)
    end

    self.m_itemCfg = nil
    self.m_itemCount = 0
    self.m_isLocked = false
    self.m_canSelect = false
    self.m_isOnSelected = false
    self.m_needShowLock = false
    self.m_selfOnClickCallback = nil

    self.m_itemLowLightBgTrans = nil
    self.m_itemHighLightBgTrans = nil    
    self.m_itemCountText = nil
    
    if self.m_lockSpt then
        self.m_lockSpt:Delete()
        self.m_lockSpt = nil
    end
    if self.m_itemIconSpt then
        self.m_itemIconSpt:Delete()
        self.m_itemIconSpt = nil
    end
    if self.m_itemLowLightBg then
        self.m_itemLowLightBg:Delete()
        self.m_itemLowLightBg = nil
    end
    if self.m_itemHighLightBg then
        self.m_itemHighLightBg:Delete()
        self.m_itemHighLightBg = nil
    end
    if self.m_itemLowLightFrame then
        self.m_itemLowLightFrame:Delete()
        self.m_itemLowLightFrame = nil
    end
    if self.m_itemHighLightFrame then
        self.m_itemHighLightFrame:Delete()
        self.m_itemHighLightFrame = nil
    end 
    if self.m_mingqianBgSpt then
        self.m_mingqianBgSpt:Delete()
        self.m_mingqianBgSpt = nil
    end 
    if self.m_mingqianIcon then
        self.m_mingqianIcon:Delete()
        self.m_mingqianIcon = nil
    end 
    if self.m_levelImg then
        self.m_levelImg:Delete()
        self.m_levelImg = nil
    end 

    self.m_isRebuildGo = nil
    self.m_checkSptGo = nil

    self:ShowEffect(false)
    self:ShowIconMask(true)
    self:ShowFrame(true)

    base.OnDestroy(self)
end

return BagItem