local table_insert = table.insert
local FixNewVector3 = FixMath.NewFixVector3
local FixNormalize = FixMath.Vector3Normalize
local CtlBattleInst = CtlBattleInst
local Actor = require "GameLogic.Battle.Actors.Actor"
local DieShowActor = BaseClass("DieShowActor", Actor)

function DieShowActor:__init()
end

function DieShowActor:SetWujiangID(wujiangID)
    self.m_wujiangID = wujiangID
end

function DieShowActor:SetWuqiLevel(wuqiLevel)
    self.m_wuqiLevel = wuqiLevel
end

function DieShowActor:SetActorID(actorID)
    self.m_actorID = actorID
    self.m_relationType = BattleEnum.RelationType_SON_NONINTERACTIVE
end

function DieShowActor:SetSkillContainer(skillContainer)
    self.m_skillContainer = skillContainer
end

function DieShowActor:SetFightData(fightData)
    self.m_fightData = fightData
end

function DieShowActor:SetCamp(camp)
    self.m_camp = camp
end

function DieShowActor:SetLineupPos(lineupPos)
    self.m_lineUpPos = lineupPos
end

function DieShowActor:SetForward(dir)
    if dir then
        dir = FixNormalize(dir)
        self.m_forward = FixNewVector3(dir.x, 0, dir.z)

        if self.m_component then
            self.m_component:SetForward(self.m_forward, true)
        end
    end
end

function DieShowActor:SetPosition(pos)
    self.m_position = pos
    if self.m_component then
        self.m_component:SetPosition(pos)
    end
end

function DieShowActor:SimpleMove(...)
    self:PlayAnim(BattleEnum.ANIM_MOVE)
    local desPos, desDir = ...

    local pathHandler = CtlBattleInst:GetPathHandler()  
    if pathHandler then
        local x, y, z = self.m_position:GetXYZ()
        local x2, y2, z2 = desPos:GetXYZ()
        local pathPosList = pathHandler:FindPath(x, y, z, x2, y2, z2)
        if pathPosList and next(pathPosList) then
            local posList = {}
			for _,v in ipairs(pathPosList) do
				local pos = FixNewVector3(v.x , v.y, v.z)
                table_insert(posList, pos)
            end
            self.m_moveHelper:Start(posList, self:GetMoveSpeed(), nil, true)
        else
            -- print("no find path " , self.m_position, desPos)
        end
    end
end

function DieShowActor:Update(deltaMS)
    if self.m_isPause then
        return
    end

    self.m_moveHelper:Update(deltaMS)
end

function DieShowActor:GetActorColor()
    if self.m_component then
        return self.m_component:GetActorColor()
    end
end

function DieShowActor:StopMove()
    if self.m_moveHelper then
        self.m_moveHelper:Stop()
        self:PlayAnim(BattleEnum.ANIM_IDLE)
    end
end

-- 死亡表现完后，由对应的死亡表现逻辑回收
function DieShowActor:DeleteComponent()
    if self.m_component then
        self.m_component:Delete() 
        self.m_component = nil
    end
end

-- 死亡表现完后，由对应的死亡表现逻辑回收
function Actor:DeleteFightData()
    if self.m_fightData then
        self.m_fightData:Delete()
        self.m_fightData = nil
    end
end

return DieShowActor