
local Vector3 = Vector3
local Quaternion = CS.UnityEngine.Quaternion
local GameUtility = CS.GameUtility
local GameObject = CS.UnityEngine.GameObject
local Type_Material = typeof(CS.UnityEngine.Material)
local Time = Time
local BattleEnum = BattleEnum
local SKILL_RANGE_TYPE = SKILL_RANGE_TYPE
local table_insert = table.insert
local BindCallback = BindCallback
local math_rad = math.rad
local math_sin = math.sin
local Shader = CS.UnityEngine.Shader

local SkillSelector = BaseClass("SkillSelector")

local PIX_TO_UNIT = 0.005
local OFFSET_Y = 0.05
local SELECTOR_TYPE = {
    LINE = 1,
    RECT = 2,
    CIRCLE = 3,
    SECTOR = 4,
    LOLLIPOP = 5,
    LOLLIPOP2 = 6,
    RECT_IN_CIRCLE = 7,
    ZHUGELIANG_FLAGS = 8,
    SECTOR_RING = 9, --扇形环形
    HALF_CIRCLE = 14, --半圆
}

local LAYER = Layers.Skill_Fx_2 

function SkillSelector:__init()
    self.m_skillRangeType = 0
    self.m_disSqr1 = 0
    self.m_disSqr2 = 4
    self.m_disSqr3 = 0
    self.m_disSqr4 = 0
    self.m_dis1 = 0
    self.m_dis2 = 4
    self.m_dis3 = 0
    self.m_dis4 = 0
    self.m_angle = 0
    self.m_startPos = Vector3.zero
    self.m_candidateTargets = {}
    self.m_skillReallyPos = Vector3.zero
    self.m_skillReallyDir = Vector3.zero
    self.m_skillReallySingleTarget = false
    self.m_selectorType = 0

    self.m_trans_line = false
    self.m_trans_line_part1 = false
    self.m_trans_line_part2 = false
    self.m_trans_line_part3 = false
    self.m_line_material = false

    self.m_trans_rect = false
    self.m_trans_rect_part1 = false
    self.m_trans_rect_part2 = false
    self.m_trans_rect_part3 = false
    self.m_rect_material = false

    self.m_trans_circle = false
    self.m_trans_circle_part1 = false
    self.m_circle_material = false

    self.m_trans_sector = false
    self.m_trans_sector_part1 = false
    self.m_sector_material = false

    self.m_trans_range = false
    self.m_trans_range_part1 = false
    self.m_range_material = false

    self.m_trans_ring_sector = false
    self.m_trans_ring_sector_part1 = false
    self.m_ring_sector_material = false
        
    self.m_trans_half_circle = false
    self.m_trans_half_circle_part1 = false
    self.m_half_circle_material = false

    self.m_selectorRootTrans = false

    self.m_ShadowPowerID = Shader.PropertyToID("_Power")
end

function SkillSelector:Reset()
    self.m_startPos = Vector3.zero
    self.m_candidateTargets = {}
    self.m_skillReallyPos = Vector3.zero
    self.m_skillReallyDir = Vector3.zero
    self.m_skillReallySingleTarget = false

    local ActiveTransform = GameUtility.ActiveTransform
    if self.m_selectorRootTrans then ActiveTransform(self.m_selectorRootTrans, false) end
    if self.m_trans_line then ActiveTransform(self.m_trans_line, false) end
    if self.m_trans_rect then ActiveTransform(self.m_trans_rect, false) end
    if self.m_trans_circle then ActiveTransform(self.m_trans_circle, false) end
    if self.m_trans_sector then ActiveTransform(self.m_trans_sector, false) end
    if self.m_trans_range then ActiveTransform(self.m_trans_range, false) end
    if self.m_trans_ring_sector then ActiveTransform(self.m_trans_ring_sector, false) end
    if self.m_trans_half_circle then ActiveTransform(self.m_trans_half_circle, false) end
end

