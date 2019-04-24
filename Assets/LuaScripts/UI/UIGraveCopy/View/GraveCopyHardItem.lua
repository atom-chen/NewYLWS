local Language = Language
local CommonDefine = CommonDefine
local UIUtil = UIUtil
local SplitString = CUtil.SplitString
local string_format = string.format
local ConfigUtil = ConfigUtil
local Color = Color
local Vector3 = Vector3
local Vector4 = Vector4

local CardItemPath = TheGameIds.CommonWujiangCardPrefab
local EffectPath_Blue = TheGameIds.UI_bigmapmisson_select_blue_path
local EffectPath_Purple = TheGameIds.UI_bigmapmisson_select_purple_path

local GraveCopyHardItem = BaseClass("GraveCopyHardItem", UIBaseItem)
local base = UIBaseItem

function GraveCopyHardItem:OnCreate()
    self.m_copyID = 0
    self.m_selectEffect = nil
    self.m_effectPath = nil
    
    self.m_clickBtn, self.m_lockImage = UIUtil.GetChildTransforms(self.transform, {
        "clickBtn",
        "lockImage"
    })

    self.m_nameText, self.m_descText = UIUtil.GetChildTexts(self.transform, {
        "nameText", "descText",
    })

    self.m_selectImage = UIUtil.AddComponent(UIImage, self, "selectImage", AtlasConfig.DynamicLoad)
    self.m_selectImageGO = self.m_selectImage.gameObject
    self.m_lockImage = self.m_lockImage.gameObject

    self.m_layerName = UILogicUtil.FindLayerName(self.transform)
    self.m_locked = true

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_clickBtn.gameObject, onClick)
end

function GraveCopyHardItem:SetData(copyID, locked, isSelected, showEffectBounds)
    self.m_copyID = copyID

    local copyCfg = ConfigUtil.GetGraveCopyCfgByID(copyID)
    if not copyCfg then
        return
    end

    self.m_locked = locked
    self.m_lockImage:SetActive(locked)
    
    self.m_selectImage:SetAtlasSprite("zhuxian9.png", true, AtlasConfig.DynamicLoad)
    self.m_effectPath = EffectPath_Blue
    self.m_nameText.text = copyCfg.name
    self:DoSelect(isSelected, showEffectBounds)

    self.m_descText.text = ""

    if locked then
        if Player:GetInstance():GetUserMgr():GetUserData().level < copyCfg.level then
            self.m_descText.text = string_format(Language.GetString(1804), copyCfg.level)
            return 
        end

        local preCopyCfg = ConfigUtil.GetGraveCopyCfgByID(copyID - 1)
        if preCopyCfg then
            self.m_descText.text = string_format(Language.GetString(1805), preCopyCfg.name)
        end
    else
        local battleRound = copyCfg.battleRound[1]
        local battleRoundCfg = ConfigUtil.GetBattleRoundCfgByID(battleRound[1])
        if battleRoundCfg then
            self.m_descText.text = string_format(Language.GetString(2819), battleRoundCfg.monsterLevel)
        end
    end
end

function GraveCopyHardItem:DoSelect(isSelected, showEffectBounds)
    self.m_selectImageGO:SetActive(isSelected)
    if isSelected then
        if not self.m_selectEffect then
            local sortOrder = UISortOrderMgr:GetInstance():PopSortingOrder(self, self.m_layerName)
            UIUtil.AddComponent(UIEffect, self, "", sortOrder, self.m_effectPath, function(effect)
                self.m_selectEffect = effect
                self.m_selectEffect:SetLocalPosition(Vector3.New(-49, -8, 0))

                local clipRegion = Vector4.New(showEffectBounds[0].x, showEffectBounds[0].y, showEffectBounds[2].x, showEffectBounds[2].y)
                self.m_selectEffect:ClipParticleWithBounds(clipRegion)
            end)
        end
    else
        self:ClearEffect()
    end
end

function GraveCopyHardItem:GetCopyID()
    return self.m_copyID
end

function GraveCopyHardItem:OnClick(go, x, y)
    if self.m_locked then
        return
    end

    UIManagerInst:Broadcast(UIMessageNames.MN_GRAVE_COPY_CLICK_COPY, self.m_copyID)
end

function GraveCopyHardItem:OnDestroy()
    UISortOrderMgr:GetInstance():PushSortingOrder(self, self.m_layerName)

    UIUtil.RemoveClickEvent(self.m_clickBtn.gameObject)

    self:ClearEffect()
    self.m_effectPath = nil

    base.OnDestroy(self)
end

function GraveCopyHardItem:ClearEffect()
    if self.m_selectEffect then
        self.m_selectEffect:Delete()
        self.m_selectEffect = nil
    end 
end

return GraveCopyHardItem