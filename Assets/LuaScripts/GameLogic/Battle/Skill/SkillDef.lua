local FixMul = FixMath.mul
local FixAdd = FixMath.add
local FixDiv = FixMath.div
local FixCeil = FixMath.ceil
local FixFloor = FixMath.floor
local FixNewVector3 = FixMath.NewFixVector3
local FixDistance = FixMath.Vector3Distance
local FixNormalize = FixMath.Vector3Normalize
local FixIsInRect = FixMath.IsInRect
local FixIsInSector = FixMath.IsInSector
local FixSub = FixMath.sub
local FixVetor3RotateAroundY = FixMath.Vector3RotateAroundY
local string_format = string.format

SKILL_CHK_RESULT = {
    OK = 0,
    ERR = 1,
    TOO_FAR = 2,
    RESELECT = 3,
    TARGET_TYPE_UNFIT = 4,
    CD = 5,
    FIGHT_STATUS_ERR = 6,
    NUQI_LESS = 7,
    OTHER = 8,
}

SKILL_RANGE_TYPE = {
    RING = 1,                                   -- 圆环
    SECTOR = 2,                               -- 扇形
    RECT = 3,
    CIRCLE = 4,                                 -- 圆形
    LINE = 5,                                     -- 直线
    SINGLE_TARGET = 6,                          -- 单体目标
    INFINITE_LINE = 7,                            -- 直线 无限长(配置距离非常大的直线，另起一枚举以区别选择框的纹理)
    LOLLIPOP = 8,                                 -- 棒棒糖形
    LOLLIPOP2 = 9,                                 -- 棒棒糖2 （单体）
    RECT_IN_CIRCLE = 10,                           -- 圆内正方形
    ZHUGELIANG_FLAGS = 11,                           -- 诸葛亮选旗子 todo 可能没用
    SECTOR_RING = 12,                           -- 诸葛亮选旗子 todo 可能没用
    HALF_CIRCLE = 14,                                -- 半圆
}

SKILL_RELATION_TYPE = {
    NONE = 0,                                 -- 无
    ENEMY = 1,                                 -- 敌人
    FRIEND_WITH_SELF = 2,              -- 我方 包括自己
    SELF = 3,                                     -- 自己
    FRIEND_WITHOUT_SELF = 4,       -- 我方 不包括自己
}

SKILL_TARGET_TYPE = {
    CURRENT_TARGET = 1,                 -- 当前攻击目标
    NONE = 2,                                   -- 无目标
    ANY = 3,                                      -- 至少一个目标
}

SKILL_ANI = {
    ATTACK = 0,
    SKILL = 1,
}

SKILL_TYPE = {
    PHY_ATK = 1,                        -- 物理普攻
    MAGIC_ATK = 2,                      -- 法术普攻
    PHY_ACTIVE_SKILL = 3,                -- 物理主动技能
    MAGIC_ACTIVE_SKILL = 4,            -- 法术主动技能
    OTHER_ACTIVE_SKILL = 5,             -- 其他主动技
    PHY_PASSIVE_SKILL = 6,                -- 物理被动技能
    MAGIC_PASSIVE_SKILL = 7,            -- 法术被动技能
    OTHER_PASSIVE_SKILL = 8,             -- 其他被动技
    DAZHAO = 9,                                 -- 选区大招
    DAZHAO_NO_SELECT = 11                       -- 不选区大招
}

SKILL_PERFORM_MODE = {
    MANUAL = 1,                             -- 手动
    AI = 2,                                               -- AI
}

SKILL_PHASE = {
    INVALID = 0,                        --无效阶段
    PREPARE = 1,                        --准备
    PERFORM = 2,                        --释放
    KEY_FRAME = 3,                      --关键帧
}

SKILL_TIPS_TYPE = {
    DAZHAO = 0,
    ACTIVE = 1,
    PASSIVE = 2,
}

SKILL_CD = {
    GLOBAL = 2000,
    LITTLE_MONSTER_GLOBALCD = 4000,
}

