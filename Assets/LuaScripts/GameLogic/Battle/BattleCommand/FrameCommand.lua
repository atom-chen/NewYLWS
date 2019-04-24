local FrameCommand = BaseClass("FrameCommand")

function FrameCommand:__init()
    self.m_frameNum = 0
    self.m_cmdType = 0
end

function FrameCommand:DoExecute()
end

function FrameCommand:Execute()   
    self:DoExecute()
end

function FrameCommand:Send()
    -- TODO now only one player 
    CtlBattleInst:AddFrameCommand(self)
end

-- return : pb_obj
function FrameCommand:ToProtobuf()
end

function FrameCommand:FromProtobuf(pb_obj)
end

function FrameCommand:GetFrameNum()
    return self.m_frameNum
end

function FrameCommand:SetFrameNum(num)
    self.m_frameNum = num
end

function FrameCommand:GetCmdType() 
    return self.m_cmdType
end

return FrameCommand