function SkillSelector:__delete()
    self.m_selectorRootTrans = nil
    
    if self.m_trans_line then
        GameObject.DestroyImmediate(self.m_trans_line.gameObject)
        self.m_trans_line = nil
    end

    if self.m_trans_rect then
        GameObject.DestroyImmediate(self.m_trans_rect.gameObject)
        self.m_trans_rect = nil
    end

    if self.m_trans_circle then
        GameObject.DestroyImmediate(self.m_trans_circle.gameObject)
        self.m_trans_circle = nil
    end

    if self.m_trans_sector then
        GameObject.DestroyImmediate(self.m_trans_sector.gameObject)
        self.m_trans_sector = nil
    end

    if self.m_trans_range then
        GameObject.DestroyImmediate(self.m_trans_range.gameObject)
        self.m_trans_range = nil
    end

    if self.m_trans_ring_sector then
        GameObject.DestroyImmediate(self.m_trans_ring_sector.gameObject)
        self.m_trans_ring_sector = nil
    end

    if self.m_trans_half_circle then
        GameObject.DestroyImmediate(self.m_trans_half_circle.gameObject)
        self.m_trans_half_circle = nil
    end
end

function SkillSelector:SureRoot()
    if not self.m_selectorRootTrans then 
        self.m_selectorRootTrans = GameObject("SelectorRoot").transform
    end

    if self.m_selectorRootTrans then 
        GameUtility.ActiveTransform(self.m_selectorRootTrans, true)
    end
end

function SkillSelector:GetRoot()
    return self.m_selectorRootTrans
end

function SkillSelector:SetPower(power)
    if self.m_line_material then self.m_line_material:SetFloat(self.m_ShadowPowerID, power) end
    if self.m_rect_material then self.m_rect_material:SetFloat(self.m_ShadowPowerID, power) end
    if self.m_circle_material then self.m_circle_material:SetFloat(self.m_ShadowPowerID, power) end
    if self.m_sector_material then self.m_sector_material:SetFloat(self.m_ShadowPowerID, power) end
    if self.m_range_material then self.m_range_material:SetFloat(self.m_ShadowPowerID, power) end
    if self.m_ring_sector_material then self.m_ring_sector_material:SetFloat(self.m_ShadowPowerID, power) end
    if self.m_half_circle_material then self.m_half_circle_material:SetFloat(self.m_ShadowPowerID, power) end
end

-- cfg, Vector3, Actor[]
function SkillSelector:InitBySkillCfg(skillCfg, startPos, targets)
    self.m_startPos = startPos:Clone()
    for k,v in pairs(targets) do
        table_insert(self.m_candidateTargets, v)
    end
    self.m_skillRangeType = skillCfg.validrangetype
    self.m_disSqr1 = skillCfg.disSqr1
    self.m_disSqr2 = skillCfg.disSqr2
    self.m_disSqr3 = skillCfg.disSqr3
    self.m_disSqr4 = skillCfg.disSqr4
    self.m_dis1 = skillCfg.dis1
    self.m_dis2 = skillCfg.dis2
    self.m_dis3 = skillCfg.dis3
    self.m_dis4 = skillCfg.dis4
    self.m_angle = skillCfg.angle
    
    self:InitSelectorType()
end

