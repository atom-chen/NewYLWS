local UILineupMainView = require("UI.Lineup.UILineupMainView")
local UICampsRushLineupView = BaseClass("UICampsRushLineupView", UILineupMainView)
local base = UILineupMainView

local Lineup_Type = {
    MAIN = 1, --主力
    BENCH = 2,--替补
}

function UICampsRushLineupView:OnEnable(...)
    self.m_lineupType = Lineup_Type.MAIN

    base.OnEnable(self, ...)

    self.m_bottomContainer.sizeDelta = Vector2.New(1566, self.m_bottomContainer.sizeDelta.y)
    self.m_lineupRoleContent:SetActive(false)
    self.m_benchRoleContent:SetActive(true)
end

function UICampsRushLineupView:SendFightReq()
    Player:GetInstance():GetCampsRushMgr():ReqEnterCamps(self.m_copyID)
end

function UICampsRushLineupView:OpenWujiangSeleteUI(standPos)
    UIManagerInst:OpenWindow(UIWindowNames.UICampsRushSelect, self.m_battleType, standPos, self.m_lineupType == Lineup_Type.MAIN)
end

function UICampsRushLineupView:UpdateLineup()
    self:UpdateMainAndBenchState()
    base.UpdateLineup(self)
end

function UICampsRushLineupView:UpdateMainAndBenchState()
    self.m_lineupBtnImage:SetColor(self.m_lineupType == Lineup_Type.MAIN and Color.white or Color.black)
    self.m_benchBtnImage:SetColor(self.m_lineupType ~= Lineup_Type.MAIN and Color.white or Color.black)
    self.m_benchIconBg3:SetActive(self.m_lineupType == Lineup_Type.MAIN and true or false)
    self.m_benchIconBg4:SetActive(self.m_lineupType == Lineup_Type.MAIN and true or false)
    self.m_benchIconBg5:SetActive(self.m_lineupType == Lineup_Type.MAIN and true or false)
end


function UICampsRushLineupView:GetIconParent()
    return self.m_benchRoleParent
end

function UICampsRushLineupView:GetRecoverParam()
    return self.m_battleType, self.m_copyID
end

function UICampsRushLineupView:OnClick(go, x, y)
    local name = go.name
    if name == "lineupBtn" then
        self.m_lineupType = Lineup_Type.MAIN
        self:RecyleModelAndIcon()
        self:UpdateLineup()
    elseif name == "benchBtn" then
        self.m_lineupType = Lineup_Type.BENCH
        self:RecyleModelAndIcon()
        self:UpdateLineup()
    else
        base.OnClick(self, go, x, y)
    end
end

function UICampsRushLineupView:CheckLineupBeforeFight()
    local lineupRoleCount = self:GetLineupRoleCount()
    if lineupRoleCount == 0 then
        UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(1107),Language.GetString(1108), 
                                           Language.GetString(1109))
        return
    end

    local allRoleCount = Player:GetInstance():GetWujiangMgr():GetWujiangCount()
    if lineupRoleCount < (CommonDefine.LINEUP_WUJIANG_COUNT + CommonDefine.LINEUP_BENCH_COUNT) and lineupRoleCount < allRoleCount then
        UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(1107),Language.GetString(1106), 
        Language.GetString(10), Bind(self, self.StartFight), Language.GetString(5))
        return
    end
    
    self:StartFight()
end

function UICampsRushLineupView:WalkLineup(filter)
    if self.m_lineupType == Lineup_Type.MAIN then
        self.m_lineupMgr:WalkMain(Utils.GetBuZhenIDByBattleType(self.m_battleType), filter)
    else
        self.m_lineupMgr:WalkBench(Utils.GetBuZhenIDByBattleType(self.m_battleType), filter)
    end
end

function UICampsRushLineupView:ModifyLineupSeq(standPos, newSeq)
    self.m_lineupMgr:ModifyLineupSeq(Utils.GetBuZhenIDByBattleType(self.m_battleType), self.m_lineupType == Lineup_Type.BENCH, standPos, newSeq)
end

function UICampsRushLineupView:SwapLineupSeq(standPos1, standPos2)
    self.m_lineupMgr:SwapLineupSeq(Utils.GetBuZhenIDByBattleType(self.m_battleType), self.m_lineupType == Lineup_Type.BENCH, standPos1, standPos2)
end

return UICampsRushLineupView