local FixNewVector3 = FixMath.NewFixVector3

local AISpecialState = BaseClass("AISpecialState")

SPECIAL_STATE = {
    NONE = 0,
    CONTINUE_GUIDE = 1,
    RAND_MOVE = 2,
    BACK_AND_SKILL = 3,
    BACK_AND_IDLE = 4,
    FOLLOW_TARGET = 5,
}

function AISpecialState:__init()
    self.stateType = SPECIAL_STATE.NONE
    self.leftMS = 0
    self.skillID = 0
    self.param1 = 0
    self.param2 = 0
    self.position = false
    self.forward = false
end

function AISpecialState:SetPos(pos)
    if not self.position then
        self.position = pos:Clone()
    else
        pos:CopyTo(self.position)
    end
end

function AISpecialState:SetForward(forward)
    if not self.forward then
        self.forward = forward:Clone()
    else
        forward:CopyTo(self.forward)
    end
end

function AISpecialState:Clear()
    self.stateType = 0
    self.leftMS = 0
    self.skillID = 0
    self.param1 = 0
    self.param2 = 0
    self.position = false
    self.forward = false
end

return AISpecialState