function SkillSelector:InitSelectorType()
    local ActiveTransform = GameUtility.ActiveTransform

    self:SureRoot()

    if self.m_skillRangeType == SKILL_RANGE_TYPE.SECTOR then
        self.m_selectorType = SELECTOR_TYPE.SECTOR
        if self.m_trans_line then ActiveTransform(self.m_trans_line, false) end
        if self.m_trans_rect then ActiveTransform(self.m_trans_rect, false) end
        if self.m_trans_circle then ActiveTransform(self.m_trans_circle, false) end
        if self.m_trans_sector then ActiveTransform(self.m_trans_sector, true) end
        if self.m_trans_range then ActiveTransform(self.m_trans_range, false) end
        if self.m_trans_ring_sector then ActiveTransform(self.m_trans_ring_sector, false) end
        if self.m_trans_half_circle then ActiveTransform(self.m_trans_half_circle, false) end
    
    elseif self.m_skillRangeType == SKILL_RANGE_TYPE.RECT then
        self.m_selectorType = SELECTOR_TYPE.RECT
        if self.m_trans_line then ActiveTransform(self.m_trans_line, false) end
        if self.m_trans_rect then ActiveTransform(self.m_trans_rect, true) end
        if self.m_trans_circle then ActiveTransform(self.m_trans_circle, false) end
        if self.m_trans_sector then ActiveTransform(self.m_trans_sector, false) end
        if self.m_trans_range then ActiveTransform(self.m_trans_range, false) end
        if self.m_trans_ring_sector then ActiveTransform(self.m_trans_ring_sector, false) end
        if self.m_trans_half_circle then ActiveTransform(self.m_trans_half_circle, false) end
        
    elseif self.m_skillRangeType == SKILL_RANGE_TYPE.CIRCLE then
        self.m_selectorType = SELECTOR_TYPE.CIRCLE
        if self.m_trans_line then ActiveTransform(self.m_trans_line, false) end
        if self.m_trans_rect then ActiveTransform(self.m_trans_rect, false) end
        if self.m_trans_circle then ActiveTransform(self.m_trans_circle, true) end
        if self.m_trans_sector then ActiveTransform(self.m_trans_sector, false) end
        if self.m_trans_range then ActiveTransform(self.m_trans_range, true) end
        if self.m_trans_ring_sector then ActiveTransform(self.m_trans_ring_sector, false) end
        if self.m_trans_half_circle then ActiveTransform(self.m_trans_half_circle, false) end

    elseif self.m_skillRangeType == SKILL_RANGE_TYPE.SINGLE_TARGET then
        self.m_selectorType = SELECTOR_TYPE.CIRCLE
        if self.m_trans_line then ActiveTransform(self.m_trans_line, false) end
        if self.m_trans_rect then ActiveTransform(self.m_trans_rect, false) end
        if self.m_trans_circle then ActiveTransform(self.m_trans_circle, false) end
        if self.m_trans_sector then ActiveTransform(self.m_trans_sector, false) end
        if self.m_trans_range then ActiveTransform(self.m_trans_range, true) end
        if self.m_trans_ring_sector then ActiveTransform(self.m_trans_ring_sector, false) end
        if self.m_trans_half_circle then ActiveTransform(self.m_trans_half_circle, false) end

    elseif self.m_skillRangeType == SKILL_RANGE_TYPE.LINE then
        self.m_selectorType = SELECTOR_TYPE.LINE
        if self.m_trans_line then ActiveTransform(self.m_trans_line, true) end
        if self.m_trans_rect then ActiveTransform(self.m_trans_rect, false) end
        if self.m_trans_circle then ActiveTransform(self.m_trans_circle, false) end
        if self.m_trans_sector then ActiveTransform(self.m_trans_sector, false) end
        if self.m_trans_range then ActiveTransform(self.m_trans_range, false) end
        if self.m_trans_ring_sector then ActiveTransform(self.m_trans_ring_sector, false) end
        if self.m_trans_half_circle then ActiveTransform(self.m_trans_half_circle, false) end

    elseif self.m_skillRangeType == SKILL_RANGE_TYPE.LOLLIPOP then
        self.m_selectorType = SELECTOR_TYPE.LOLLIPOP
        if self.m_trans_line then ActiveTransform(self.m_trans_line, true) end
        if self.m_trans_rect then ActiveTransform(self.m_trans_rect, false) end
        if self.m_trans_circle then ActiveTransform(self.m_trans_circle, true) end
        if self.m_trans_sector then ActiveTransform(self.m_trans_sector, false) end
        if self.m_trans_range then ActiveTransform(self.m_trans_range, true) end
        if self.m_trans_ring_sector then ActiveTransform(self.m_trans_ring_sector, false) end
        if self.m_trans_half_circle then ActiveTransform(self.m_trans_half_circle, false) end

    elseif self.m_skillRangeType == SKILL_RANGE_TYPE.LOLLIPOP2 then
        self.m_selectorType = SELECTOR_TYPE.LOLLIPOP2
        if self.m_trans_line then ActiveTransform(self.m_trans_line, true) end
        if self.m_trans_rect then ActiveTransform(self.m_trans_rect, false) end
        if self.m_trans_circle then ActiveTransform(self.m_trans_circle, true) end
        if self.m_trans_sector then ActiveTransform(self.m_trans_sector, false) end
        if self.m_trans_range then ActiveTransform(self.m_trans_range, true) end
        if self.m_trans_ring_sector then ActiveTransform(self.m_trans_ring_sector, false) end
        if self.m_trans_half_circle then ActiveTransform(self.m_trans_half_circle, false) end
        
    elseif self.m_skillRangeType == SKILL_RANGE_TYPE.RECT_IN_CIRCLE then
        self.m_selectorType = SELECTOR_TYPE.RECT_IN_CIRCLE
        if self.m_trans_line then ActiveTransform(self.m_trans_line, false) end
        if self.m_trans_rect then ActiveTransform(self.m_trans_rect, true) end
        if self.m_trans_circle then ActiveTransform(self.m_trans_circle, false) end
        if self.m_trans_sector then ActiveTransform(self.m_trans_sector, false) end
        if self.m_trans_range then ActiveTransform(self.m_trans_range, true) end
        if self.m_trans_ring_sector then ActiveTransform(self.m_trans_ring_sector, false) end
        if self.m_trans_half_circle then ActiveTransform(self.m_trans_half_circle, false) end

    elseif self.m_skillRangeType == SKILL_RANGE_TYPE.SECTOR_RING then
        self.m_selectorType = SELECTOR_TYPE.SECTOR_RING
        if self.m_trans_line then ActiveTransform(self.m_trans_line, false) end
        if self.m_trans_rect then ActiveTransform(self.m_trans_rect, false) end
        if self.m_trans_circle then ActiveTransform(self.m_trans_circle, false) end
        if self.m_trans_sector then ActiveTransform(self.m_trans_sector, false) end
        if self.m_trans_range then ActiveTransform(self.m_trans_range, false) end
        if self.m_trans_ring_sector then ActiveTransform(self.m_trans_ring_sector, true) end
        if self.m_trans_half_circle then ActiveTransform(self.m_trans_half_circle, false) end

    elseif self.m_skillRangeType == SKILL_RANGE_TYPE.HALF_CIRCLE then
        self.m_selectorType = SELECTOR_TYPE.HALF_CIRCLE
        if self.m_trans_line then ActiveTransform(self.m_trans_line, false) end
        if self.m_trans_rect then ActiveTransform(self.m_trans_rect, false) end
        if self.m_trans_circle then ActiveTransform(self.m_trans_circle, false) end
        if self.m_trans_sector then ActiveTransform(self.m_trans_sector, false) end
        if self.m_trans_range then ActiveTransform(self.m_trans_range, false) end
        if self.m_trans_ring_sector then ActiveTransform(self.m_trans_ring_sector, false) end
        if self.m_trans_half_circle then ActiveTransform(self.m_trans_half_circle, true) end
    end
