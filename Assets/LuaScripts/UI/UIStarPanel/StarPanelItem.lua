local tonumber = tonumber
local string_split = string.split
local Vector3 = Vector3
local AtlasConfig = AtlasConfig
local UIImage = UIImage
local UIUtil = UIUtil
local Color = Color
local UILogicUtil = UILogicUtil

local ActivePath = "UI/Effect/Prefabs/ui_xingpan_jihuo"
local CanActivePath = "UI/Effect/Prefabs/ui_xingpan_guang"

local StarPanelItem = BaseClass("StarPanelItem", UIBaseItem)
local base = UIBaseItem

function StarPanelItem:OnCreate()
    base.OnCreate(self)

    self:InitView()

    self:HandleClick()
end

function StarPanelItem:InitView()

    self.m_starNameText = UIUtil.GetChildTexts(self.transform, {
        "starNameText"
    })
    self.m_starIcon = UIUtil.AddComponent(UIImage, self, "starIcon", ImageConfig.XingPan)
    self.m_starFrame = UIUtil.AddComponent(UIImage, self, "starFrame", AtlasConfig.DynamicLoad)
    self.m_starSelectSpt = UIUtil.AddComponent(UIImage, self, "starSelectSpt", AtlasConfig.DynamicLoad)

    self.m_starItemCfg = nil
    self.m_pos = nil

    self.m_selfOnClickCallback = nil
    self.m_isOnSelected = false
end

function StarPanelItem:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_gameObject, onClick)
end

function StarPanelItem:OnClick(go, x, y)
    if not go then
        return
    end
    local goName = go.name
    if go == self.m_gameObject then
        if self.m_selfOnClickCallback then
            self.m_selfOnClickCallback(self)
        end
    end
end

function StarPanelItem:OnDestroy()

    UIUtil.RemoveClickEvent(self.m_gameObject)

    self:ClearEffect()

    if self.m_starIcon then
        self.m_starIcon:Delete()
        self.m_starIcon = nil
    end
    if self.m_starFrame then
        self.m_starFrame:Delete()
        self.m_starFrame = nil
    end
    if self.m_starSelectSpt then
        self.m_starSelectSpt:Delete()
        self.m_starSelectSpt = nil
    end

    self.m_starNameText = nil

    self.m_starItemCfg = nil
    self.m_pos = nil

    self.m_selfOnClickCallback = nil

    base.OnDestroy(self)
end

function StarPanelItem:OnDisable()

    self.m_starItemCfg = nil

    self.m_selfOnClickCallback = nil

    base.OnDisable(self)
end

function StarPanelItem:UpdateData(starItemCfg, selfOnClickCallback)
    if not starItemCfg then
        return
    end
    
    self.m_starItemCfg = starItemCfg

    self.m_starNameText.text = starItemCfg.star_attr

    local starItemPos = UILogicUtil.GetStarCfgItemPos(starItemCfg)
    self.m_pos = starItemPos
    self.transform.localPosition = starItemPos

    self.m_starIcon:SetAtlasSprite(starItemCfg.sIcon, false)

    self.m_selfOnClickCallback = selfOnClickCallback

    self:SetOnSelectState(false)

    --设置名字的位置
    local name_pos = Vector3.New(0, -100, 0)
    if starItemCfg.name_pos then
        local posStrArr = string_split(starItemCfg.name_pos, "|")
        if posStrArr and #posStrArr >= 2 then
            local posX = tonumber(posStrArr[1])
            local posY = tonumber(posStrArr[2])
            name_pos = Vector3.New(posX, posY, 0)
        end
    end
    self.m_starNameText.transform.localPosition = name_pos
    self.m_gameObject.name = starItemCfg.star_index
end

function StarPanelItem:SetOnSelectState(isSelect)
    self.m_isOnSelected = isSelect
    self.m_starSelectSpt.gameObject:SetActive(isSelect)
end

function StarPanelItem:GetPos()
    return self.m_pos
end

function StarPanelItem:Effect(sortOrder, canActiveEffect, activeEffect)
    if canActiveEffect then
        if not self.m_canActiveEffect then
            UIUtil.AddComponent(UIEffect, self, "", sortOrder, CanActivePath, function(effect)
                effect:SetLocalPosition(Vector3.zero)
                effect:SetLocalScale(Vector3.one)
                self.m_canActiveEffect = effect
            end)
        end
    elseif activeEffect then
        if not self.m_activeEffect then
            UIUtil.AddComponent(UIEffect, self, "", sortOrder, ActivePath, function(effect)
                effect:SetLocalPosition(Vector3.zero)
                effect:SetLocalScale(Vector3.one)
                self.m_activeEffect = effect
            end)
        end
    else
        self:ClearEffect()
    end
end

function StarPanelItem:ClearEffect()
    if self.m_canActiveEffect then
        self.m_canActiveEffect:Delete()
        self.m_canActiveEffect = nil
    end

    if self.m_activeEffect then
        self.m_activeEffect:Delete()
        self.m_activeEffect = nil
    end
end

function StarPanelItem:GetStarItemCfg()
    return self.m_starItemCfg
end

function StarPanelItem:GetStarIndex()
    return self.m_starItemCfg and self.m_starItemCfg.star_index or 0
end

function StarPanelItem:SetActiveState(isActive)
    isActive = isActive and isActive or false
    self.m_isActive = isActive
    local color = isActive and Color.white or Color.black
    self.m_starIcon:SetColor(color)
    self.m_starFrame:SetColor(color)
    --self.m_starSelectSpt:SetColor(color)
end

function StarPanelItem:GetFrameImage()
    if self.m_starFrame then
        return self.m_starFrame
    end
end

return StarPanelItem