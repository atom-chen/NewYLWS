local BattleEnum = BattleEnum
local FixAdd = FixMath.add
local ConfigUtil = ConfigUtil
local table_insert = table.insert
local table_remove = table.remove
local NewFixVector3 = FixMath.NewFixVector3
local CommonDefine = CommonDefine
local ActorManagerInst = ActorManagerInst
local ActorCreateParam = require "GameLogic.Battle.Actors.ActorCreateParam"
local CopyLogic = require "GameLogic.Battle.BattleLogic.impl.CopyLogic"
local CampsRushLogic = BaseClass("CampsRushLogic", CopyLogic)

local base = CopyLogic

function CampsRushLogic:__init()
    self.m_battleType = BattleEnum.BattleType_CAMPSRUSH
    self.m_loadingBenchID = 0
    self.m_dierLineupPosList = {}
end

function CampsRushLogic:InitCopyCfg()
    self.m_copyCfg = ConfigUtil.GetCampsRushCopyCfgByID(self.m_battleParam.copyID)
end

function CampsRushLogic:GetMyCampCenter()
    local count = 0
    local center = NewFixVector3(0, 0, 0)
    ActorManagerInst:Walk(
        function(tmpTarget)
            if tmpTarget:GetCamp() == BattleEnum.ActorCamp_LEFT and tmpTarget:IsLive() and not tmpTarget:IsCalled() then
                center:Add(tmpTarget:GetPosition())
                count = count + 1
            end
        end
    )

    if count > 0 then
        center:Div(count)
    end
    return center
end

function CampsRushLogic:LoadBenchModel(wujiangID)
    local benchWujiangList = self.m_battleParam.leftCamp.benchWujiangList
    for _, wujiangData in pairs(benchWujiangList) do
        if wujiangData and wujiangData.wujiangID == wujiangID then
            self.m_loadingBenchID = wujiangData.wujiangID
            wujiangData.lineUpPos = self:GetReplaceLineupPos()
            local createParam = ActorCreateParam.New()
            createParam:MakeSource(BattleEnum.ActorSource_ORIGIN, 0)
            createParam:MakeAttr(BattleEnum.ActorCamp_LEFT, wujiangData)
            createParam:MakeLocation(self:GetMyCampCenter(), self:GetForward(BattleEnum.ActorCamp_LEFT, self:GetCurWave()))
            createParam:MakeAI(BattleEnum.AITYPE_MANUAL) 
            createParam:MakeRelationType(BattleEnum.RelationType_NORMAL)
            createParam:SetImmediateCreateObj(true)
        
            ActorManagerInst:CreateActor(createParam)
            break
        end
    end
end

function CampsRushLogic:OnActorCreated(actor)
    if not actor then return end

    base.OnActorCreated(self, actor)

    if actor:GetWujiangID() == self.m_loadingBenchID then
        self.m_loadingBenchID = 0

        actor:SetAnimatorSpeed(1)
        actor:GetData():SetNuqi(1000)
        actor:ResetSkillFirstCD()
        BattleCameraMgr:PlayCameraEffect(BattleEnum.CAMERA_MODE_WUJIANG_REPLACE, actor:GetActorID())
    end
end

function CampsRushLogic:GetBenchWujiangList()
    return self.m_battleParam.leftCamp.benchWujiangList
end

function CampsRushLogic:CanReplaceWujiang()
    return #self.m_dierLineupPosList > 0
end

function CampsRushLogic:GetReplaceLineupPos()
    local index = 0
    local lineupPos = 100
    for i, pos in ipairs(self.m_dierLineupPosList) do
        if pos < lineupPos then
            lineupPos = pos
            index = i
        end
    end

    table_remove(self.m_dierLineupPosList, index)
    return lineupPos
end

function CampsRushLogic:OnActorDie(actor, killerGiver, hurtReason, deadMode)
   base.OnActorDie(self, actor, killerGiver, hurtReason)

   if actor:GetCamp() == BattleEnum.ActorCamp_LEFT and not actor:IsCalled() and not actor:IsPartner() then
        table_insert(self.m_dierLineupPosList, actor:GetLineupPos())
   end
end

function CampsRushLogic:ReqSettle(isWin)
    if self.m_component then
        local floorID = Player:GetInstance():GetCampsRushMgr():GetCurPassFloor()
        self.m_component:ReqBattleFinish(self.m_battleParam.copyID, floorID, self.m_resultParam.playerWin)
    end
end

function CampsRushLogic:RecordCommand()
    return true
end

function CampsRushLogic:OnAward(battleAwardData)
    if not battleAwardData then
        return
    end  

    if battleAwardData.finish_result == 0 then
        UIManagerInst:OpenWindow(UIWindowNames.UIBattleWinView)
    else
        if self.m_resultParam.loseReason == BattleEnum.BATTLE_LOSE_REASON_TIMEOUT then
            UIManagerInst:OpenWindow(UIWindowNames.UIBattleLoseView)
        else
            UIManagerInst:OpenWindow(UIWindowNames.UIBattleLoseView)
        end
    end
end

function CampsRushLogic:DistributeDrop()
end

function CampsRushLogic:CheckDoorOpen(actorPos, cameraPos)
    if self.m_component then
        self.m_component:CheckDoorOpen(actorPos, cameraPos)
    end
end

function CampsRushLogic:GetGoWaveTimelinePath()
    return TimelineType.PATH_BATTLE_SCENE
end

return CampsRushLogic
