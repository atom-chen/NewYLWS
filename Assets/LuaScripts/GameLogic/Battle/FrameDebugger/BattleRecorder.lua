local AppendToLogger = CUtil.AppendToLogger
local FlushLogger = CUtil.FlushLogger
local FrameRecordData = BaseClass("FrameRecordData")
function FrameRecordData:__init(frameID, eventType)
    self.frame_id = frameID
    self.event_type = eventType
    self.summonData = nil
    self.skillData = nil
    self.positionData = nil
    self.rotationData = nil
    self.wujiangAttrData = nil
    self.hpData = nil
    self.judgeData = nil
    self.nuqiData = nil
    self.bornData = nil
    self.statusData = nil
end
function FrameRecordData:__delete()
    self.summonData = nil
    self.skillData = nil
    self.positionData = nil
    self.rotationData = nil
    self.wujiangAttrData = nil
    self.hpData = nil
    self.judgeData = nil
    self.nuqiData = nil
    self.bornData = nil
    self.statusData = nil
end

function FrameRecordData:LoggerAppend()
    AppendToLogger(self.frame_id, ",", self.event_type, ",")
    if self.summonData then self.summonData:LoggerAppend() end
    if self.skillData then self.skillData:LoggerAppend() end
    if self.positionData then self.positionData:LoggerAppend() end
    if self.rotationData then self.rotationData:LoggerAppend() end
    if self.wujiangAttrData then self.wujiangAttrData:LoggerAppend() end
    if self.hpData then self.hpData:LoggerAppend() end
    if self.judgeData then self.judgeData:LoggerAppend() end
    if self.nuqiData then self.nuqiData:LoggerAppend() end
    if self.bornData then self.bornData:LoggerAppend() end
    if self.statusData then self.statusData:LoggerAppend() end
    return ''
end

local SummonRecordData = BaseClass("SummonRecordData")
function SummonRecordData:__init()
    self.camp = 0
    self.reason = 0
    self.summonID = 0
    self.summonLevel = 0
end

function SummonRecordData:LoggerAppend()
    AppendToLogger(self.camp, ",", self.reason, ",", self.summonID, ",", self.summonLevel, "|")
end
function SummonRecordData:ToString()
    return "RecordSummon,camp:" .. self.camp .. ",reason:" .. self.reason .. ", ID:" .. self.summonID .. ", summonLevel:" .. self.summonLevel
end

local SkillRecordData = BaseClass("SkillRecordData")
function SkillRecordData:__init()
    self.camp = 0
    self.skillID = 0
    self.actorID = 0
    self.targetID = 0
    self.keyframe = 0
end
function SkillRecordData:LoggerAppend()
    AppendToLogger(self.camp, ", ", self.skillID, ",", self.actorID, ",", self.targetID, ",", self.keyframe, "|")
end
function SkillRecordData:ToString()
    return "SkillRecordData,skillID:" .. self.skillID .. ",camp:" .. self.camp .. ", actorID:" .. 
    self.actorID .. ", targetID:" .. self.targetID .. ", keyframe:" .. self.keyframe
end


local PositionRecordData = BaseClass("PositionRecordData")
function PositionRecordData:__init()
    self.reason = 0
    self.pos_x = 0
    self.pos_y = 0
    self.pos_z = 0
    self.actorID = 0
    self.exParam = 0
end
function PositionRecordData:LoggerAppend()
    AppendToLogger(self.reason, ",", self.pos_x, ",", self.pos_y, ",", self.pos_z, ",", self.actorID, ",", self.exParam, "|")
end
function PositionRecordData:ToString()
    return "PositionRecordData,reason:" .. self.reason .. ",pos_x:" .. self.pos_x .. ", pos_y:" .. self.pos_y .. 
    ", pos_z:" .. self.pos_z .. ", actorID:" .. self.actorID .. ", exParam:" .. self.exParam
end

local RotationRecordData = BaseClass("RotationRecordData")
function RotationRecordData:__init()
    self.actorID = 0
    self.rot_x = 0
    self.rot_y = 0
    self.rot_z = 0
end
function RotationRecordData:LoggerAppend()
    AppendToLogger(self.actorID, ",", self.rot_x, ",", self.rot_y, ",", self.rot_z, "|")
