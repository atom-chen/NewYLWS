local PlotCommonStep = require "GameLogic.Plot.PlotCommonStep"

local PlotBase = BaseClass("PlotBase", SequenceBase)

function PlotBase:__init()

end

function PlotBase:S_Begin()
    return SequenceStep.New('S_Begin', PlotCommonStep.S_Begin)
end

function PlotBase:S_Init()
    return SequenceStep.New('S_Init', PlotCommonStep.S_Init)
end
    
function PlotBase:S_EnterScene()
    return SequenceStep.New('S_EnterScene', PlotCommonStep.S_EnterScene)
end
    
function PlotBase:S_StartCamera()
    return SequenceStep.New('S_StartCamera', PlotCommonStep.S_StartCamera)
end
    
function PlotBase:S_Wave1Start()
    return SequenceStep.New('S_Wave1Start', PlotCommonStep.S_Wave1Start)
end
    
function PlotBase:S_Wave1End()
    return SequenceStep.New('S_Wave1End', PlotCommonStep.S_Wave1End)
end
    
function PlotBase:S_GoCamera1()
    return SequenceStep.New('S_GoCamera1', PlotCommonStep.S_GoCamera1)
end
    
function PlotBase:S_Wave2Start()
    return SequenceStep.New('S_Wave2Start', PlotCommonStep.S_Wave2Start)
end
    
function PlotBase:S_Wave2End()
    return SequenceStep.New('S_Wave2End', PlotCommonStep.S_Wave2End)
end

function PlotBase:S_GoCamera2()
    return SequenceStep.New('S_GoCamera2', PlotCommonStep.S_GoCamera2)
end
    
function PlotBase:S_Wave3Start()
    return SequenceStep.New('S_Wave3Start', PlotCommonStep.S_Wave3Start)
end
    
function PlotBase:S_Wave3End()
    return SequenceStep.New('S_Wave3End', PlotCommonStep.S_Wave3End)
end
    
function PlotBase:S_WinAction()
    return SequenceStep.New('S_WinAction', PlotCommonStep.S_WinAction)
end

function PlotBase:RegisterSkip(steps)
    return SequenceStep.New('RegisterSkip', function(context)
            context:CacheData("timeSpeedInit", true)
    -- context:CacheData("timeElapseSpeed", CtlBattle.instance.GetTimeScaleMultiple()); todo
    -- CtlBattle.instance.SetTimeScaleMultiple(1.0f);
            context:SetSkipSteps(steps)
            return nil
        end)
end

function PlotBase:ClearSkip()
    return SequenceStep.New('ClearSkip', PlotCommonStep.ClearSkip)
end

function PlotBase:S_Result_With_Camera()
    return SequenceStep.New('S_Result_With_Camera', PlotCommonStep.S_Result_With_Camera)
end

function PlotBase:S_Result_Without_Camera()
    return SequenceStep.New('S_Result_Without_Camera', PlotCommonStep.S_Result_Without_Camera)
end

return PlotBase