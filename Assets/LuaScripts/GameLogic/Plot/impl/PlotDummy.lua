
local PlotBase = require "GameLogic.Plot.PlotBase"
local PlotCommonStep = require "GameLogic.Plot.PlotCommonStep"

local PlotDummy = BaseClass("PlotDummy", PlotBase)

function PlotDummy:__init()
    self.steps = {
        self:S_Begin(),
        self:S_Init(),
        self:S_EnterScene(),
        self:S_StartCamera(),
        self:S_Wave1Start(),
        self:S_Wave1End(),
        self:S_GoCamera1(),
        self:S_Wave2Start(),
        self:S_Wave2End(),
        self:S_GoCamera2(),
        self:S_Wave3Start(),
        self:S_Wave3End(),
        self:S_WinAction(),
        self:S_Result_With_Camera(),
    }
end

return PlotDummy