end
function RotationRecordData:ToString()
    return "RotationRecordData,rot_x:" .. self.rot_x .. ",rot_y:" .. self.rot_y .. ", rot_z:" .. self.rot_z .. ", actorID:" .. self.actorID
end

local WujiangAttrRecordData = BaseClass("WujiangAttrRecordData")
function WujiangAttrRecordData:__init()
    self.actorID = 0
    self.attrType = 0
    self.oldVal = 0
    self.newVal = 0
end
function WujiangAttrRecordData:LoggerAppend()
    AppendToLogger(self.actorID, ",", self.attrType, ",", self.oldVal, ",", self.newVal, "|")
end
function WujiangAttrRecordData:ToString()
    return "WujiangAttrRecordData,actorID:" .. self.actorID .. ",attrType:" .. self.attrType .. ", oldVal:" .. self.oldVal.. ", newVal:" .. self.newVal
end

local HPRecordData = BaseClass("HPRecordData")
function HPRecordData:__init()
    self.actorID = 0
    self.hurtType = 0
    self.reason = 0
    self.deltaVal = 0
    self.oldHP = 0
    self.newHP = 0
    self.attackID = 0
    self.skillID = 0
    self.judge = 0
end
function HPRecordData:LoggerAppend()
    AppendToLogger(self.actorID, ",", self.hurtType, ",", self.reason, ",", self.deltaVal, ",", self.oldHP, ",", self.newHP, ",", self.attackID, ",", self.skillID, ",", self.judge, "|")
end
function HPRecordData:ToString()
    return "HPRecordData,actorID:" .. self.actorID .. ",hurtType:" .. self.hurtType .. ", reason:" .. self.reason .. ", judge:" .. self.judge .. 
    ", deltaVal:" .. self.deltaVal .. ", oldHP:" .. self.oldHP.. ", newHP:" .. self.newHP.. ", attackID:" .. self.attackID.. ", skillID:" .. self.skillID
end

local JudgeRecordData = BaseClass("JudgeRecordData")
function JudgeRecordData:__init()
    self.actorID = 0
    self.targetID = 0
    self.judge = 0
end
function JudgeRecordData:LoggerAppend()
    AppendToLogger(self.actorID, ",", self.targetID, ",", self.judge, "|")
end
function JudgeRecordData:ToString()
    return "JudgeRecordData,actorID:" .. self.actorID .. ",judge:" .. self.judge .. ", targetID:" .. self.targetID
end

local NuqiRecordData = BaseClass("NuqiRecordData")
function NuqiRecordData:__init()
    self.actorID = 0
    self.reason = 0
    self.deltaVal = 0
    self.skillID = 0
    self.oldHP = 0
    self.newHP = 0
end
function NuqiRecordData:LoggerAppend()
    AppendToLogger(self.actorID, ",", self.reason, ",", self.deltaVal, ",", self.skillID, ",", self.oldHP, ",", self.newHP, "|")
end
function NuqiRecordData:ToString()
    return "NuqiRecordData,actorID:" .. self.actorID .. ",deltaVal:" .. self.deltaVal .. ", reason:" .. self.reason .. 
    ", skillID:" .. self.skillID .. ", oldHP:" .. self.oldHP .. ", newHP:" .. self.newHP
end

local BornRecordData = BaseClass("BornRecordData")
function BornRecordData:__init()
    self.actorID = 0
    self.pos_x = 0
    self.pos_y = 0
    self.pos_z = 0
    self.forward_x = 0
    self.forward_y = 0
    self.forward_z = 0
    self.hp = 0
end
function BornRecordData:LoggerAppend()
    AppendToLogger(self.actorID, ",", self.pos_x, ",", self.pos_y, ",", self.pos_z, ",", self.forward_x, ",", self.forward_y, ",", self.forward_z, ",", self.hp, "|")
end
function BornRecordData:ToString()
    return "BornRecordData,actorID:" .. self.actorID .. ",pos_x:" .. self.pos_x .. ", pos_y:" .. self.pos_y .. 
    ", pos_z:" .. self.pos_z .. ", forward_x:" .. self.forward_x .. ", forward_y:" .. self.forward_y .. ", forward_z:" .. self.forward_z
end

