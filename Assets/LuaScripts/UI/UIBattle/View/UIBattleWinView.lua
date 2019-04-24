local UIBattleWinView = BaseClass("UIBattleWinView", UIBaseView)
local base = UIBaseView
local UIUtil = UIUtil
local CtlBattleInst = CtlBattleInst

function UIBattleWinView:OnCreate()
    base.OnCreate(self)
    
    self:InitView()
end

function UIBattleWinView:InitView()

    self.GoBackBtnTrans, self.starListTrans = UIUtil.GetChildTransforms(self.transform, {
        "GoBack_BTN",
        "Canvas/starList",
    })

    self.m_showStarDedayTime = 0
    self.m_countDownTime = 0
    self.starListTrans.gameObject:SetActive(false)

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.GoBackBtnTrans.gameObject, onClick)

    self:AddComponent(UICanvas, "Canvas", 3)

end

function UIBattleWinView:OnEnable(initOrder)
    base.OnEnable(self)

    if not self.m_winEffect then
        local sortOrder = self:PopSortingOrder()
        self.m_winEffect = self:AddComponent(UIEffect, "Container", sortOrder, TheGameIds.BattleWin, function()
            self.m_winEffect:SetLocalPosition(Vector3.New(0, -51.8, 0))
            self.m_winEffect:SetLocalScale(Vector3.New(100, 100, 100))

            self.m_showStarDedayTime = 2.2
        end)
    end
    
    if Player:GetInstance():GetMainlineMgr():IsAutoFight() then
        self.m_countDownTime = 3
    end
end

function UIBattleWinView:Update()
    if self.m_showStarDedayTime > 0 then
        self.m_showStarDedayTime = self.m_showStarDedayTime - Time.deltaTime
        if  self.m_showStarDedayTime <= 0 then
            self.starListTrans.gameObject:SetActive(true)
        end
    end

    if self.m_countDownTime > 0 then
        self.m_countDownTime = self.m_countDownTime - Time.deltaTime
        if self.m_countDownTime <= 0 then
            local battleLogic = CtlBattleInst:GetLogic()
            if battleLogic then
                battleLogic:OnCityReturn()
            end
        end
    end
end

function UIBattleWinView:OnDestroy()
    UIUtil.RemoveClickEvent(self.GoBackBtnTrans.gameObject)

    if self.m_winEffect then
        self:RemoveComponent(self.m_winEffect:GetName(), UIEffect)
        self.m_winEffect = nil
    end 

    base.OnDestroy(self)
end

function UIBattleWinView:OnClick(go, x, y)
    if go.name == "GoBack_BTN" then
        local battleLogic = CtlBattleInst:GetLogic()
        if battleLogic then
            battleLogic:OnCityReturn()
        end
    end
end

function UIBattleWinView:GetOpenAudio()
	return 120
end


return UIBattleWinView