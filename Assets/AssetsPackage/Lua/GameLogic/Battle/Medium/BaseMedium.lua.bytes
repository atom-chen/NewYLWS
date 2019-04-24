local FixDiv = FixMath.div
local FixSub = FixMath.sub
local FixNormalize = FixMath.Vector3Normalize
local FixMul = FixMath.mul
local Angle = FixMath.Vector3Angle  --角度
local FixNewVector3 = FixMath.NewFixVector3
local table_insert = table.insert
local table_remove = table.remove
local MediumEnum = MediumEnum
local StatusGiver = StatusGiver
local FixVecConst = FixVecConst
local ActorManagerInst = ActorManagerInst
local ComponentMgr = ComponentMgr
local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID
local MediumManagerInst = MediumManagerInst


local BaseMedium = BaseClass("BaseMedium")

function BaseMedium:__init()
    self.m_position = nil  -- Vector3
    self.m_forward = nil   -- Vector3

    self.m_isValid = true
    self.m_giver = nil  -- StatusGiver
    self.m_skillBase = nil
    self.m_ID = 0
    self.m_type = MediumEnum.MEDIUMTYPE_None
    self.m_mediumID = 0
    self.m_isPause = false
    self.m_component = nil
end

function BaseMedium:ID()
    return self.m_ID
end

function BaseMedium:OnCreate(id, mediumID, giver, skillBase, pos, forward, param)
    self.m_ID = id
    self.m_mediumID = mediumID
    self.m_giver = giver
    self.m_skillBase = skillBase
    self.m_position = pos:Clone()
    self.m_forward = forward:Clone()
    self:InitParam(param)

    ComponentMgr:CreateMediumComponent(self)
end

function BaseMedium:GetMediumID()
    return self.m_mediumID
end

function BaseMedium:GetID()
    return self.m_ID
end

function BaseMedium:__delete()
    if self.m_component then
        self.m_component:Delete()
        self.m_component = nil
    end

    self.m_position = nil
    self.m_forward = nil
    self.m_isValid = nil
    self.m_giver = nil 
    self.m_skillBase = nil
end

function BaseMedium:InitParam(param)
end

function BaseMedium:RegisterComponent(com)
    self.m_component = com
    self:OnComponentBorn()
end

function BaseMedium:OnComponentBorn()

end

function BaseMedium:IsValid()
    return self.m_isValid
end

function BaseMedium:Invalid()
    self.m_isValid = false
end

function BaseMedium:GetForward()
    return self.m_forward
end

function BaseMedium:GetPostion()
    return self.m_position
end

function BaseMedium:SetForward(forward)
    if forward then
        self:SetForward_OnlyLogic(forward)

        if self.m_component then
            self.m_component:SetForward(forward)
        end
    end
end

function BaseMedium:SetForward_OnlyLogic(forward)
    forward = FixNormalize(forward)
    self.m_forward:SetXYZ(forward:GetXYZ())
end

function BaseMedium:SetNormalizedForward_OnlyLogic(forward)
    self.m_forward:SetXYZ(forward:GetXYZ())
end

--@delta dest : FixVector3
function BaseMedium:MovePosition(delta)
    self:MovePosition_OnlyLogic(delta)

    if self.m_component then
        self.m_component:SetPosition(self.m_position)
    end

    return self.m_position
end

function BaseMedium:MovePosition_OnlyLogic(delta)
    self.m_position:Add(delta)
    
    return self.m_position
end

function BaseMedium:Over()
    MediumManagerInst:RemoveMedium(self.m_ID)
end

function BaseMedium:Update(deltaMS)

   if self.m_isPause then
        return
   end

   self:DoUpdate(deltaMS)
end

function BaseMedium:DoUpdate(deltaMS)

end

--- return : Actor
function BaseMedium:GetOwner()
    return ActorManagerInst:GetActor(self.m_giver.actorID)
end

function BaseMedium:GetSkillCfg()
    return GetSkillCfgByID(self.m_giver.skillID)
end

function BaseMedium:GetPosition()
    return self.m_position
end

function BaseMedium:Pause(reason)
    self.m_isPause = true

    if self.m_component then
        self.m_component:Pause(reason)
    end
end

function BaseMedium:Resume(reason)
    self.m_isPause = false

    if self.m_component then
        self.m_component:Resume(reason)
    end
end

function BaseMedium:SetLayerState(layerState)
    if self.m_component then
        self.m_component:SetLayerState(layerState)
    end
end


 function BaseMedium:LookatPosOnlyShow(x, y, z)  
    if self.m_component then
        self.m_component:LookAtPos(x, y, z)
    end
end 


 function BaseMedium:LookatTransformOnlyShow(tr)  
    if self.m_component then
        self.m_component:LookAtTransform(tr)
    end
end 

function BaseMedium:MoveOnlyShow(dis)
    if self.m_component then
        self.m_component:MoveOnlyShow(dis)
    end
end

function BaseMedium:AddStatus(performer, target, status, prob)
    if not target or not status then 
        return false 
    end

    if not self.m_skillBase or not self:GetSkillCfg() then 
        return false 
    end

    return target:GetStatusContainer():Add(status, performer, prob)
end

function BaseMedium:Rotate(point, axis, angle)
    if self.m_component then
        self.m_component:Rotate(point, axis, angle)
    end
end

return BaseMedium