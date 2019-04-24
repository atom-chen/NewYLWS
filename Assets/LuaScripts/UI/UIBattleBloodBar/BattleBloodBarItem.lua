local Time = Time
local Vector3 = Vector3
local Vector2 = Vector2
local IsNull = IsNull
local UIUtil = UIUtil
local ActorUtil = ActorUtil
local GameUtility = CS.GameUtility
local ScreenPointToLocalPointInRectangle = CS.UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle
local UISliderHelper = typeof(CS.UISliderHelper)

local BattleBloodBarItem = BaseClass("BattleBloodBarItem", UIBaseItem)
local base = UIBaseItem
local Vector3 = Vector3
local ActorManagerInst = ActorManagerInst
local BattleEnum = BattleEnum

local shield_path = "shieldSlider"
local blood_slider_path = "bloodSlider"
local blood_path = "bloodSlider/Fill Area/bloodSpt"
local fill_area_path = "bloodSlider/Fill Area"
local buff_path = "buffSlider"
local CtlBattleInst = CtlBattleInst
local UIManagerInst = UIManagerInst

local INVIS_Y = -5000

function BattleBloodBarItem:OnCreate(actorID, resPath, parentRectTrans)
    base.OnCreate(self)
    self.m_actorID = actorID
    self.m_resPath = resPath
    self.m_parentRectTrans = parentRectTrans

    self.m_mainCam = BattleCameraMgr:GetMainCamera()
    
    local typeRectTrans = typeof(CS.UnityEngine.RectTransform)
    self.m_bloodSlider = UIUtil.FindComponent(self.transform, UISliderHelper, blood_slider_path)
    self.m_shieldSlider = UIUtil.FindComponent(self.transform, UISliderHelper, shield_path)
    self.m_buffSlider = UIUtil.FindComponent(self.transform, UISliderHelper, buff_path)
    self.m_bloodRT = UIUtil.FindComponent(self.transform, typeRectTrans, blood_path)
    local rectTransform = UIUtil.FindComponent(self.transform, typeRectTrans, fill_area_path)

    self.m_buffGO = self.m_buffSlider.gameObject
    self.m_bloodWidth = rectTransform.sizeDelta.x
    self.m_bloodHeight = self.m_bloodRT.sizeDelta.y
    self.m_isBloodHide = false
    self.m_hideTime = 0
    self.m_lastHP = 0
    self.m_totalControlTime = 0
    self.m_leftControlTime = 0
    self:InitShiledValue()
    self:SetLocalScale()
    self:UpdateBloodBar(0)
    -- self.m_gameObject:SetActive(false)

    GameUtility.SetLocalPosition(self.transform, 0, INVIS_Y, 0)
end

function BattleBloodBarItem:OnDestroy()
    self.m_mainCam = nil
    
    self.m_bloodSlider:Dispose()
    self.m_shieldSlider:Dispose()
    self.m_buffSlider:Dispose()

    self.m_actorID = nil
    self.m_resPath = nil
    self.m_bloodSlider = nil
    self.m_shieldSpt = nil
    self.m_bloodSpt = nil
    self.m_isBloodHide = nil
    self.m_hideTime = 0
    self.m_parentRectTrans = nil
    self.m_shieldSlider = nil
    self.m_buffSlider = nil
    self.m_lastHP = nil
    self.m_lastShieldValue = nil
    self.m_totalControlTime = 0
    self.m_leftControlTime = 0
    self.m_bloodRT = nil
    self.m_buffGO = nil

    base.OnDestroy(self)
end

function BattleBloodBarItem:UpdateData(deltaTime)
    local actor = ActorManagerInst:GetActor(self.m_actorID)
    if not actor then
       return 
    end

    self:CheckBloodShow(deltaTime)
    local isControll = self:CheckControll(deltaTime)
    local isFight = CtlBattleInst:IsInFight()
    local needBlood = actor:NeedBlood()
    local showBlood = isFight and needBlood and (not self.m_isBloodHide or isControll)

    if not IsNull(self.m_buffGO) then
        if self.m_buffGO.activeSelf ~= isControll then
            self.m_buffGO:SetActive(isControll)
        end
    end

    if not IsNull(self.m_gameObject) then
        -- if self.m_gameObject.activeSelf ~= showBlood then
        --     self.m_gameObject:SetActive(showBlood)
        -- end
        if showBlood then
            self:RefreshPosition()
            self:CheckSheild()
        else
            GameUtility.SetLocalPosition(self.transform, 0, INVIS_Y, 0)
        end
    end
end

function BattleBloodBarItem:CheckBloodShow(deltaTime)
    self.m_hideTime = self.m_hideTime - deltaTime
    if self.m_hideTime <= 0 then
        self:HideBloodUI()
    end
end

