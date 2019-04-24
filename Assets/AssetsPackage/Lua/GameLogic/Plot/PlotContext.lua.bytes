
local SequenceContext = require "GameLogic.Sequence.SequenceContext"

local PlotContext = BaseClass("PlotContext", SequenceContext)

function PlotContext:__init()
    self.m_whatContext = WhatContext.PLOT
end

function PlotContext:CreateSequence(sequenceName)
    local cc = require("GameLogic.Plot.impl."..sequenceName)
    return cc.New()
end

return PlotContext