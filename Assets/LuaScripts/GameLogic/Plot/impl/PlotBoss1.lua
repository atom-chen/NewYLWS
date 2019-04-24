local PlotBase = require "GameLogic.Plot.PlotBase"
local PlotCommonStep = require "GameLogic.Plot.PlotCommonStep"

local PlotBoss1 = BaseClass("PlotBoss1", PlotBase)

function PlotBoss1:__init()
    self.steps = {
        self:S_Begin(),
        self:S_Init(),
        self:S_EnterScene(),
        -- self:S_WaitAMoment(),
        self:S_Wave3Start(),
        self:S_Wave3End(),
        self:S_WinAction(),
        self:S_Result_With_Camera(),
    }
end

-- function PlotBoss1:S_WaitAMoment()
--     return SequenceStep.New('S_WaitAMoment', function()
--             return SequenceCommonCmd.Async.Delay(3, true)
--         end)
-- end

return PlotBoss1