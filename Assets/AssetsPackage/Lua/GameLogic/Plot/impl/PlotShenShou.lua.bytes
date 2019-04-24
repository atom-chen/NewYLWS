
local PlotBase = require "GameLogic.Plot.PlotBase"
local PlotCommonStep = require "GameLogic.Plot.PlotCommonStep"

local PlotShenShou = BaseClass("PlotShenShou", PlotBase)

function PlotShenShou:__init()
    self.steps = {
        self:S_Begin(),
        self:S_Init(),
        self:S_EnterScene(),
        self:S_StartCamera(),
        self:S_Wave3Start(),
        self:S_Wave3End(),
        self:S_WinAction(),
        self:S_Result_With_Camera(),
    }
end

return PlotShenShou