function BattleBloodBarItem:RefreshPosition()
    local actor = ActorManagerInst:GetActor(self.m_actorID)
    if not actor then
       return 
    end

    local bloodBar = actor:GetBloodBarTransform()
        
	local ok, outV2 = GameUtility.TransformWorld2RectPos(self.m_mainCam, UIManagerInst.UICamera, bloodBar, self.m_parentRectTrans, 0)
    GameUtility.SetLocalPosition(self.transform, outV2.x, outV2.y, 10)
end

function BattleBloodBarItem:HideBloodUI()
    self.m_isBloodHide = true
    self.m_hideTime = -1
end

function BattleBloodBarItem:ShowBloodUI()
    self.m_isBloodHide = false
    self.m_hideTime = 2
end

function BattleBloodBarItem:UpdateBloodBar()
    local actor = ActorManagerInst:GetActor(self.m_actorID)
    if not actor then
       return 
    end

    local actorData = actor:GetData()
    if not actorData then
        return
    end

    local curHP = actorData:GetAttrValue(ACTOR_ATTR.FIGHT_HP)
    local maxHP = actorData:GetAttrValue(ACTOR_ATTR.FIGHT_MAXHP)
    local newPercent = curHP / maxHP

    local shieldPercent = newPercent + actor:GetTotalShieldValue() / maxHP
    if shieldPercent > 1 then
        newPercent = newPercent / shieldPercent
    end
    
    self.m_bloodRT.sizeDelta = Vector2.New(self.m_bloodWidth * newPercent, self.m_bloodHeight)

    local hpChg = curHP - self.m_lastHP
    if hpChg >= 0 or newPercent > self.m_bloodSlider:GetSliderValue() then
        self.m_bloodSlider:UpdateSliderImmediately(newPercent)
    else
        local time = (-hpChg) / maxHP * 5
        time = time > 2 and 2 or time
        newPercent = newPercent < 0.02 and 0.02 or newPercent
        self.m_bloodSlider:TweenUpdateSlider(newPercent, time)
    end
    self.m_lastHP = curHP
end

function BattleBloodBarItem:CheckControll(deltaTime)
    if self.m_leftControlTime <= 0 then
        return false
    end

    self.m_leftControlTime = self.m_leftControlTime - deltaTime

    return true
end

function BattleBloodBarItem:OnControl(controlMSTime)
    local controlTime = controlMSTime / 1000
    if controlTime > self.m_leftControlTime then
        self.m_leftControlTime = controlTime
        self.m_totalControlTime = controlTime
        self.m_buffSlider:UpdateSliderImmediately(1)
        self.m_buffSlider:TweenUpdateSlider(0, self.m_totalControlTime)
    end
end

function BattleBloodBarItem:CheckSheild()
    local actor = ActorManagerInst:GetActor(self.m_actorID)
    if not actor then
       return 
    end

    local actorData = actor:GetData()
    if not actorData then
        return
    end

    local shieldValue = actor:GetTotalShieldValue()
    if shieldValue <= 0 then
        if self.m_lastShieldValue ~= shieldValue then
            self:ShowBloodUI()
            self.m_shieldSlider:UpdateSliderImmediately(0)
            self:UpdateBloodBar()
            self.m_lastShieldValue = shieldValue
        end
        return
    end

    if self.m_lastShieldValue ~= shieldValue then
        self:ShowBloodUI()
        self.m_lastShieldValue = shieldValue
    end

    local curHP = actorData:GetAttrValue(ACTOR_ATTR.FIGHT_HP)
    local maxHP = actorData:GetAttrValue(ACTOR_ATTR.FIGHT_MAXHP)

    local shieldPercent = (curHP + shieldValue) / maxHP
    if shieldPercent > 1 then
        shieldPercent = 1
    end
    
    local hpChg = curHP - self.m_lastHP
    if hpChg >= 0 then
        self.m_shieldSlider:UpdateSliderImmediately(shieldPercent)
    else
        local time = (-chgVal) / maxHP * 5
        time = time > 2 and 2 or time
        self.m_shieldSlider:TweenUpdateSlider(shieldPercent, time)
    end
    self:UpdateBloodBar()
end

function BattleBloodBarItem:SetLocalScale()
    local actor = ActorManagerInst:GetActor(self.m_actorID)
    if not actor then
        GameUtility.SetLocalScale(self.transform, 1, 1, 1)
        return
    end

    if actor:IsCalled() or ActorUtil.IsAnimal(actor) then
        GameUtility.SetLocalScale(self.transform, 0.667, 0.667, 0.667)
        return
    end
    
    if actor:GetMonsterID() > 0 then
        if actor:GetBossType() == BattleEnum.BOSSTYPE_SMALL then
            GameUtility.SetLocalScale(self.transform, 0.8, 0.8, 0.8)
        else
            GameUtility.SetLocalScale(self.transform, 0.667, 0.667, 0.667)
        end
    else
        GameUtility.SetLocalScale(self.transform, 0.8, 0.8, 0.8)
    end
end

function BattleBloodBarItem:InitShiledValue()
    self.m_lastShieldValue = 0
    self.m_shieldSlider:UpdateSliderImmediately(0)
end

return BattleBloodBarItem

