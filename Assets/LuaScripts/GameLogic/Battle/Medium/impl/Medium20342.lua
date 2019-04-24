local FixDiv = FixMath.div
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixIntMul = FixMath.muli
local BattleEnum = BattleEnum
local table_insert = table.insert
local ActorManagerInst = ActorManagerInst
local ACTOR_ATTR = ACTOR_ATTR

local ActorCreateParam = require "GameLogic.Battle.Actors.ActorCreateParam"

local BaseMedium = require("GameLogic.Battle.Medium.BaseMedium")
local Medium20342 = BaseClass("Medium20342", BaseMedium)

function Medium20342:__init()
   self.m_speed = 15
   self.m_distance = 0
   self.m_targetPos = nil 
   self.m_resID = 0
   self.m_monsterID = 0
   self.m_percent = 0
   self.m_leftTime = 0
end

function Medium20342:__delete()
    self.m_distance = 0 
    self.m_farthestTargetID = 0    
    self.m_targetOriginalPos = false   
    self.m_enemyList = {} 
end

function Medium20342:InitParam(param)
    BaseMedium.InitParam(self, param)

    self.m_targetPos = param.targetPos
    self.m_resID = param.resID 
    self.m_monsterID = param.monsterID 
    self.m_percent = param.percent 

    local performer = self:GetOwner()
    if performer and performer:IsLive() then
        self.m_distance = (self.m_position - self.m_targetPos):Magnitude()
        self.m_leftTime = FixMul(FixDiv(self.m_distance, self.m_speed), 1000)
    end
end


function Medium20342:DoUpdate(deltaMS)
    if self.m_isPause then
        return
    end

    self.m_leftTime = FixSub(self.m_leftTime, deltaMS)
    
    self:LookatPosOnlyShow(self.m_targetPos.x, self.m_targetPos.y, self.m_targetPos.z)

    local curDis = (self.m_position - self.m_targetPos):Magnitude()
    local tmp = FixDiv(curDis, self.m_distance)
    if tmp > 1 then
        tmp = 1
    end

    local angle = FixMul(tmp, 50)
    if angle > 60 then
        angle = 60
    elseif angle < -60 then
        angle = -60
    end

    self:Rotate(FixMul(angle, -1),0,0)

    local deltaS = FixDiv(deltaMS, 1000)
    local tmpDis = FixMul(self.m_speed, deltaS)
    if curDis > tmpDis then
        curDis = tmpDis
    end

    self:MoveOnlyShow(curDis)

    if self.m_leftTime <= 0 then
        local performer = self:GetOwner()
        if performer and performer:IsLive() then
            self:Call(performer, self.m_targetPos:Clone(), self.m_resID, self.m_monsterID, self.m_percent)
        end

        self:Over()
        return
    end
end


function Medium20342:Call(performer, pos, resID, monsterID, percent)
    local roleCfg = ConfigUtil.GetWujiangCfgByID(resID)
    if not roleCfg then
        -- print(' no boss2 he xin ==========')
        return
    end

    pos.y = performer:GetPosition().y

    local oneWujiang = OneBattleWujiang.New()
    oneWujiang.wujiangID = roleCfg.id
    oneWujiang.level = performer:GetLevel()
    oneWujiang.init_nuqi = roleCfg.initNuqi
    oneWujiang.lineUpPos = 0

    local fightData = performer:GetData()
    oneWujiang.max_hp = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_MAXHP), percent)
    oneWujiang.phy_atk = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK), percent)
    oneWujiang.phy_def = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_PHY_DEF), percent)
    oneWujiang.magic_atk = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_MAGIC_ATK), percent)
    oneWujiang.magic_def = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_MAGIC_DEF), percent)
    oneWujiang.phy_baoji = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_PHY_BAOJI), percent)
    oneWujiang.magic_baoji = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_MAGIC_BAOJI), percent)
    oneWujiang.shanbi = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_SHANBI), percent)
    oneWujiang.mingzhong = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_MINGZHONG), percent)
    oneWujiang.move_speed = fightData:GetAttrValue(ACTOR_ATTR.BASE_MOVESPEED)
    oneWujiang.atk_speed = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED), percent)

    table_insert(oneWujiang.skillList, {})

    local createParam = ActorCreateParam.New()
    createParam:MakeSource(BattleEnum.ActorSource_CALLED, performer:GetActorID())
    createParam:MakeAI(BattleEnum.AITYPE_STUPID)
    createParam:MakeAttr(performer:GetCamp(), oneWujiang)

    local forward = performer:GetForward()

    local pathHandler = CtlBattleInst:GetPathHandler()
    if pathHandler then
        local x,y,z = performer:GetPosition():GetXYZ()
        local x2, y2, z2 = pos:GetXYZ()
        local hitPos = pathHandler:HitTest(x, y, z, x2, y2, z2)
        if hitPos then
            pos:SetXYZ(hitPos.x , performer:GetPosition().y, hitPos.z)
        end
    end

    createParam:MakeLocation(pos, forward)
    createParam:MakeRelationType(BattleEnum.RelationType_NORMAL)
    
    ActorManagerInst:CreateActor(createParam)
end


return Medium20342