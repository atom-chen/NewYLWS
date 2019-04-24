local table_insert = table.insert
local math_ceil = math.ceil
local math_floor = math.floor
local UIUtil = UIUtil
local UILogicUtil = UILogicUtil
local tostring = tostring
local string_format = string.format
local AtlasConfig = AtlasConfig
local ConfigUtil = ConfigUtil
local Utils = Utils
local CommonDefine = CommonDefine
local UIImage = UIImage
local TypeMask = typeof(CS.UnityEngine.UI.Mask)

local CommonAwardItem = BaseClass("CommonAwardItem", UIBaseItem)
local base = UIBaseItem

function CommonAwardItem:OnCreate()
    
    self.m_iconBg = UIUtil.AddComponent(UIImage, self, "ItemIconMask/iconBg", AtlasConfig.DynamicLoad)
    self.m_iconImage = UIUtil.AddComponent(UIImage, self, "ItemIconMask/icon", AtlasConfig.RoleIcon)
    self.m_frameImage = UIUtil.AddComponent(UIImage, self, "frame", AtlasConfig.DynamicLoad)
    self.m_countryImage = UIUtil.AddComponent(UIImage, self, "Other/CountryImage", AtlasConfig.DynamicLoad)
    self.m_mingqianBgSpt = UIUtil.AddComponent(UIImage, self, "mingqianBgSpt", AtlasConfig.ItemIcon)
    self.m_mingqianIcon = UIUtil.AddComponent(UIImage, self, "mingqianBgSpt/mingqianIconSpt", AtlasConfig.DynamicLoad)
    self.m_levelImg = UIUtil.AddComponent(UIImage, self, "LevelImg", AtlasConfig.DynamicLoad)
   
    self.m_itemIconMask = UIUtil.FindComponent(self.transform, TypeMask, "ItemIconMask")

    self.m_levelText, self.m_itemCountText = UIUtil.GetChildTexts(self.transform, {
        "LevelImg/LevelText", 
        "ItemCountText",
    })
    
    local star1_trans, star2_trans, star3_trans,star4_trans,star5_trans,star6_trans, other_tr
    star1_trans, star2_trans, star3_trans,star4_trans,star5_trans,star6_trans, other_tr,
    self.m_maskImgTr = UIUtil.GetChildTransforms(self.transform, {
        "Other/startList/star1",
        "Other/startList/star2",
        "Other/startList/star3",
        "Other/startList/star4",
        "Other/startList/star5",
        "Other/startList/star6",
        "Other",
        "MaskImg",
    })
    
    self.m_wujiangGo = other_tr.gameObject
    self.m_starList = { star1_trans, star2_trans, star3_trans,star4_trans,star5_trans,star6_trans }
    
    self.m_itemDetailPosZ = 0

    self.m_param = nil

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_frameImage.gameObject, onClick)

    self.m_maskImgTr.gameObject:SetActive(false)
end

function CommonAwardItem:OnClick(go, x, y)
    if IsNull(go) then
        return
    end

    -- print(' ----------- ', table.dump(self.m_param))
    if self.m_param and self.m_param.showDetailOnClick then
        UIManagerInst:OpenWindow(UIWindowNames.UIAwardDetail, self)
    end
end

function CommonAwardItem:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_frameImage.gameObject)

    if self.m_frameImage then
        self.m_frameImage:Delete()
        self.m_frameImage = nil
    end
    if self.m_iconImage then
        self.m_iconImage:Delete()
        self.m_iconImage = nil
    end
    if self.m_countryImage then
        self.m_countryImage:Delete()
        self.m_countryImage = nil
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

    self.m_param = nil
    base.OnDestroy(self)
end

function CommonAwardItem:GetParam()
    return self.m_param
end

