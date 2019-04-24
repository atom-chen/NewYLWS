local UIUtil = UIUtil
local Vector3 = Vector3
local string_len = string.len
local string_split = string.split
local UILogicUtil = UILogicUtil
local UIImage = UIImage
local AtlasConfig = AtlasConfig
local UserMgr = Player:GetInstance():GetUserMgr()
local RotateStart = Quaternion.Euler(0, 0, -8)
local RotateEnd = Vector3.New(0, 0, 8)
local EffectPath = "UI/Effect/Prefabs/ui_baoxiang_fx"

local StarPanelBoxItem = BaseClass("StarPanelBoxItem", UIBaseItem)
local base = UIBaseItem

function StarPanelBoxItem:OnCreate()
    base.OnCreate(self)

    self:InitView()

    self:HandleClick()
end

function StarPanelBoxItem:InitView()
    self.m_boxFrame, self.m_redPoint = UIUtil.GetChildRectTrans(self.transform, {"boxFrame", "redPoint"})

    self.m_boxIcon = UIUtil.AddComponent(UIImage, self, "boxIcon", AtlasConfig.DynamicLoad)

    self.m_starItemCfg = nil
    self.m_selfOnClickCallback = nil

    self.m_iconRotateTweener = nil

    self.m_haveGetBox = false
    self.m_canGetBoxAward = false
end

function StarPanelBoxItem:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_gameObject, onClick)
end

function StarPanelBoxItem:OnClick(go, x, y)
    if not go then
        return
    end

    if go == self.m_gameObject then
        if self.m_canGetBoxAward then
            UserMgr:ReqTakeActiveStarAward(self.m_starItemCfg.id)
        elseif not self.m_haveGetBox then
            if self.m_selfOnClickCallback then
                self.m_selfOnClickCallback(self)
            end
        end
    end
end

function StarPanelBoxItem:OnDestroy()

    UIUtil.RemoveClickEvent(self.m_boxFrame.gameObject)

    self.m_boxFrame = nil
    self.m_redPoint = nil

    if self.m_boxIcon then
        self.m_boxIcon:Delete()
        self.m_boxIcon = nil
    end

    self.m_starItemCfg = nil
    self.m_selfOnClickCallback = nil

    if self.m_iconRotateTweener then
        UIUtil.KillTween(self.m_iconRotateTweener)
    end

    self:ClearEffect()
    base.OnDestroy(self)
end

function StarPanelBoxItem:UpdateData(starItemCfg, sortOrder, selfOnClickCallBack)
    if not starItemCfg then
        return
    end
    self.m_starItemCfg = starItemCfg
    self.m_selfOnClickCallback = selfOnClickCallBack

    local starItemPos = UILogicUtil.GetStarCfgItemPos(starItemCfg)
    local posOffset = UILogicUtil.GetStarCfgBoxOffset(starItemCfg)
    if starItemPos and posOffset then
        local pos = Vector3.New(starItemPos.x + posOffset.x, starItemPos.y + posOffset.y, starItemPos.z + posOffset.z)
        self.transform.localPosition = pos
    end
    local dir = posOffset:Mul(-1)
    local angle = Vector3.Angle(dir, Vector3.down)
    local cross1 = Vector3.Cross(dir, Vector3.down)
    local cross2 = Vector3.Cross(Vector3.right, Vector3.down)
    angle = Vector3.Dot(cross1, cross2) >= 0 and angle or - angle
    local q = Quaternion.Euler(0, 0, angle)
    self.m_boxFrame.localRotation = q

    self.m_haveGetBox = UserMgr:CheckHaveGetStarBoxAward(starItemCfg.id)
    local haveActive = UserMgr:CheckStarIsActive(starItemCfg.id)
    self.m_canGetBoxAward = not self.m_haveGetBox and haveActive
    local sptName = self.m_haveGetBox and "zhuxian17.png" or "zhuxian18.png"
    self.m_boxIcon:SetAtlasSprite(sptName, false)
    if self.m_canGetBoxAward then

        UIUtil.AddComponent(UIEffect, self, "", sortOrder, EffectPath, function(effect)
            effect:SetLocalPosition(Vector3.zero)
            effect:SetLocalScale(Vector3.one)
            self.m_effect = effect
        end)
        --震动
        self.m_iconRotateTweener = UIUtil.TweenRotateToShake(self.m_boxIcon.transform, self.m_iconRotateTweener, RotateStart, RotateEnd)
    else
        self:ClearEffect()
    end
    self.m_redPoint.gameObject:SetActive(self.m_canGetBoxAward)
end

function StarPanelBoxItem:ClearEffect()
    if self.m_effect then
        self.m_effect:Delete()
        self.m_effect = nil
    end
end

function StarPanelBoxItem:GetStarItemCfg()
    return self.m_starItemCfg
end

return StarPanelBoxItem