end

-- in : Vector3
function SkillSelector:UpdateSkillSelector(inputPos)    
    self.m_skillReallySingleTarget = nil
    self.m_skillReallyDir = Vector3.zero
    self.m_skillReallyPos = inputPos

    self.m_skillReallyDir = inputPos - self.m_startPos  
    self.m_skillReallyDir.y = 0

    local battleLogic = CtlBattleInst:GetLogic()
    
    if self.m_skillRangeType == SKILL_RANGE_TYPE.CIRCLE or 
        self.m_skillRangeType == SKILL_RANGE_TYPE.SINGLE_TARGET or
        self.m_skillRangeType == SKILL_RANGE_TYPE.LOLLIPOP2 then
            
        if self.m_skillReallyDir:SqrMagnitude() > battleLogic:GetSkillDistanceSqr(self.m_disSqr1) then
            self.m_skillReallyPos = self.m_startPos + Vector3.Normalize(self.m_skillReallyDir) * battleLogic:GetSkillDistance(self.m_dis1)
        end

    elseif self.m_skillRangeType == SKILL_RANGE_TYPE.LOLLIPOP then
        local sqrMag = self.m_skillReallyDir:SqrMagnitude()
        if sqrMag > battleLogic:GetSkillDistanceSqr(self.m_disSqr1) then
            self.m_skillReallyPos = self.m_startPos + Vector3.Normalize(self.m_skillReallyDir) * battleLogic:GetSkillDistance(self.m_dis1)
        elseif sqrMag < battleLogic:GetSkillDistanceSqr(self.m_disSqr4) then
            self.m_skillReallyPos = self.m_startPos + Vector3.Normalize(self.m_skillReallyDir) * battleLogic:GetSkillDistance(self.m_dis4)
        end
        
    elseif self.m_skillRangeType == SKILL_RANGE_TYPE.RECT then
        self.m_skillReallyPos = self.m_startPos + Vector3.Normalize(self.m_skillReallyDir) * (battleLogic:GetSkillDistance(self.m_dis3) + self.m_dis2 / 2)

    elseif self.m_skillRangeType == SKILL_RANGE_TYPE.LINE then
        self.m_skillReallyPos = self.m_startPos + Vector3.Normalize(self.m_skillReallyDir) * self.m_dis2 / 2
        
    elseif self.m_skillRangeType == SKILL_RANGE_TYPE.RECT_IN_CIRCLE then
        if self.m_skillReallyDir:SqrMagnitude() > battleLogic:GetSkillDistanceSqr(self.m_disSqr3) then
            self.m_skillReallyPos = self.m_startPos + Vector3.Normalize(self.m_skillReallyDir) * battleLogic:GetSkillDistance(self.m_dis3)
        end

    else
        self.m_skillReallyPos = self.m_startPos + Vector3.Normalize(self.m_skillReallyDir) * 0.2
    end

    if self.m_skillRangeType == SKILL_RANGE_TYPE.SINGLE_TARGET or self.m_skillRangeType == SKILL_RANGE_TYPE.LOLLIPOP2 then
        local target = nil
        local dis = 9999999
        local tPos = Vector3.zero
        for _, tmpTarget in ipairs(self.m_candidateTargets) do
            if tmpTarget and tmpTarget:IsLive() then
                local x,y,z = tmpTarget:GetPosition():GetXYZ()
                local targetPos = Vector3.New(x, y, z)
                local tmpSqr = (self.m_skillReallyPos - targetPos):SqrMagnitude() - tmpTarget:GetRadius()
               
                if tmpSqr < 4 and tmpSqr < dis then
                   
                    if (targetPos - self.m_startPos):SqrMagnitude() <= battleLogic:GetSkillDistanceSqr(self.m_disSqr1) then
                        dis = tmpSqr
                        target = tmpTarget
                        tPos = targetPos
                    end
                end
            end
        end
        if target then
            self.m_skillReallySingleTarget = target
            self.m_skillReallyPos = tPos
        end
    end

    self:UpdateSelectorType()
