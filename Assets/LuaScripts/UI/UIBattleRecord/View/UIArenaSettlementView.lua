local base = require "UI.UIBattleRecord.View.BattleSettlementView"
local UIArenaSettlementView = BaseClass("UIArenaSettlementView", base)

local CtlBattleInst = CtlBattleInst

function UIArenaSettlementView:OnEnable(...)
    base.OnEnable(self)

    local order, playerWin, drop_list = ...
    local msgObj = {
        drop_list = drop_list
    }

    self.m_msgObj = msgObj

    if playerWin then
        self:HandleWinOrLoseEffect(0)
    else
        self:HandleWinOrLoseEffect(1)
    end

    self:CoroutineDrop()

    self.starListTrans.gameObject:SetActive(false)
    self.m_bottomContentTr.gameObject:SetActive(drop_list and #drop_list > 0)

    self:UpdateTimeout()
end

function UIArenaSettlementView:OnClick(go, x, y)
    if go.name == "finish_BTN" then
        if self.m_finish then
            SceneManagerInst:SwitchScene(SceneConfig.HomeScene)
        end
    elseif go.name == "record_BTN" then
        if self.m_finish then
            self:Hide()
            local battleLogic = CtlBattleInst:GetLogic()
            if battleLogic:GetBattleType() == BattleEnum.BattleType_FRIEND_CHALLENGE then
                UIManagerInst:OpenWindow(UIWindowNames.BattleRecord, self.m_msgObj)
            else
                UIManagerInst:OpenWindow(UIWindowNames.BattleRecordFromSever, self.m_msgObj)
            end            
        end
    end
end

function UIArenaSettlementView:GetBattleResult()
    local logic = CtlBattleInst:GetLogic()
    if logic then
        return logic:GetBattleResult()
    end
end

function UIArenaSettlementView:GetOpenAudio()
    if self:GetBattleResult() == 0 then
	    return 120
    else
        return 121
    end
end

function UIArenaSettlementView:UpdateTimeout()
    if self:GetBattleResult() == 2 then
        self.m_timeoutText.transform.localPosition = Vector3.New(0, 110, 0)
    else
        self.m_timeoutText.transform.localPosition = Vector3.New(0, 100, 0)
    end
end

return UIArenaSettlementView