function CommonAwardItem:UpdateData(iconParam)
    if not iconParam then
        return
    end
    self.m_maskImgTr.gameObject:SetActive(false)
    self.m_param = iconParam

    if Utils.IsWujiang(iconParam.itemID) then
        local wujiangCfg = ConfigUtil.GetWujiangCfgByID(iconParam.itemID)
        if not wujiangCfg then
            return
        end
        
        self.m_wujiangGo:SetActive(true)

        UILogicUtil.SetWuJiangFrame(self.m_frameImage, wujiangCfg.rare)
        UILogicUtil.SetWuJiangCountryImage(self.m_countryImage, wujiangCfg.country)
        UILogicUtil.SetWuJiangJobImage(self.m_jobImage, wujiangCfg.nTypeJob)
        UILogicUtil.SetItemLevelImage(self.m_levelImg, wujiangCfg.rare)
        self.m_levelImg.gameObject:SetActive(true)
        
        local level = iconParam.level
        if level <= 0 then
            level = 1 
        end

        local star = iconParam.star
        if star <= 0 then
            star = 1
        end

        local wujiangStarCfg = ConfigUtil.GetWuJiangStarCfgByID(star)
        if wujiangStarCfg then
            if wujiangStarCfg.level_limit == level then
                self.m_levelText.text = Language.GetString(700)
            else
                self.m_levelText.text = math_ceil(level)
            end
        end
        
        for i = 1, #self.m_starList do
            if self.m_starList[i] then
                if i <= star then
                    self.m_starList[i].gameObject:SetActive(true)
                else
                    self.m_starList[i].gameObject:SetActive(false)
                end
            end
        end
        
        self.m_iconImage:SetAtlasSprite(wujiangCfg.sIcon, false, AtlasConfig.RoleIcon)
        self.m_iconImage.gameObject:SetActive(true)

        if iconParam.itemCount > 1 then
            self.m_itemCountText.text = math_floor(iconParam.itemCount)
        else
            self.m_itemCountText.text = ''
        end

        self.m_mingqianBgSpt.gameObject:SetActive(false)
        self.m_itemIconMask.enabled = false
    else
        local itemCfg = ConfigUtil.GetItemCfgByID(iconParam.itemID)
        if not itemCfg then
            return
        end

        local level = iconParam.level
        if level <= 0 then
            level = 1 
        end

        self.m_wujiangGo:SetActive(false)

        local itemCount = math_floor(iconParam.itemCount)
        local itemMainType = itemCfg.sMainType
        if UILogicUtil.IsNormalItem(itemMainType) and itemCount > 1 then
            self.m_itemCountText.text = itemCount
        else
            self.m_itemCountText.text = ""
        end
        
        local color = iconParam.color
        local showLevel = false

        if itemMainType == CommonDefine.ItemMainType_ShenBing then
            color = UILogicUtil.GetShenBingStageByLevel(iconParam.level)
            showLevel = true
        elseif itemMainType == CommonDefine.ItemMainType_Mount then
            color = iconParam.level
            showLevel = true
        else
            color = itemCfg.nColor
        end

        UILogicUtil.SetItemBgNormalImage(self.m_iconBg, color, false)
        UILogicUtil.SetItemFrameNormalImage(self.m_frameImage, color, itemMainType, false)
        UILogicUtil.SetItemLevelImage(self.m_levelImg, color, false)

        self.m_frameImage:SetColor(Color.black)

        local isMingQian = (itemMainType == CommonDefine.ItemMainType_MingQian)
        local isRandMingQian = itemMainType == CommonDefine.ItemMainType_LiBao and itemCfg.sSubType == CommonDefine.OtherItem_SubType_Mingqin
        --随机命签和命签表现一样
        if isRandMingQian then
            isMingQian = true
        end

        self.m_iconImage.gameObject:SetActive(not isMingQian)
        self.m_mingqianBgSpt.gameObject:SetActive(isMingQian)
        local isShenBing = (itemMainType == CommonDefine.ItemMainType_ShenBing)
        local isZuoqi = itemMainType == CommonDefine.ItemMainType_Mount
        
        local icon = itemCfg.sIcon
        local atlasConfig = AtlasConfig[itemCfg.sAtlas]
        if icon and atlasConfig then
            if isMingQian then
                self.m_mingqianIcon:SetAtlasSprite(icon, true, atlasConfig)
                UILogicUtil.SetMingQianBgImage(self.m_mingqianBgSpt, color, true)
            elseif isShenBing then
                local stage = self:GetStageByLevel(level)
                self.m_iconImage:SetAtlasSprite(string_format(Language.GetString(3588), icon, math_ceil(stage)), true, atlasConfig)
            elseif isZuoqi then
                self.m_iconImage:SetAtlasSprite(string_format(Language.GetString(3589), icon, math_ceil(level)), true, atlasConfig)
            else
                self.m_iconImage:SetAtlasSprite(icon, true, atlasConfig)
            end
        end

        self.m_levelImg.gameObject:SetActive(showLevel)
        self.m_levelText.text = math_ceil(iconParam.level)
        
        self.m_itemIconMask.enabled = (itemMainType == CommonDefine.ItemMainType_XinWu)
    end
    
    if not self.m_param.showDetailOnClick then
        self.m_frameImage:EnableRaycastTarget(false)
    else
        self.m_frameImage:EnableRaycastTarget(true)
    end
end

function CommonAwardItem:GetStageByLevel(level)
    local stage = 0
    if level < 5 then
        stage = CommonDefine.ItemStageType_1
    elseif level >= 5 and level < 10 then
        stage = CommonDefine.ItemStageType_2
    elseif level >= 10 and level < 15 then
        stage = CommonDefine.ItemStageType_3
    elseif level == 15 then
        stage = CommonDefine.ItemStageType_4
    end
    return stage
end

function CommonAwardItem:SetItemDetailPosZ(z)
    self.m_itemDetailPosZ = z
end

function CommonAwardItem:GetItemDetailPosZ()
    return self.m_itemDetailPosZ
end

function CommonAwardItem:SetMaskImgActive(isShow)
    isShow = isShow or false
    self.m_maskImgTr.gameObject:SetActive(isShow)
end

return CommonAwardItem