SkillUtil = {
    A = function(skillCfg)
        return skillCfg["A"]
    end,

    B = function(skillCfg)
        return skillCfg["B"]
    end,

    C = function(skillCfg)
        return skillCfg["C"]
    end,

    D = function(skillCfg)
        return skillCfg["D"]
    end,

    E = function(skillCfg)
        return skillCfg["E"]
    end,

    X = function(skillCfg, level)
        return skillCfg[string_format("x%d", level)]
    end,

    Y = function(skillCfg, level)
        return skillCfg[string_format("y%d", level)]
    end,

    Z = function(skillCfg, level)
        return skillCfg[string_format("z%d", level)]
    end,

    IsMagicSkill = function(skillCfg)
        return skillCfg.type == SKILL_TYPE.MAGIC_ACTIVE_SKILL or skillCfg.type == SKILL_TYPE.MAGIC_PASSIVE_SKILL
    end,

    IsPhySkill = function(skillCfg)
        return skillCfg.type == SKILL_TYPE.PHY_ACTIVE_SKILL or skillCfg.type == SKILL_TYPE.PHY_PASSIVE_SKILL
    end,

    IsActiveSkill = function(skillCfg)
        return skillCfg.type == SKILL_TYPE.PHY_ACTIVE_SKILL or skillCfg.type == SKILL_TYPE.MAGIC_ACTIVE_SKILL or 
            skillCfg.type == SKILL_TYPE.OTHER_ACTIVE_SKILL
    end,

    IsPassiveSkill = function(skillCfg)
        return skillCfg.type == SKILL_TYPE.PHY_PASSIVE_SKILL or skillCfg.type == SKILL_TYPE.MAGIC_PASSIVE_SKILL or
            skillCfg.type == SKILL_TYPE.OTHER_PASSIVE_SKILL
    end,

    IsDazhao = function (skillCfg)
        return skillCfg.type == SKILL_TYPE.DAZHAO or skillCfg.type == SKILL_TYPE.DAZHAO_NO_SELECT
    end,

    IsAtk = function (skillCfg)
        return skillCfg.type == SKILL_TYPE.PHY_ATK or skillCfg.type == SKILL_TYPE.MAGIC_ATK
    end,

    -- IsOnce = function(skillCfg)
    --     return skillCfg.isOnce == 1
    -- end,

    IsContinueGuide = function(skillCfg)
        return skillCfg.guideduring > 0
    end,
}

SkillRoleColorParam = BaseClass("SkillRoleColorParam")
function SkillRoleColorParam:__init(_phase, _delay, _during, _recover, _color)
    self.phase = _phase
    self.delay = _delay
    self.during = _during
    self.recover = _recover
    self.color = _color
end

PerformParam = BaseClass("PerformParam")
function PerformParam:__init(_keyFrameTimes, _preparam, _performMode)
    self.keyFrameTimes = _keyFrameTimes
    self.preparam = _preparam
    self.performMode = _performMode
end

SkillCheckResult = BaseClass("SkillCheckResult")
function SkillCheckResult:__init(newTarget, pos)
    self.newTarget = newTarget
    self.pos = pos
end

local LinedirI = {0, -90, -180, -270}
local LineangleJ = {0, -22.5, -45.0, -67.5, 22.5, 45.0, 67.5}
local Lineangles = {0.0, 15, 30.0, 45, 60.0, 75, 90, -15, -30.0, -45, -60.0, -75, -90, 135, 180, -135}
local Rectangles = {0.0, 22.5, 45.0, 67.5, 90.0, 112.5, 135.0, 157.5, 180.0, 202.5, 225.0, 247.5, 270.0, 292.5, 315.0, 337.5}
local CircleanglesK = {90, 180, 270, 360}            
local SectordirI = {0, 22.5, 45.0, 67.5, -22.5, -45.0, -67.5,}
local SectorangleJ = {0, -22.5, -45.0, -67.5, 22.5, 45.0, 67.5}
local SectorangleI = {0, -22.5, -45.0, -67.5, -90.0, -112.5, -135.0, -157.5, -180.0, -202.5, -225.0, -247.5, -270.0, -292.5, -315.0, -337.5}
local Rect_CircleanglesK = {0, 45, 90, 135, 180, 225, 270, 315, 360, 405, 450, 495, 540, 585, 630, 675}
local HalfCircleI = {0, 15, 30, 45, -15, -30, -45}
local HalfCircleJ = {0, -7.5, -15.0, -22.5, 22.5, 15.0, 7.5}

