local base = require "UI.UIBattleRecord.View.BattleSettlementView"
local UILieZhuanSettlementView = BaseClass("UILieZhuanSettlementView", base)
local LieZhuanMgr = Player:GetInstance():GetLieZhuanMgr()
local WAITTIME = 2

function UILieZhuanSettlementView:OnEnable(...)
    base.OnEnable(self,...)

    self.m_teamInfo = LieZhuanMgr:GetTeamInfo()
    self.m_liftTime = Player:GetInstance():GetServerTime() + WAITTIME
    self.m_autoNextFight = LieZhuanMgr:GetSelfAutoNextFight()
end

function UILieZhuanSettlementView:OnClick(go, x, y)

    if go.name == "finish_BTN" then
        if self.m_finish then
            self:OnReturnHomeScene()
        end
    end
end

function UILieZhuanSettlementView:OnReturnHomeScene()
    if self.m_teamInfo then
        local data = {}
        GamePromptMgr:GetInstance():InstallPrompt(CommonDefine.LIEZHUAN_TEAM_FIGHT_END, data)
    end
    SceneManagerInst:SwitchScene(SceneConfig.HomeScene)
end

function UILieZhuanSettlementView:Update()
    if self.m_autoNextFight then
        local refreshTime = self.m_liftTime
        local curTime = Player:GetInstance():GetServerTime() 
    
        local leftS = refreshTime - curTime
        if leftS and leftS < 0 then
            self.m_autoNextFight = false
            self:OnReturnHomeScene()
        end
    end
end

return UILieZhuanSettlementView