local StatusData = BaseClass("StatusData")
function StatusData:__init()
    self.actorID = 0
    self.statusType = 0
    self.giverSkillID = 0
    self.giverActorID = 0
end
function StatusData:LoggerAppend()
    AppendToLogger(self.actorID, ",", self.statusType, ",", self.giverSkillID, ",", self.giverActorID, "|")
end
function StatusData:ToString()
    return "StatusData,giverSkillID:" .. self.giverSkillID .. ",giverActorID:" .. self.giverActorID .. ", statusType:" .. self.statusType .. ", actorID:" .. self.actorID
end

local BattleRecordEnum = BattleRecordEnum
local table_insert = table.insert
local BattleRecorder = BaseClass("BattleRecorder", Singleton)

function BattleRecorder:__init()
    self.m_frameDataArray = {}
end

function BattleRecorder:Clear()
    for _,data in pairs(self.m_frameDataArray) do
        if data then
            data:Delete()
        end
    end
    self.m_frameDataArray = {}
end

function BattleRecorder:AddEvent(eventType, ...)
    if eventType == BattleRecordEnum.EVENT_TYPE_SUMMON then
        return self:AddSummonEvent(...)
    elseif eventType == BattleRecordEnum.EVENT_TYPE_SKILL then
        return self:AddSkillEvent(...)
    elseif eventType == BattleRecordEnum.EVENT_TYPE_POSITION then
        return self:AddPostionEvent(...)
    elseif eventType == BattleRecordEnum.EVENT_TYPE_HP then
        return self:AddHPEvent(...)
    elseif eventType == BattleRecordEnum.EVENT_TYPE_ROUNDJUDGE then
        return self:AddJudgeEvent(...)
    elseif eventType == BattleRecordEnum.EVENT_TYPE_NUQI then
        return self:AddNuqiEvent(...)
    elseif eventType == BattleRecordEnum.EVENT_TYPE_ROTATION then
        return self:AddRotationEvent(...)
    elseif eventType == BattleRecordEnum.EVENT_TYPE_BORN then
        return self:AddBornEvent(...)
    elseif eventType == BattleRecordEnum.EVENT_TYPE_WUJIANG_ATTR then
        return self:AddWujiangAttrEvent(...)
    elseif eventType == BattleRecordEnum.EVENT_TYPE_ADD_STATUS then
        return self:AddStatusEvent(...)
    end
end