SkillRangeHelper = {
    IsInRect = function(targetPos, targetRadius, widthHalf, heightHalf, rectCenter, normalizedDir)
        local isIn = FixIsInRect(targetPos, targetRadius, widthHalf, heightHalf, rectCenter, normalizedDir)
        return isIn
    end,

    -- args: sectorCenter, sectorForward, sectorSmallRadius, sectorBigRadius, sectorAngle, targetPos, targetRadius
    IsInSector = function(circleCenter, forward, dis1, dis2, angle, targetPos, targetRadius)
        local isIn = FixIsInSector(circleCenter, forward, dis1, dis2, angle, targetPos, targetRadius)
        return isIn
    end,

    IsInCircle = function(circleCenter, circelRadius, targetPos, targetRadius)
        local sqrDistance = (circleCenter - targetPos):SqrMagnitude()
        local radiusSum = FixAdd(circelRadius, targetRadius)
        return sqrDistance <= FixMul(radiusSum, radiusSum)
    end,

    RotateAroundY = function(forward, angle)
        return FixVetor3RotateAroundY(forward, angle)
    end,

    -- return : (true,false), SkillCheckResult
    Line = function(performer, currTarget, targetList, skillCfg, skillbase)
        local targetPos = nil

        local selfPos = performer:GetPosition()
        local range = CtlBattleInst:GetLogic():GetSkillDistance(skillCfg.dis2)
        local fieldForward = CtlBattleInst:GetLogic():GetCurrWaveForward(performer:GetCamp())
        local rangeVec = fieldForward * FixDiv(range, 2)

        if #targetList == 1 then
            local p2 = currTarget:GetPosition()
            local tmp = selfPos - p2
            if tmp:SqrMagnitude() <= FixMul(range, range) then
                targetPos = p2
            end
        else            
            local halfTargetCount = FixCeil(FixMul(#targetList, 0.8))
            local RotateAroundY = SkillRangeHelper.RotateAroundY
            local hitCount = 0

            for _, angle in ipairs(Lineangles) do
                local pos = RotateAroundY(rangeVec, angle) 
                pos:Add(selfPos)
                local ret, tmpList = skillbase:GetTargetList(performer, pos, nil)
                if tmpList and #tmpList > hitCount then
                    targetPos = pos
                    hitCount = #tmpList

                    if hitCount >= halfTargetCount then
                        break
                    end
                end
            end
        end
        if targetPos then
            return true, SkillCheckResult.New(nil, targetPos)
        else
            return false
        end
    end,

    -- return : (true,false), SkillCheckResult
    Rect = function(performer, currTarget, targetList, skillCfg, skillbase)
        local targetPos = nil

        local selfPos = performer:GetPosition()
        local skldis = CtlBattleInst:GetLogic():GetSkillDistance(skillCfg.dis2)
        local range = FixAdd(skldis, skillCfg.dis3)

        local rangeVec = FixNewVector3(0, 0, FixAdd(FixDiv(skldis, 2), skillCfg.dis3))
        local sqrRange = FixMul(range, range)

        if #targetList == 1 then
            local p2 = currTarget:GetPosition()
            local tmp = selfPos - p2
            local sqrP = tmp:SqrMagnitude()
            if sqrP <= sqrRange and sqrP >= skillCfg.disSqr3 then
                targetPos = p2
            end
        else
            local hitCount = 0
            local halfTargetCount = FixFloor(FixDiv(#targetList, 2))

            local RotateAroundY = SkillRangeHelper.RotateAroundY
            for i = 1, 16 do
                local pos = RotateAroundY(rangeVec, Rectangles[i]) 
                pos:Add(selfPos)
                local ret, tmpList = skillbase:GetTargetList(performer, pos, nil)
                if tmpList and #tmpList > hitCount then
                    targetPos = pos
                    hitCount = #tmpList

                    if hitCount >= halfTargetCount then
                        break
                    end
                end
            end
        end

        if targetPos then
            return true, SkillCheckResult.New(nil, targetPos)
        else
            return false
        end
    end,

    -- return : (true,false), SkillCheckResult
    Circle = function(performer, currTarget, targetList, skillCfg, skillbase)
        local targetPos = nil

        local range = CtlBattleInst:GetLogic():GetSkillDistance(skillCfg.dis1)
        local radius = skillCfg.dis2

        local radiusVect = FixNewVector3(0, 0, radius)
        local sum_range_radius = FixAdd(range, radius)

        if #targetList == 1 then
            local p1 = performer:GetPosition()
            local p2 = targetList[1]:GetPosition()
            local distance = FixDistance(p1, p2)
            if distance <= sum_range_radius then
                if distance <= range then
                    targetPos = p2
                else
                    -- targetPos = p1 + (p2 - p1) * FixDiv(range, distance)

                    local dir = FixNormalize(p2 - p1)
                    dir:Mul(range)
                    dir:Add(p1)
                    targetPos = dir
                end
            end
        elseif #targetList == 2 then
            local p1 = targetList[1]:GetPosition()
            local p2 = targetList[2]:GetPosition()
            local p3 = performer:GetPosition()

            local dis1 = FixDistance(p1, p3)
            local dis2 = FixDistance(p2, p3)
            if dis1 <= sum_range_radius or dis2 <= sum_range_radius then
                if dis1 <= sum_range_radius and dis2 <= sum_range_radius and 
                    (p1 - p2):SqrMagnitude() <= FixMul(FixMul(radius, radius), 4) then
                    targetPos = (p1 + p2) 
                    targetPos:Div(2)
                
                elseif dis1 <= sum_range_radius then
                    if dis1 <= range then
                        targetPos = p1
                    else
                        -- targetPos = p3 + FixNormalize(p1 - p3) * range

                        targetPos = FixNormalize(p1 - p3)
                        targetPos:Mul(range)
                        targetPos:Add(p3)
                    end

                elseif dis2 <= sum_range_radius then
                    if dis2 <= range then
                        targetPos = p2
                    else
                        -- targetPos = p3 + FixNormalize(p1 - p3) * range

                        targetPos = FixNormalize(p1 - p3)
                        targetPos:Mul(range)
                        targetPos:Add(p3)
                    end
                end
            end
        else
            local hitCount = 0
            local targetCount = #targetList
            local p1 = performer:GetPosition()

            local RotateAroundY = SkillRangeHelper.RotateAroundY
            for i = 1, targetCount do
                local p2 = targetList[i]:GetPosition()

                for k = 1, 4 do
                    local pos = RotateAroundY(radiusVect, CircleanglesK[k])
                    pos:Add(p2)

                    if (pos - p1):SqrMagnitude() <= skillCfg.disSqr1 then
                        local ret, tmpList = skillbase:GetTargetList(performer, pos, nil)
                        if tmpList and #tmpList > hitCount then
                            hitCount = #tmpList
                            targetPos = pos
                            if hitCount >= targetCount then
                                break
                            end
                        end
                    end
                end

                if hitCount >= targetCount then
                    break
                end
            end
        end

        if targetPos then
            return true, SkillCheckResult.New(nil, targetPos)
        else
            return false
        end
    end,

    -- return : (true,false), SkillCheckResult
    Sector = function(performer, currTarget, targetList, skillCfg, skillbase)
        local targetPos = nil
        local p1 = performer:GetPosition()
        local range = CtlBattleInst:GetLogic():GetSkillDistance(skillCfg.dis2)
        local rangeVec = FixNewVector3(0, 0, range)

        if #targetList == 1 then
            local p2 = currTarget:GetPosition()
            if skillbase:InRange(performer, currTarget, p2 - p1, nil) then
                targetPos = p2
            end            

        elseif #targetList <= 4 then
            local dirCount = {0, 0, 0, 0}
            local maxCount = 0

            for _, tmpTarget in ipairs(targetList) do
                local p2 = tmpTarget:GetPosition()
                local dirVec = p2 - p1
                local x,y,z = dirVec:GetXYZ()
                if x >= 0 and z >= 0 then
                    dirCount[1] = FixAdd(dirCount[1], 1)
                    if dirCount[1] > maxCount then
                        maxCount = dirCount[1]
                    end
                elseif x <= 0 and z >= 0 then
                    dirCount[4] = FixAdd(dirCount[4], 1)
                    if dirCount[4] > maxCount then
                        maxCount = dirCount[4]
                    end
                elseif x <= 0 and z <= 0 then
                    dirCount[3] = FixAdd(dirCount[3], 1)
                    if dirCount[3] > maxCount then
                        maxCount = dirCount[3]
                    end
                elseif x >= 0 and z <= 0 then
                    dirCount[2] = FixAdd(dirCount[2], 1)
                    if dirCount[2] > maxCount then
                        maxCount = dirCount[2]
                    end
                end
            end

            local halfTargetCount = FixCeil(FixDiv(#targetList, 2))

            local RotateAroundY = SkillRangeHelper.RotateAroundY
            for i, count in ipairs(dirCount) do
                if count >= maxCount then
                    local hitCount = 0
                    for j = 1, 7 do
                        local pos = RotateAroundY(rangeVec, FixAdd(SectordirI[i], SectorangleJ[j]))
                        pos:Add(p1)
                        local ret, tmpList = skillbase:GetTargetList(performer, pos, nil)
                        if tmpList and #tmpList > hitCount then
                            targetPos = pos
                            hitCount = #tmpList

                            if hitCount >= halfTargetCount then
                                break
                            end
                        end
                    end
                end
            end

        else
            local halfTargetCount = FixFloor(FixDiv(#targetList, 2))
            local RotateAroundY = SkillRangeHelper.RotateAroundY
            local hitCount = 0
            for i = 1, 16 do
                local pos = RotateAroundY(rangeVec, SectorangleI[i]) 
                pos:Add(p1)
                local ret, tmpList = skillbase:GetTargetList(performer, pos, nil)
                if tmpList and #tmpList > hitCount then
                    targetPos = pos
                    hitCount = #tmpList

                    if hitCount >= halfTargetCount then
                        break
                    end
                end
            end
        end

        if targetPos then
            return true, SkillCheckResult.New(nil, targetPos)
        else
            return false
        end
    end,

    -- return : (true,false), SkillCheckResult
    SingleTarget = function(performer, currTarget, targetList, skillCfg, skillbase)
        local p1 = performer:GetPosition()
        local target = nil

        -- 当前目标属于技能目标则选择当前目标，否则遍历技能目标选择范围内的一个

        local IsTargetInList = function(targetList, target)
            for _, tmpTarget in ipairs(targetList) do
                if target:GetActorID() == tmpTarget:GetActorID() then
                    return true
                end
            end
            return false
        end

        if currTarget and IsTargetInList(targetList, currTarget) then
            local p2 = currTarget:GetPosition()
            if skillbase:InRange(performer, currTarget, p2 - p1, p2) then
                target = currTarget
            end
        else
            for _, tmpTarget in ipairs(targetList) do
                local p2 = tmpTarget:GetPosition()
                if skillbase:InRange(performer, tmpTarget, p2 - p1, p2) then
                    target = tmpTarget
                    break
                end
            end
        end

        if target then
            return true, SkillCheckResult.New(target, target:GetPosition())
        else
            return false
        end
    end,

    -- return : (true,false), SkillCheckResult
    Lollipop = function(performer, currTarget, targetList, skillCfg, skillbase)
        local ret, chkRet = SkillRangeHelper.Circle(performer, currTarget, targetList, skillCfg, skillbase)
        if ret then
            local targetPos = chkRet.pos
            local dir = targetPos - performer:GetPosition()
            if dir:SqrMagnitude() < skillCfg.disSqr4 then
                local ndir = FixNormalize(dir)
                local range = CtlBattleInst:GetLogic():GetSkillDistance(skillCfg.dis1)
                ndir:Mul(range)
                ndir:Add(performer:GetPosition())
                chkRet.pos = ndir
            end
        else
            return ret, chkRet
        end
    end,

    -- return : (true,false), SkillCheckResult
    Rect_Circle = function(performer, currTarget, targetList, skillCfg, skillbase)
        local targetPos = nil

        local selfPos = performer:GetPosition()
        local range = CtlBattleInst:GetSkillDistance(skillCfg.dis3)
        local rangeSqr = CtlBattleInst:GetSkillDistanceSqr(skillCfg.disSqr3)

        local minRadius = skillCfg.dis1 
        if skillCfg.dis2 < minRadius then
            minRadius = skillCfg.dis2
        end

        local radiusVect = FixNewVector3(0, 0, minRadius)

        if #targetList == 1 then
            local p1 = performer:GetPosition()
            local p2 = targetList[1]:GetPosition()
            local distance = FixDistance(p1, p2)
            if distance <= range + skillCfg.dis2 then
                if distance <= range then
                    targetPos = p2
                else
                    -- targetPos = p1 + (p2 - p1) * (FixDiv(range, distance))

                    targetPos = p2 - p1
                    targetPos:Mul(FixDiv(range, distance))
                    targetPos:Add(p1)
                end
            end
        else
            local hitCount = 0
            local targetCount = #targetList
            local p1 = performer:GetPosition()
            local RotateAroundY = SkillRangeHelper.RotateAroundY
            for i = 1, targetCount do
                local p2 = targetList[i]:GetPosition()
                
                for k = 1, 8 do
                    local pos = RotateAroundY(radiusVect, Rect_CircleanglesK[k])
                    pos:Add(p2)

                    if (pos - p1):SqrMagnitude() <= rangeSqr then
                        local ret, tmpList = skillbase:GetTargetList(performer, pos, nil)
                        if tmpList and #tmpList > hitCount then
                            hitCount = #tmpList
                            targetPos = pos
                            if hitCount >= targetCount then
                                break
                            end
                        end
                    end
                end
            end
        end

        if targetPos then
            return true, SkillCheckResult.New(nil, targetPos)
        else
            return false
        end
    end,


    HalfCircle = function(performer, currTarget, targetList, skillCfg, skillbase)
        local targetPos = nil
        local p1 = performer:GetPosition()
        local range = CtlBattleInst:GetLogic():GetSkillDistance(skillCfg.dis2)
        local rangeVec = FixNewVector3(0, 0, range)

        if #targetList == 1 then
            local p2 = currTarget:GetPosition()
            if skillbase:InRange(performer, currTarget, p2 - p1, nil) then
                targetPos = p2
            end            

        elseif #targetList <= 4 then
            local dirCount = {0, 0, 0, 0}
            local maxCount = 0

            for _, tmpTarget in ipairs(targetList) do
                local p2 = tmpTarget:GetPosition()
                local dirVec = p2 - p1
                local x,y,z = dirVec:GetXYZ()
                if x >= 0 and z >= 0 then
                    dirCount[1] = FixAdd(dirCount[1], 1)
                    if dirCount[1] > maxCount then
                        maxCount = dirCount[1]
                    end
                elseif x <= 0 and z >= 0 then
                    dirCount[4] = FixAdd(dirCount[4], 1)
                    if dirCount[4] > maxCount then
                        maxCount = dirCount[4]
                    end
                elseif x <= 0 and z <= 0 then
                    dirCount[3] = FixAdd(dirCount[3], 1)
                    if dirCount[3] > maxCount then
                        maxCount = dirCount[3]
                    end
                elseif x >= 0 and z <= 0 then
                    dirCount[2] = FixAdd(dirCount[2], 1)
                    if dirCount[2] > maxCount then
                        maxCount = dirCount[2]
                    end
                end
            end

            local halfTargetCount = FixCeil(FixDiv(#targetList, 2))

            local RotateAroundY = SkillRangeHelper.RotateAroundY
            for i, count in ipairs(dirCount) do
                if count >= maxCount then
                    local hitCount = 0
                    for j = 1, 7 do
                        local pos = RotateAroundY(rangeVec, FixAdd(HalfCircleI[i], HalfCircleJ[j]))
                        pos:Add(p1)
                        local ret, tmpList = skillbase:GetTargetList(performer, pos, nil)
                        if tmpList and #tmpList > hitCount then
                            targetPos = pos
                            hitCount = #tmpList

                            if hitCount >= halfTargetCount then
                                break
                            end
                        end
                    end
                end
            end

        else
            local halfTargetCount = FixFloor(FixDiv(#targetList, 2))
            local RotateAroundY = SkillRangeHelper.RotateAroundY
            local hitCount = 0
            for i = 1, 7 do
                local pos = RotateAroundY(rangeVec, HalfCircleI[i]) 
                pos:Add(p1)
                local ret, tmpList = skillbase:GetTargetList(performer, pos, nil)
                if tmpList and #tmpList > hitCount then
                    targetPos = pos
                    hitCount = #tmpList

                    if hitCount >= halfTargetCount then
                        break
                    end
                end
            end
        end

        if targetPos then
            return true, SkillCheckResult.New(nil, targetPos)
        else
            return false
        end
    end,
    --todo continue
}