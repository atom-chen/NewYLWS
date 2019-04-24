local table_insert = table.insert
local table_count = table.count
local table_values = table.values
local string_format = string.format
local CommonDefine = CommonDefine
local Time = Time
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local DOTween = CS.DOTween.DOTween
local GameUtility = CS.GameUtility
local Vector3 = Vector3
local Quaternion = Quaternion
local CopyDetailItem = require "UI.Mainline.CopyDetailItem"
local CopyDetailItemPath = "UI/Prefabs/Mainline/CopyDetailItem.prefab"
local BagItemPrefabPath = TheGameIds.CommonBagItemPrefab
local RotateStart = Quaternion.Euler(0, 0, -8)
local RotateEnd = Vector3.New(0, 0, 8)
local SpringContent = CS.SpringContent
local itemHeight = 164.8

local UICopyDetailView = require "UI.Mainline.UICopyDetailView"
local UIMonsterHomeDetailView = BaseClass("UIMonsterHomeDetailView", UICopyDetailView)
local base = UICopyDetailView

function UIMonsterHomeDetailView:OnEnable(...)
    base.OnEnable(self, ...)
    self.m_bgRoot.sizeDelta = Vector2.New(1190, 630)
    self.m_topRoot.anchoredPosition = Vector3.New(0, -58, 0)
    self.m_bottomRoot.gameObject:SetActive(false)
    self.m_autoFightCheckBox:SetActive(false)

    local sectionData = self.m_mainlineMgr:GetSectionData(self.m_sectionID)
    if sectionData and self.m_sectionID >= CommonDefine.MAINLINE_SECTION_MONSTER_HOME and sectionData:IsAllNormalCopyClear() then
        self:CloseSelf()
    end
    self:UpdateView(true)
end

function UIMonsterHomeDetailView:OnDisable()
    self.m_bgRoot.sizeDelta = Vector2.New(1190, 730)
    self.m_topRoot.anchoredPosition = Vector3.zero
    self.m_bottomRoot.gameObject:SetActive(true)
    self.m_autoFightCheckBox:SetActive(true)

    base.OnDisable(self)
end

function UIMonsterHomeDetailView:UpdateCopyDetail(sectionData)
    local copyCfg = ConfigUtil.GetCopyCfgByID(self:GetCurCopyID())
    if not copyCfg then
        return
    end
    local starCount = 0
    local copyData = self.m_mainlineMgr:GetCopyData(self:GetCurCopyID())
    if copyData then
        starCount = copyData:GetStarCount()
    end
    self.m_starRoot:SetActive(false)

    local copyIndex = sectionData:GetNormalLevelByID(self:GetCurCopyID())
    self.m_copyNameText.text = copyCfg.name
    self.m_typeDesText.text = Language.GetString(2603)
    self.m_leftTimesTextGO:SetActive(false)
    self.m_copyTypeImage:SetAtlasSprite("zhuxian12.png")
    
    self.m_consumeText.text = string_format(Language.GetString(2607), 36, self:GetAutoFightTimes())
    self.m_fightConsumeText.text = copyCfg.stamina

    self.m_copyDesText.text = copyCfg.desc

    self.m_autoFightSelect:SetActive(self.m_uiData.isAutoFight)
end


return UIMonsterHomeDetailView