end

function SkillSelector:UpdateSelectorType()

    if self.m_selectorType == SELECTOR_TYPE.LINE then
        self:CreateLine()
        GameUtility.SetLocalPosition(self.m_selectorRootTrans, self.m_startPos.x, self.m_startPos.y + OFFSET_Y, self.m_startPos.z)
    
        local dir = self.m_skillReallyPos - self.m_startPos
        dir.y = 0
        GameUtility.SetLocalFromRotation(self.m_trans_line, Vector3.forward, dir)
        
        local width = self.m_dis1

        GameUtility.SetLocalScale(self.m_trans_line_part1, width, 1, 320 * PIX_TO_UNIT)
        GameUtility.SetLocalScale(self.m_trans_line_part2, width, 1, self.m_dis2 - 700 * PIX_TO_UNIT)
        GameUtility.SetLocalScale(self.m_trans_line_part3, width, 1, 380 * PIX_TO_UNIT)
        
        GameUtility.SetLocalPosition(self.m_trans_line_part2, 0, 0, 320 * PIX_TO_UNIT)
        GameUtility.SetLocalPosition(self.m_trans_line_part3, 0, 0, self.m_dis2 - 380 * PIX_TO_UNIT)

    elseif self.m_selectorType == SELECTOR_TYPE.RECT then
        self:CreateRect()

        GameUtility.SetLocalPosition(self.m_selectorRootTrans, self.m_startPos.x, self.m_startPos.y + OFFSET_Y, self.m_startPos.z)
    
        local dir = self.m_skillReallyPos - self.m_startPos
        dir.y = 0
        GameUtility.SetLocalFromRotation(self.m_trans_rect, Vector3.forward, dir)

        local width = self.m_dis1
        local range = CtlBattleInst:GetLogic():GetSkillDistance(self.m_dis3)
        
        GameUtility.SetLocalScale(self.m_trans_rect_part1, width, 1, 220 * PIX_TO_UNIT)
        GameUtility.SetLocalScale(self.m_trans_rect_part2, width, 1, self.m_dis2 - 440 * PIX_TO_UNIT)
        GameUtility.SetLocalScale(self.m_trans_rect_part3, width, 1, 220 * PIX_TO_UNIT)
        
        GameUtility.SetLocalPosition(self.m_trans_rect_part1, 0, 0, range)
        GameUtility.SetLocalPosition(self.m_trans_rect_part2, 0, 0, range + 220 * PIX_TO_UNIT)
        GameUtility.SetLocalPosition(self.m_trans_rect_part3, 0, 0, range + self.m_dis2 - 220 * PIX_TO_UNIT)

    elseif self.m_selectorType == SELECTOR_TYPE.CIRCLE then
        self:CreateCircle()
        self:CreateRange()

        GameUtility.SetLocalPosition(self.m_selectorRootTrans, self.m_startPos.x, self.m_startPos.y + OFFSET_Y, self.m_startPos.z)

        local dir = self.m_skillReallyPos - self.m_startPos
        dir.y = 0
        GameUtility.SetLocalFromRotation(self.m_trans_circle, Vector3.forward, dir)

        local distance = dir:Magnitude()
        local rangeD = CtlBattleInst:GetLogic():GetSkillDistance(self.m_dis1) * 2
        local effectD = self.m_dis2 * 2
        
        if self.m_skillRangeType == SKILL_RANGE_TYPE.SINGLE_TARGET then
            if self.m_skillReallySingleTarget then
                effectD = self.m_skillReallySingleTarget:GetRadius() * 2
            else
                effectD = 0
            end
        end
        
        GameUtility.SetLocalScale(self.m_trans_range_part1, rangeD, 1, rangeD)
        GameUtility.SetLocalScale(self.m_trans_circle_part1, effectD, 1, effectD)
        
        GameUtility.SetLocalPosition(self.m_trans_circle_part1, 0, 0, distance)

    elseif self.m_selectorType == SELECTOR_TYPE.SECTOR then
        self:CreateSector()

        GameUtility.SetLocalPosition(self.m_selectorRootTrans, self.m_startPos.x, self.m_startPos.y + OFFSET_Y, self.m_startPos.z)

        local dir = self.m_skillReallyPos - self.m_startPos
        dir.y = 0
        GameUtility.SetLocalFromRotation(self.m_trans_sector, Vector3.forward, dir)

        local radiusOuter = CtlBattleInst:GetLogic():GetSkillDistance(self.m_dis2)
        local equalWidth = math_sin(math_rad(self.m_angle) / 2) * radiusOuter * 2
        
        GameUtility.SetLocalScale(self.m_trans_sector_part1, equalWidth, 1, radiusOuter)

    elseif self.m_selectorType == SELECTOR_TYPE.LOLLIPOP2 then
        self:CreateRange()
        self:CreateCircle()
        self:CreateLine()
        
        GameUtility.SetLocalPosition(self.m_selectorRootTrans, self.m_startPos.x, self.m_startPos.y + OFFSET_Y, self.m_startPos.z)

        local dir = self.m_skillReallyPos - self.m_startPos
        dir.y = 0
        GameUtility.SetLocalFromRotation(self.m_trans_line, Vector3.forward, dir)
        GameUtility.SetLocalFromRotation(self.m_trans_circle, Vector3.forward, dir)
        
        local distance = dir:Magnitude()
        local rangeD = CtlBattleInst:GetLogic():GetSkillDistance(self.m_dis1) * 2
        local effectD = 0
        local width = self.m_dis2
        local height = distance

        GameUtility.SetLocalScale(self.m_trans_range_part1, rangeD, 1, rangeD)
        
        if self.m_skillReallySingleTarget then
            effectD = self.m_skillReallySingleTarget:GetRadius() * 2
        else
             width = 0
             height = 0
        end
        
        GameUtility.SetLocalScale(self.m_trans_circle_part1, effectD, 1, effectD)
        GameUtility.SetLocalPosition(self.m_trans_circle_part1, 0, 0, distance)

        local fLinePart2Z = height - 320 * PIX_TO_UNIT
       
        if fLinePart2Z > 0 then
            GameUtility.SetLocalScale(self.m_trans_line_part1, width, 1, 320 * PIX_TO_UNIT)
            GameUtility.SetLocalScale(self.m_trans_line_part2, width, 1, fLinePart2Z)
        else
            GameUtility.SetLocalScale(self.m_trans_line_part1, 0, 0, 0)
            GameUtility.SetLocalScale(self.m_trans_line_part2, 0, 0, 0)
        end

        GameUtility.SetLocalScale(self.m_trans_line_part3, 0, 0, 0)
        GameUtility.SetLocalPosition(self.m_trans_line_part2, 0, 0, 320 * PIX_TO_UNIT)

    elseif self.m_selectorType == SELECTOR_TYPE.LOLLIPOP then
        self:CreateRange()
        self:CreateCircle()
        self:CreateLine()
        
        GameUtility.SetLocalPosition(self.m_selectorRootTrans, self.m_startPos.x, self.m_startPos.y + OFFSET_Y, self.m_startPos.z)

        local dir = self.m_skillReallyPos - self.m_startPos
        dir.y = 0
        GameUtility.SetLocalFromRotation(self.m_trans_line, Vector3.forward, dir)
        GameUtility.SetLocalFromRotation(self.m_trans_circle, Vector3.forward, dir)
        
        local distance = dir:Magnitude()
        local width = self.m_dis3
        local height = distance - self.m_dis2

        local fLinePart2Z = height - 320 * PIX_TO_UNIT;
        if fLinePart2Z > 0 then
            GameUtility.SetLocalScale(self.m_trans_line_part1, width, 1, 320 * PIX_TO_UNIT)
            GameUtility.SetLocalScale(self.m_trans_line_part2, width, 1, fLinePart2Z)
        else
            GameUtility.SetLocalScale(self.m_trans_line_part1, 0, 0, 0)
            GameUtility.SetLocalScale(self.m_trans_line_part2, 0, 0, 0)
        end

        GameUtility.SetLocalScale(self.m_trans_line_part3, 0, 0, 0)        
        GameUtility.SetLocalPosition(self.m_trans_line_part2, 0, 0, 320 * PIX_TO_UNIT)

        local rangeD = CtlBattleInst:GetLogic():GetSkillDistance(self.m_dis1) * 2
        local effectD = self.m_dis2 * 2

        GameUtility.SetLocalScale(self.m_trans_range_part1 , rangeD, 1, rangeD)
        GameUtility.SetLocalScale(self.m_trans_circle_part1, effectD, 1, effectD)
        
        GameUtility.SetLocalPosition(self.m_trans_circle_part1, 0, 0, distance)

    elseif self.m_selectorType == SELECTOR_TYPE.RECT_IN_CIRCLE then
        self:CreateRange()
        self:CreateRect()

        GameUtility.SetLocalPosition(self.m_selectorRootTrans, self.m_startPos.x, self.m_startPos.y + OFFSET_Y, self.m_startPos.z)

        local rangeD = CtlBattleInst:GetLogic():GetSkillDistance(self.m_dis3) * 2
        
        GameUtility.SetLocalScale(self.m_trans_range_part1, rangeD, 1, rangeD)

        local dir = self.m_skillReallyPos - self.m_startPos
        dir.y = 0
        GameUtility.SetLocalFromRotation(self.m_trans_rect, Vector3.forward, dir)

        local width = self.m_dis1
        local range = dir:Magnitude()
        local fixHeight = 220 * PIX_TO_UNIT;
        local scaleHeight = self.m_dis2 - fixHeight * 2

        GameUtility.SetLocalScale(self.m_trans_rect_part1, width, 1, fixHeight)
        GameUtility.SetLocalScale(self.m_trans_rect_part2, width, 1, scaleHeight)
        GameUtility.SetLocalScale(self.m_trans_rect_part3, width, 1, fixHeight)
        
        GameUtility.SetLocalPosition(self.m_trans_rect_part1, 0, 0, range - scaleHeight * 0.5 - fixHeight)
        GameUtility.SetLocalPosition(self.m_trans_rect_part2, 0, 0, range - scaleHeight * 0.5)
        GameUtility.SetLocalPosition(self.m_trans_rect_part3, 0, 0, range + scaleHeight * 0.5)

    elseif self.m_selectorType == SELECTOR_TYPE.SECTOR_RING then
        self:CreateRingSector()

        GameUtility.SetLocalPosition(self.m_selectorRootTrans, self.m_startPos.x, self.m_startPos.y + OFFSET_Y, self.m_startPos.z)

        local dir = self.m_skillReallyPos - self.m_startPos
        dir.y = 0
        GameUtility.SetLocalFromRotation(self.m_trans_ring_sector, Vector3.forward, dir)

        local radiusOuter = CtlBattleInst:GetLogic():GetSkillDistance(self.m_dis2)
        local equalWidth = math_sin(math_rad(self.m_angle) / 2) * radiusOuter * 2
        local equalHeight = radiusOuter - self.m_dis3
        
        GameUtility.SetLocalScale(self.m_trans_ring_sector_part1, equalWidth, 1, equalHeight + 32 * PIX_TO_UNIT)        
        GameUtility.SetLocalPosition(self.m_trans_ring_sector_part1, 0, 0, -32 * PIX_TO_UNIT)

    elseif self.m_selectorType == SELECTOR_TYPE.HALF_CIRCLE then
        self:CreateHalfCircle()

        GameUtility.SetLocalPosition(self.m_selectorRootTrans, self.m_startPos.x, self.m_startPos.y + OFFSET_Y, self.m_startPos.z)

        local dir = self.m_skillReallyPos - self.m_startPos
        dir.y = 0
        GameUtility.SetLocalFromRotation(self.m_trans_half_circle, Vector3.forward, dir)

        local effectR = self.m_dis2
        local effectD = self.m_dis2 * 2
        local effectRH = self.m_dis2 / 2
        
        GameUtility.SetLocalScale(self.m_trans_half_circle_part1, effectD, 1, effectR)
        GameUtility.SetLocalPosition(self.m_trans_half_circle_part1, 0, 0, effectRH)
    end
