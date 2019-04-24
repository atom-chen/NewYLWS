local UIBattleLoseView = BaseClass("UIBattleLoseView", UIBaseView)
local base = UIBaseView
local UIUtil = UIUtil

local CtlBattleInst = CtlBattleInst

function UIBattleLoseView:OnCreate()
    base.OnCreate(self)
    
    self:InitView()
end

function UIBattleLoseView:OnEnable(...)
    base.OnEnable(self, ...)

    if Player:GetInstance():GetMainlineMgr():IsAutoFight() then
        self.m_countDownTime = 3
    end
end

function UIBattleLoseView:InitView()
    self.m_countDownTime = 0
    
    self.GoBackBtnTrans = UIUtil.GetChildTransforms(self.transform, {
        "GoBack_BTN",
    })

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.GoBackBtnTrans.gameObject, onClick)

    if not self.m_loseEffect then
        self.m_loseEffect = self:AddComponent(UIEffect, "Container", 1, TheGameIds.BattleLose, function()
            self.m_loseEffect:SetLocalPosition(Vector3.New(0, -51.8, 0))
            self.m_loseEffect:SetLocalScale(Vector3.New(100, 100, 100))
        end)
    end
end

function UIBattleLoseView:Update()
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


function UIBattleLoseView:OnClick(go, x, y)
    if go.name == "GoBack_BTN" then
        local battleLogic = CtlBattleInst:GetLogic()
        if battleLogic then
            battleLogic:OnCityReturn()
        end
    end
end

function UIBattleLoseView:OnDestroy()
    UIUtil.RemoveClickEvent(self.GoBackBtnTrans.gameObject)

    if self.m_loseEffect then
        self:RemoveComponent(self.m_loseEffect:GetName(), UIEffect)
        self.m_loseEffect = nil
    end 

    base.OnDestroy(self)
end

function UIBattleLoseView:GetOpenAudio()
	return 121
end


return UIBattleLoseView