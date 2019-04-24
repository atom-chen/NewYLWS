local StatusWudi = require("GameLogic.Battle.Status.impl.StatusWudi")
local StatusEnum = StatusEnum
local FixSub = FixMath.sub

local StatusZhaoYunWudi = BaseClass("StatusZhaoYunWudi", StatusWudi)

function StatusZhaoYunWudi:GetStatusType()
    return StatusEnum.STATUSTYPE_ZHAOYUNWUDI
end

function StatusZhaoYunWudi:Effect(actor)
    if actor then
        local actorColor = actor:GetActorColor()
        if actorColor then
            actorColor:ClearColor()
        end

        local actorCom = actor:GetComponent()
        if actorCom then
            actorCom:ChangeMeshRenderer()
        end
    end
    return StatusWudi.Effect(self, actor)
end

function StatusZhaoYunWudi:ClearEffect(actor)
    StatusWudi.ClearEffect(self, actor)
    
    if actor then
        local actorCom = actor:GetComponent()
        if actorCom then
            actorCom:ClearMeshRenderer()
        end
    end
end


return StatusZhaoYunWudi