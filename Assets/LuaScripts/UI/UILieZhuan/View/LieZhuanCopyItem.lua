local string_format = string.format
local ConfigUtil = ConfigUtil
local string_split = CUtil.SplitString
local Vector3 = Vector3
local Vector4 = Vector4
local effectPath = TheGameIds.UI_bigmapmisson_select_blue_path

local LieZhuanCopyItem = BaseClass("LieZhuanCopyItem", UIBaseItem)
local base = UIBaseItem

function LieZhuanCopyItem:OnCreate()
    base.OnCreate(self)
    self:InitView()
end

function LieZhuanCopyItem:InitView()
    self.m_nameText, self.m_lvText = UIUtil.GetChildTexts(self.transform, { "right/nameText", "right/lvText" })
    self.m_selectImage, self.m_lockImage = UIUtil.GetChildTransforms(self.transform, { "selectImage", "right/lockImage"})

    self.m_countryIcon = UIUtil.AddComponent(UIImage, self, "wujiang/countryIcon", ImageConfig.LieZhuan)
    self.m_wujiangIcon = UIUtil.AddComponent(UIImage, self, "wujiang/icon", AtlasConfig.RoleIcon)

    self.m_copyId = 0
    self.m_islocked = false
    self.m_selectEffect = nil
    self.m_layerName = UILogicUtil.FindLayerName(self.transform)
    self.m_sCountryNameList = string_split(Language.GetString(3739), ",")
    
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self:GetGameObject(), onClick)
end

function LieZhuanCopyItem:OnClick(go)
    if go == self:GetGameObject() and self.m_onClickCallback then
        if self.m_islocked then
            local sCopyId = self.m_copyId % 100
            UILogicUtil.FloatAlert(string.format(Language.GetString(3760), sCopyId - 1))
        else
            self.m_onClickCallback(self)
        end
    end
end

function LieZhuanCopyItem:UpdateData(copyCfg, islocked, onClickCallback, countryId)
    if copyCfg then
        self.m_copyId = copyCfg.id
        self.m_islocked = islocked
    
        if self.m_copyId == 0 then
            self.m_nameText.text = Language.GetString(3761)
            if countryId then
                self.m_countryIcon:SetAtlasSprite(countryId..".png")
                self.m_countryIcon.gameObject:SetActive(true)
                self.m_wujiangIcon.gameObject:SetActive(false)
            end
        else
            local sCopyId = self.m_copyId % 100
            self.m_nameText.text = string_format(Language.GetString(3748), self.m_sCountryNameList[copyCfg.country], sCopyId)
            self.m_wujiangIcon:SetAtlasSprite(copyCfg.icon)
            self.m_countryIcon.gameObject:SetActive(false)
            self.m_wujiangIcon.gameObject:SetActive(true)

            local battleRoundCfg = ConfigUtil.GetBattleRoundCfgByID(copyCfg.battleRoundTeam[1][1])
            if battleRoundCfg then
                self.m_lvText.text = string_format(Language.GetString(3728), battleRoundCfg.monsterLevel)
            end
        end
    end

    self.m_lvText.gameObject:SetActive(self.m_copyId ~= 0 and not islocked)
    self.m_lockImage.gameObject:SetActive(islocked)
    self.m_onClickCallback = onClickCallback
end

function LieZhuanCopyItem:GetCopyId()
    return self.m_copyId
end

function LieZhuanCopyItem:SetSelectState(show, showEffectBounds)
    if self.m_selectImage then
        self.m_selectImage.gameObject:SetActive(show)
    end

    if show then
        if not self.m_selectEffect then
            local sortOrder = UISortOrderMgr:GetInstance():PopSortingOrder(self, self.m_layerName)
            self.m_selectEffect = UIUtil.AddComponent(UIEffect, self, "", sortOrder, effectPath, function(effect)
                self.m_selectEffect = effect
                self.m_selectEffect:SetLocalPosition(Vector3.New(0, 0, 0))
                self.m_selectEffect:SetLocalScale(Vector3.New(1, 1, 1))
                if showEffectBounds then
                    local clipRegion = Vector4.New(showEffectBounds[0].x, showEffectBounds[0].y, showEffectBounds[2].x, showEffectBounds[2].y)
                    self.m_selectEffect:ClipParticleWithBounds(clipRegion)
                end
            end)
        end
    else
        self:ClearEffect()
    end

end

function LieZhuanCopyItem:ClearEffect()
    if self.m_selectEffect then
        self.m_selectEffect:Delete()
        self.m_selectEffect = nil
    end 
end

function LieZhuanCopyItem:OnDestroy()
    UIUtil.RemoveClickEvent(self:GetGameObject())
    UISortOrderMgr:GetInstance():PushSortingOrder(self, self.m_layerName)
    self:ClearEffect()
    self.m_onClickCallback = nil
    base.OnDestroy(self)
end


return LieZhuanCopyItem