end

function SkillSelector:CreateLine()
    if not self.m_trans_line then
        local mat = ResourcesManagerInst:LoadSync("EffectCommonMat/DynamicMaterials/SelectorLine.mat", Type_Material)
        self.m_trans_line = GameUtility.CreateLine(self.m_selectorRootTrans, mat, LAYER)
        self.m_trans_line_part1 = self.m_trans_line:Find('Part1')
        self.m_trans_line_part2 = self.m_trans_line:Find('Part2')
        self.m_trans_line_part3 = self.m_trans_line:Find('Part3')
        self.m_line_material = mat
    end
end

function SkillSelector:CreateRect()
    if not self.m_trans_rect then
        local mat = ResourcesManagerInst:LoadSync("EffectCommonMat/DynamicMaterials/SelectorRect.mat", Type_Material)
        self.m_trans_rect = GameUtility.CreateRect(self.m_selectorRootTrans, mat, LAYER)
        self.m_trans_rect_part1 = self.m_trans_rect:Find('Part1')
        self.m_trans_rect_part2 = self.m_trans_rect:Find('Part2')
        self.m_trans_rect_part3 = self.m_trans_rect:Find('Part3')
        self.m_rect_material = mat
    end
end

function SkillSelector:CreateCircle()
    if not self.m_trans_circle then
        local mat = ResourcesManagerInst:LoadSync("EffectCommonMat/DynamicMaterials/SelectorCircle.mat", Type_Material)        
        self.m_trans_circle = GameUtility.CreateCircle(self.m_selectorRootTrans, mat, LAYER)
        self.m_trans_circle_part1 = self.m_trans_circle:Find('Part1')
        self.m_circle_material = mat
    end
