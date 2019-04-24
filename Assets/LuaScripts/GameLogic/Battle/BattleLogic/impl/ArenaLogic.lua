local FilmLogic = require "GameLogic.Battle.BattleLogic.impl.FilmLogic"
local NewFixVector3 = FixMath.NewFixVector3
local ArenaLogic = BaseClass("ArenaLogic", FilmLogic)

local base = FilmLogic
local BattleEnum = BattleEnum

function ArenaLogic:__init()
    self.m_battleType = BattleEnum.BattleType_ARENA
end

function ArenaLogic:IsShowLeftCampKilled()
    return true
end

function ArenaLogic:CreatePlot()
    self.m_plotContext = SequenceMgr:GetInstance():PlayPlot('PlotArena')
end

function ArenaLogic:DoFinish()
    base.DoFinish(self)
    
    if self.m_resultParam.playerWin then
        SequenceMgr:GetInstance():TriggerEvent(SequenceEventType.BATTLE_END)
        -- self:OnWinSettle(true)
    else
        self:OnLoseSettle(self.m_resultParam.loseReason)
    end
end

function ArenaLogic:ReqSettle(isWin, isSkip)
    if self.m_component then
        Player:GetInstance():GetArenaMgr():TriggerGuideArena2()
        self.m_component:ReqBattleFinish(isWin, isSkip)
    end
end

function ArenaLogic:GetFollowDirectMS()
    -- if self.m_sinceStartMS <= 3000 then
    --     return 500     --ms
    -- else
    --     return base.GetFollowDirectMS(self)
    -- end
    return 3500
end

function ArenaLogic:GetFollowDirectDis()
    return 20
end

function ArenaLogic:GetLeftPos(wave)
    if not self.m_leftPosList then
        self.m_leftPosList = {
            NewFixVector3(20.29, 0, 10.65),
            NewFixVector3(18.04, 0, 7.65),
            NewFixVector3(18.04, 0, 13.65),
            NewFixVector3(15.04, 0, 9.15),
            NewFixVector3(15.04, 0, 12.15),
        }
    end
    return self.m_leftPosList
end

function ArenaLogic:GetRightPos(wave)
    if not self.m_rightPosList then
        self.m_rightPosList = {
            NewFixVector3(81.79, 0, 10.65),
            NewFixVector3(84.04, 0, 7.65),
            NewFixVector3(84.04, 0, 13.65),
            NewFixVector3(87.04, 0, 9.15),
            NewFixVector3(87.04, 0, 12.15),
        }
    end
    return self.m_rightPosList
end

function ArenaLogic:IsPathHandlerHitTest()
    return self.m_inFightMS >= 8000
end

function ArenaLogic:GetWaveGoTimelineName()
    if self.m_cameraAngleMode == 1 then
        return "Arena20"
    elseif self.m_cameraAngleMode == 2 then
        return "Arena30"
    elseif self.m_cameraAngleMode == 3 then
        return "Arena40"
    end
end

function ArenaLogic:InnerGetPreloadList()
    local helper = CtlBattleInst:GetLogicHelper(self.m_battleType)
    return helper:GetPreloadList(true)
end

function ArenaLogic:IsPlayDragonSkillShow()
    return false
end

function ArenaLogic:OnDragonSkillPerform(camp)
    if self.m_component then
        self.m_component:OnDragonSkillPerform(camp)
    end
end

function ArenaLogic:GetDollyGroupTimelineName()
    if self.m_cameraAngleMode == 1 then
        return "ArenaDollyGroup20"
    elseif self.m_cameraAngleMode == 2 then
        return "ArenaDollyGroup30"
    elseif self.m_cameraAngleMode == 3 then
        return "ArenaDollyGroup40"
    end
end

return ArenaLogic
