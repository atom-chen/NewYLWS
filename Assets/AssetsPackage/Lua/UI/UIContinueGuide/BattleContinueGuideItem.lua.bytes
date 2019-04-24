local Time = Time
local Vector3 = Vector3
local Vector2 = Vector2
local IsNull = IsNull
local UIUtil = UIUtil
local ActorUtil = ActorUtil
local ActorManagerInst = ActorManagerInst
local GameUtility = CS.GameUtility
local ScreenPointToLocalPointInRectangle = CS.UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle
local UISliderHelper = typeof(CS.UISliderHelper)
local typeRectTrans = typeof(CS.UnityEngine.RectTransform)
local BattleEnum = BattleEnum
local CtlBattleInst = CtlBattleInst

local BattleContinueGuideItem = BaseClass("BattleContinueGuideItem", UIBaseItem)
local base = UIBaseItem
local Vector3 = Vector3

local guide_slider_path = "guideSlider"
local fill_area_path = "guideSlider/Fill Area"
local guide_fill_path = "guideSlider/Fill Area/guide"

function BattleContinueGuideItem:OnCreate(actorID, resPath, parentRectTrans, guideTime)
    base.OnCreate(self)
    self.m_actorID = actorID
    self.m_resPath = resPath
    self.m_parentRectTrans = parentRectTrans
    
    self.m_guideSlider = UIUtil.FindComponent(self.transform, UISliderHelper, guide_slider_path)
    self.m_guideRT = UIUtil.FindComponent(self.transform, typeRectTrans, guide_fill_path)
    local rectTransform = UIUtil.FindComponent(self.transform, typeRectTrans, fill_area_path)

    self.m_totalGuideTime = guideTime
    self.m_leftGuideTime = guideTime
    self:InitShiledValue()
    self:SetLocalScale()
    self.m_gameObject:SetActive(true)
end

function BattleContinueGuideItem:OnDestroy()
    self.m_guideSlider:Dispose()

    self.m_actorID = false
    self.m_resPath = false
    self.m_guideSlider = false
    self.m_shieldSpt = false
    self.m_bloodSpt = false
    self.m_parentRectTrans = false
    self.m_lastShieldValue = false
    self.m_totalGuideTime = 0
    self.m_leftGuideTime = 0

    base.OnDestroy(self)
end

function BattleContinueGuideItem:UpdateData(deltaTime)
    local actor = ActorManagerInst:GetActor(self.m_actorID)
    if not actor then
       return 
    end

    local isGuide = self:CheckGuideTime(deltaTime)
    local isFight = CtlBattleInst:IsInFight()
    local showGuide = isFight and isGuide

    if not IsNull(self.m_gameObject) then
        if showGuide then
            self:RefreshPosition()
            self:UpdateGuideValue(deltaTime)
        end
    end

    return showGuide
end

function BattleContinueGuideItem:RefreshPosition()
    local actor = ActorManagerInst:GetActor(self.m_actorID)
    if not actor then
       return 
    end

    local bloodBar = actor:GetBloodBarTransform()
	local ok, outV2 = GameUtility.TransformWorld2RectPos(BattleCameraMgr:GetMainCamera(), UIManagerInst.UICamera, bloodBar, self.m_parentRectTrans, 0)
    GameUtility.SetLocalPosition(self.transform, outV2.x, outV2.y + 10, 10)
end

function BattleContinueGuideItem:UpdateGuideValue(deltaTime)
    local updateGuideValue = self.m_leftGuideTime / self.m_totalGuideTime
    self.m_guideSlider:UpdateSliderImmediately(updateGuideValue)
end


function BattleContinueGuideItem:CheckGuideTime(deltaTime)
    if self.m_leftGuideTime <= 0 then
        return false
    end

    self.m_leftGuideTime = self.m_leftGuideTime - deltaTime
    return true
end

function BattleContinueGuideItem:SetLocalScale()
    local actor = ActorManagerInst:GetActor(self.m_actorID)
    if not actor then
        GameUtility.SetLocalScale(self.transform, 1, 1, 1)
        return
    end
    
    if actor:GetMonsterID() > 0 then
        GameUtility.SetLocalScale(self.transform, 0.667, 0.667, 0.667)
    else
        GameUtility.SetLocalScale(self.transform, 1, 1, 1)
    end
end

function BattleContinueGuideItem:InitShiledValue()
    self.m_lastShieldValue = 1
    self.m_guideSlider:UpdateSliderImmediately(1)
end

return BattleContinueGuideItem

