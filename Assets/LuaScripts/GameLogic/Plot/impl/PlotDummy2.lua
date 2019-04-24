
local PlotBase = require "GameLogic.Plot.PlotBase"
local PlotCommonStep = require "GameLogic.Plot.PlotCommonStep"

local PlotDummy2 = BaseClass("PlotDummy2", PlotBase)

function PlotDummy2:__init()
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
        self:S_WinAction(),
        self:S_Result_With_Camera(),
    }
end

return PlotDummy2