function BattleRecorder:GetFrameDataArray()
    -- print("frameDataArray length:" .. #self.m_frameDataArray)
    return self.m_frameDataArray
end

function BattleRecorder:GetAllFrameDataString()
    for _, data in ipairs(self.m_frameDataArray) do
        data:LoggerAppend()
    end
    return FlushLogger()
end

function BattleRecorder:GetCurFrameData(eventType)
    local curFrame = CtlBattleInst:GetCurFrame()
    local curFrameData = FrameRecordData.New(curFrame, eventType)
    table_insert(self.m_frameDataArray, curFrameData)
    return curFrameData
end

function BattleRecorder:AddSummonEvent(camp, summonID, level, reason)
    local summonData = SummonRecordData.New()
    summonData.camp = camp
    summonData.summonID = summonID
    summonData.summonLevel = level
    summonData.reason = reason
 
    local frameData = self:GetCurFrameData(BattleRecordEnum.EVENT_TYPE_SUMMON)
    frameData.summonData = summonData
    frameData.event_name = "Summon"
    return summonData
end

function BattleRecorder:AddSkillEvent(camp, skillID, actorID, targetID, keyframe)
    local skillData = SkillRecordData.New()
    skillData.camp = camp
    skillData.skillID = skillID
    skillData.actorID = actorID
    skillData.targetID = targetID
    skillData.keyframe = keyframe
 
    local frameData = self:GetCurFrameData(BattleRecordEnum.EVENT_TYPE_SKILL)
    frameData.skillData = skillData
    frameData.event_name = "Skill"
    return skillData
end

function BattleRecorder:AddPostionEvent(actorID, reason, pos, exParam)
    local x,y,z = pos:GetXYZ()
    local posData = PositionRecordData.New()
    posData.actorID = actorID
    posData.reason = reason
    posData.pos_x = x
    posData.pos_y = y
    posData.pos_z = z
    posData.exParam = exParam
 
    local frameData = self:GetCurFrameData(BattleRecordEnum.EVENT_TYPE_POSITION)
    frameData.positionData = posData
    frameData.event_name = "Pos"
    return posData
end

function BattleRecorder:AddRotationEvent(actorID, rot)
    local x,y,z = rot:GetXYZ()
    local rotationData = RotationRecordData.New()
    rotationData.actorID = actorID
    rotationData.rot_x = x
    rotationData.rot_y = y
    rotationData.rot_z = z

    local frameData = self:GetCurFrameData(BattleRecordEnum.EVENT_TYPE_ROTATION)
    frameData.rotationData = rotationData
    frameData.event_name = "Rot"
    return rotationData
end

function BattleRecorder:AddWujiangAttrEvent(actorID, attrType, oldVal, newVal)
    local attrData = WujiangAttrRecordData.New()
    attrData.actorID = actorID
    attrData.attrType = attrType
    attrData.oldVal = oldVal
    attrData.newVal = newVal

    local frameData = self:GetCurFrameData(BattleRecordEnum.EVENT_TYPE_WUJIANG_ATTR)
    frameData.wujiangAttrData = attrData
    frameData.event_name = "Attr"
    return attrData
end

function BattleRecorder:AddHPEvent(actorID, hurtType, reason, judge, deltaVal, oldHP, newHP, giver)
    local hpData = HPRecordData.New()
    hpData.actorID = actorID
    hpData.hurtType = hurtType or 0
    hpData.reason = reason
    hpData.judge = judge or 0
    hpData.deltaVal = deltaVal
    hpData.oldHP = oldHP
    hpData.newHP = newHP
    hpData.attackID = giver.actorID
    hpData.skillID = giver.skillID

    local frameData = self:GetCurFrameData(BattleRecordEnum.EVENT_TYPE_HP)
    frameData.hpData = hpData
    frameData.event_name = "HP"
    return hpData
end

function BattleRecorder:AddJudgeEvent(actorID, targetID, judge)
    local judgeData = JudgeRecordData.New()
    judgeData.actorID = actorID
    judgeData.targetID = targetID
    judgeData.judge = judge

    local frameData = self:GetCurFrameData(BattleRecordEnum.EVENT_TYPE_ROUNDJUDGE)
    frameData.judgeData = judgeData
    frameData.event_name = "Judge"
    return judgeData
end

function BattleRecorder:AddNuqiEvent(actorID, deltaVal, reason, skillID, oldHP, newHP)
    local nuqiData = NuqiRecordData.New()
    nuqiData.actorID = actorID
    nuqiData.deltaVal = deltaVal
    nuqiData.reason = reason
    nuqiData.skillID = skillID
    nuqiData.oldHP = oldHP
    nuqiData.newHP = newHP

    local frameData = self:GetCurFrameData(BattleRecordEnum.EVENT_TYPE_NUQI)
    frameData.nuqiData = nuqiData
    frameData.event_name = "Nuqi"
    return nuqiData
end

function BattleRecorder:AddBornEvent(actorID, pos, forward, hp)
    local x,y,z = pos:GetXYZ()
    local fx,fy,fz = forward:GetXYZ()
    local bornData = BornRecordData.New()
    bornData.actorID = actorID
    bornData.pos_x = x
    bornData.pos_y = y
    bornData.pos_z = z
    bornData.forward_x = fx
    bornData.forward_y = fy
    bornData.forward_z = fz
    bornData.hp = hp

    local frameData = self:GetCurFrameData(BattleRecordEnum.EVENT_TYPE_BORN)
    frameData.bornData = bornData
    frameData.event_name = "Born"
    return bornData
end

function BattleRecorder:AddStatusEvent(giver, statusType, actorID)
    local statusData = StatusData.New()
    statusData.actorID = actorID
    statusData.statusType = statusType
    statusData.giverSkillID = giver.skillID
    statusData.giverActorID = giver.actorID

    local frameData = self:GetCurFrameData(BattleRecordEnum.EVENT_TYPE_ADD_STATUS)
    frameData.statusData = statusData
    frameData.event_name = "Status"
    return statusData
end

return BattleRecorder