local Language = Language
local CommonDefine = CommonDefine
local UIUtil = UIUtil
local SplitString = CUtil.SplitString
local string_format = string.format
local ConfigUtil = ConfigUtil

local SectionItem = BaseClass("SectionItem", UIBaseItem)
local base = UIBaseItem

function SectionItem:OnCreate()
    self.m_sectionID = nil
    self.m_sectionType = nil
    self.m_indexStrList = SplitString(Language.GetString(2600), ',')
    self.m_nameColor = Color.New(1, 233/255, 177/255, 1)
    self.m_effect = nil

    self.m_newImageGO, self.m_lockGo, self.m_nameRoot, self.m_unlockImgGo = UIUtil.GetChildTransforms(self.transform, {
        "nameBg/newImage",
        "lockImage",
        "nameBg",
        "unlockImage"
    })

    self.m_cityImage = UIUtil.AddComponent(UIImage, self, "cityImage", AtlasConfig.DynamicLoad)
    self.m_lockImage = UIUtil.AddComponent(UIImage, self, "lockImage", AtlasConfig.DynamicLoad)

    self.m_nameText, self.m_lockText = UIUtil.GetChildTexts(self.transform, {
        "nameBg/nameText",
        "lockImage/lockText",
    })
    self.m_newImageGO = self.m_newImageGO.gameObject
    self.m_lockGo = self.m_lockGo.gameObject
    self.m_nameRoot = self.m_nameRoot.gameObject
    self.m_unlockImgGo = self.m_unlockImgGo.gameObject
    self.m_lockText.text = Language.GetString(2620)

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_cityImage.gameObject, onClick)
end

function SectionItem:SetData(sectionID, sectionType, isNewest, sortOrder)
    self.m_sortOrder = sortOrder
    self.m_sectionID = sectionID
    self.m_sectionType = sectionType
    local sectionCfg = ConfigUtil.GetCopySectionCfgByID(sectionID)
    local sectionIndexStr = self.m_indexStrList[sectionCfg.section_index]
    if sectionID >= CommonDefine.MAINLINE_SECTION_MONSTER_HOME then
        self.m_nameText.text = sectionCfg.section_name
    else
        self.m_nameText.text = string_format(Language.GetString(2601), sectionIndexStr, sectionCfg.section_name)
    end
    self.m_cityImage:SetAtlasSprite(sectionCfg.section_icon .. ".png", true)

    local sectionData = Player:GetInstance():GetMainlineMgr():GetSectionData(self.m_sectionID)
    if sectionData then
        local isOpen, islevelNotEnough = sectionData:GetOpenState(sectionType)
        if isOpen then
            if sectionType == CommonDefine.SECTION_TYPE_ELITE and not sectionData:IsAllNormalCopyClear() then
                self:Unlock(false)
                self.m_nameText.text = string_format(Language.GetString(2630), sectionIndexStr)
                self.m_nameText.color = Color.red
            else
                self:Unlock(sectionData:IsNew())
                self.m_nameText.color = self.m_nameColor
                if sectionID >= CommonDefine.MAINLINE_SECTION_MONSTER_HOME and sectionData:IsAllNormalCopyClear() then
                    self.m_cityImage:SetColor(Color.black)
                    self.m_nameRoot:SetActive(false)
                end
            end
        elseif islevelNotEnough then
            self:Unlock(false)
            self.m_nameText.text = string_format(Language.GetString(2621), sectionCfg.level)
            self.m_nameText.color = Color.red
        else
            self:GetGameObject():SetActive(false)
        end
    else
        self:GetGameObject():SetActive(false)
    end
    self.m_isNewest = isNewest 
    if isNewest then
        if not self.m_effect then 
            UIUtil.AddComponent(UIEffect, self, "", self.m_sortOrder, TheGameIds.Ui_bigmapmisson_chapter_fx, function(effect)
                self.m_effect = effect
                self.m_effect:SetLocalPosition(Vector3.New(0, 45,0))
                self.m_effect:SetOrder(self.m_sortOrder)
            end)
        end
        self.m_unlockImgGo:SetActive(false)
    else
        self:ClearNuqiEffect()
    end

    if sectionID >= CommonDefine.MAINLINE_SECTION_MONSTER_HOME then
        self.m_unlockImgGo:SetActive(false)
    end
