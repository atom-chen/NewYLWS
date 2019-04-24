
local PlotBase = require "GameLogic.Plot.PlotBase"
local PlotCommonStep = require "GameLogic.Plot.PlotCommonStep"

local PlotDummy1 = BaseClass("PlotDummy1", PlotBase)

function PlotDummy1:__init()
    self.steps = {
        self:S_Begin(),
        self:S_Init(),
        self:S_EnterScene(),
        self:S_StartCamera(),
        self:S_ShowBattleUI(),
        self:S_Wave2Start(),
        self:S_Wave2End(),
        self:S_WinAction(),
        self:S_Result_With_Camera(),
    }
end

return PlotDummy1