end

function SkillSelector:CreateSector()
    if not self.m_trans_sector then
        local mat = ResourcesManagerInst:LoadSync("EffectCommonMat/DynamicMaterials/SelectorSector.mat", Type_Material)
        self.m_trans_sector = GameUtility.CreateSector(self.m_selectorRootTrans, mat, LAYER)
        self.m_trans_sector_part1 = self.m_trans_sector:Find('Part1')
        self.m_sector_material = mat
    end
end

function SkillSelector:CreateRingSector()
    if not self.m_trans_ring_sector then
        local mat = ResourcesManagerInst:LoadSync("EffectCommonMat/DynamicMaterials/SectorRing.mat", Type_Material)
        local transList = GameUtility.CreateRingSector(self.m_selectorRootTrans, mat, LAYER)
        self.m_trans_ring_sector, self.m_trans_ring_sector_part1 = transList[0], transList[1]
        self.m_ring_sector_material = mat
    end
end

function SkillSelector:CreateRange()
    if not self.m_trans_range then
        local mat = ResourcesManagerInst:LoadSync("EffectCommonMat/DynamicMaterials/SelectorRange.mat", Type_Material)
        self.m_trans_range = GameUtility.CreateRange(self.m_selectorRootTrans, mat, LAYER)
        self.m_trans_range_part1 = self.m_trans_range:Find('RangePart1')
        self.m_range_material = mat
    end
end

function SkillSelector:CreateHalfCircle()
    if not self.m_trans_half_circle then
        local mat = ResourcesManagerInst:LoadSync("EffectCommonMat/DynamicMaterials/SelectorHalfCircle.mat", Type_Material)
        self.m_trans_half_circle = GameUtility.CreateHalfCircle(self.m_selectorRootTrans, mat, LAYER)
        self.m_trans_half_circle_part1 = self.m_trans_half_circle:Find('Part1')
        self.m_half_circle_material = mat
    end
end

function SkillSelector:GetSkillReallyPos()
    return self.m_skillReallyPos
end

function SkillSelector:GetSkillReallyDir()
    return self.m_skillReallyDir
end

function SkillSelector:SkillReallySingleTarget()
    return self.m_skillReallySingleTarget
end

function SkillSelector:GetSkillRangeType()
    return self.m_skillRangeType
end

return SkillSelector