end

function SectionItem:SetEffectOrder(effectOrder)
    self.m_sortOrder = effectOrder

    if self.m_effect then
        self.m_effect:SetOrder(self.m_sortOrder)
    end
end

function SectionItem:OnClick(go, x, y)
    local sectionData = Player:GetInstance():GetMainlineMgr():GetSectionData(self.m_sectionID)
    if not sectionData then
        return
    end
    local isOpen, islevelNotEnough = sectionData:GetOpenState(self.m_sectionType)
    if isOpen then
        if self.m_sectionID >= CommonDefine.MAINLINE_SECTION_MONSTER_HOME and sectionData:IsAllNormalCopyClear() then
            return 
        end
        UIManagerInst:Broadcast(UIMessageNames.MN_MAINLINE_CLICK_SECTION_ITEM,  self.m_sectionID)
    elseif islevelNotEnough then
        UILogicUtil.FloatAlert(string_format(Language.GetString(2629), sectionData:GetSectionCfg().level))
    elseif self.m_sectionType == CommonDefine.SECTION_TYPE_ELITE and not sectionData:IsAllNormalCopyClear() then
        local sectionIndexStr = self.m_indexStrList[sectionData:GetSectionCfg().section_index]
        UILogicUtil.FloatAlert(string_format(Language.GetString(2630), sectionIndexStr))
    end
end

function SectionItem:OnDestroy()
    self:ClearNuqiEffect()
    UIUtil.RemoveClickEvent(self.m_cityImage.gameObject)
    base.OnDestroy(self)
end

function SectionItem:ClearNuqiEffect()
    if self.m_effect then
        self.m_effect:Delete()
        self.m_effect = nil
    end 
end

function SectionItem:ChangeAlpha(alpha)
    local color = nil
    local sectionData = Player:GetInstance():GetMainlineMgr():GetSectionData(self.m_sectionID)
    if sectionData and sectionData:GetOpenState(self.m_sectionType) then
        if self.m_sectionID >= CommonDefine.MAINLINE_SECTION_MONSTER_HOME and sectionData:IsAllNormalCopyClear() then
            color = Color.New(0,0,0, alpha)
        else
            color = Color.New(1,1,1, alpha)
        end
    else
        color = Color.New(0,0,0, alpha)
    end
    
    self.m_cityImage:SetColor(color)
end

function SectionItem:Unlock(isNew)
    self:GetGameObject():SetActive(true)
    self.m_lockGo:SetActive(false)
    self.m_nameRoot:SetActive(true)
    self.m_cityImage:SetColor(Color.white)
    self.m_unlockImgGo:SetActive(true)
    self.m_newImageGO:SetActive(isNew)
end

function SectionItem:GetSectionID()
    return self.m_sectionID
end 

function SectionItem:AddAdditionalEffect()
    if self.m_isNewest then
        if not self.m_AdditionalEffect then
            UIUtil.AddComponent(UIEffect, self, "", self.m_sortOrder, TheGameIds.UI_guankakaifang, function(effect)
                self.m_AdditionalEffect = effect
                self.m_AdditionalEffect:SetLocalPosition(Vector3.New(0, 45,0))
                self.m_AdditionalEffect:SetOrder(self.m_sortOrder)
            end)
        end
    else
        self:ClearAdditionalEffect()
    end
end

function SectionItem:ClearAdditionalEffect()
    if self.m_AdditionalEffect then
        self.m_AdditionalEffect:Delete()
        self.m_AdditionalEffect = nil
    end 
end

return SectionItem