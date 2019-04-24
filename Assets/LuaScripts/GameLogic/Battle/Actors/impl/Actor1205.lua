local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local BattleEnum = BattleEnum
local FixIntMul = FixMath.muli
local FixAdd = FixMath.add
local FixMod = FixMath.mod
local FixDiv = FixMath.div
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local table_insert = table.insert
local ACTOR_ATTR = ACTOR_ATTR
local FixVetor3RotateAroundY = FixMath.Vector3RotateAroundY
local ActorManagerInst = ActorManagerInst
local ConfigUtil = ConfigUtil
local SkillUtil = SkillUtil
local FixRand = BattleRander.Rand
local CtlBattleInst = CtlBattleInst
local IsInCircle = SkillRangeHelper.IsInCircle
local IsInRect = SkillRangeHelper.IsInRect
local FixNormalize = FixMath.Vector3Normalize
local FixNewVector3 = FixMath.NewFixVector3

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1205 = BaseClass("Actor1205", Actor)
local ActorCreateParam = require "GameLogic.Battle.Actors.ActorCreateParam"

function Actor1205:__init()
    self.m_12053SkillItem = nil
    self.m_12053Level = 0
    self.m_12053XPercent = 0
    self.m_12053C = 0
    self.m_12053YPercent = 0
    self.m_12053B = 0
    self.m_12053DHP = 0

    self.m_12051X = 0
    self.m_12051SkillItem = nil
    self.m_12051SkillCfg = nil
    self.m_12051Level = 0
    self.m_12051B = 0
    self.m_12051D = 0

    self.m_canCall = false
    self.m_chgHP = 0

    self.m_12052ReducePerent = 0
    self.m_isFar = 0
    self.m_baseHP = 0
end

function Actor1205:OnAttackEnd(skillCfg)
    Actor.OnAttackEnd(self, skillCfg)

    if skillCfg.id == 12052 then
        self.m_12052ReducePerent = 0
    end
end


function Actor1205:PreChgHP(giver, chgHP, hurtType, reason)
    if self.m_12052ReducePerent > 0 and hurtType == BattleEnum.HURTTYPE_PHY_HURT then
        local skillCfg = ConfigUtil.GetSkillCfgByID(giver.skillID)
        if skillCfg and skillCfg.hurt_far == self.m_isFar then
            chgHP = FixSub(chgHP, FixMul(chgHP, self.m_12052ReducePerent))
            return chgHP
        end
    end

    return Actor.PreChgHP(self, giver, chgHP, hurtType, reason)
end


function Actor1205:Set12052ReducePercent(percent, isFar)
    self.m_12052ReducePerent = percent
    self.m_isFar = isFar
end

function Actor1205:OnHPChg(giver, deltaHP, hurtType, reason, keyFrame)
    Actor.OnHPChg(self, giver, deltaHP, hurtType, reason, keyFrame)

    if deltaHP > 0 then
        return
    end

    self.m_chgHP = FixAdd(self.m_chgHP, FixMul(deltaHP, -1))
    if self.m_12053SkillCfg and self.m_chgHP >= self.m_12053AHP then
        self.m_chgHP = FixSub(self.m_chgHP, self.m_12053AHP)

        if self.m_12053Level >= 3 then
            local mul = 1
            if self.m_12053Level >= 6 then
                local curHp = self:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
                if curHp < self.m_12053DHP then
                    mul = 2
                end
            end

            local chgPhyDef = self:CalcAttrChgValue(ACTOR_ATTR.BASE_PHY_DEF, self.m_12053YPercent)
            local chgMagicDef = self:CalcAttrChgValue(ACTOR_ATTR.BASE_MAGIC_DEF, self.m_12053YPercent)

            local giver = StatusGiver.New(self:GetActorID(), 12053)
            local buff = StatusFactoryInst:NewStatusGongsunzanBuff(giver, BattleEnum.AttrReason_SKILL, self.m_12053C, nil, self.m_12053B)
            buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_DEF, chgPhyDef)
            buff:AddAttrPair(ACTOR_ATTR.FIGHT_MAGIC_DEF, chgMagicDef)
            buff:SetMergeRule(StatusEnum.MERGERULE_MERGE)
            self:GetStatusContainer():Add(buff, self)
        end

        local chgPhyDef = self:CalcAttrChgValue(ACTOR_ATTR.FIGHT_PHY_DEF, self.m_12053XPercent)
        local chgMagicDef = self:CalcAttrChgValue(ACTOR_ATTR.FIGHT_MAGIC_DEF, self.m_12053XPercent)

        ActorManagerInst:Walk(
            function(tmpTarget)
                if not CtlBattleInst:GetLogic():IsFriend(self, tmpTarget, true) then
                    return
                end

                local giver = StatusGiver.New(self:GetActorID(), 12053)
                local buff = StatusFactoryInst:NewStatusGongsunzanBuff(giver, BattleEnum.AttrReason_SKILL, self.m_12053C, nil, 1000)
                buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_DEF, chgPhyDef)
                buff:AddAttrPair(ACTOR_ATTR.FIGHT_MAGIC_DEF, chgMagicDef)
                buff:SetMergeRule(StatusEnum.MERGERULE_MERGE)
                tmpTarget:GetStatusContainer():Add(buff, self)
            end   
        )  
    end
end


function Actor1205:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    -- 公孙瓒每损失{A}%的生命，就为己方全体武将提升相当于自身{x1}%的物防与法防，持续{C}秒。
    -- 公孙瓒每损失{A}%的生命，就为己方全体武将提升相当于自身{x2}%的物防与法防，持续{C}秒。
    -- 公孙瓒每损失{A}%的生命，就为己方全体武将提升相当于自身{x3}%的物防与法防，持续{C}秒。同时公孙瓒得到{y3}%的双防加成，最多可叠加{B}层。
    -- 公孙瓒每损失{A}%的生命，就为己方全体武将提升相当于自身{x4}%的物防与法防，持续{C}秒。同时公孙瓒得到{y4}%的双防加成，最多可叠加{B}层。
    -- 公孙瓒每损失{A}%的生命，就为己方全体武将提升相当于自身{x5}%的物防与法防，持续{C}秒。同时公孙瓒得到{y5}%的双防加成，最多可叠加{B}层。
    -- 公孙瓒每损失{A}%的生命，就为己方全体武将提升相当于自身{x6}%的物防与法防，持续{C}秒。同时公孙瓒得到{y6}%的双防加成，最多可叠加{B}层。公孙瓒的生命低于{D}%时，从围堑筑京技能中获得的累计防御加成翻倍。

    self.m_baseHP = self:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)

    local skillItem = self.m_skillContainer:GetPassiveByID(12053)
    if skillItem then
        self.m_12053SkillItem = skillItem
        local level = skillItem:GetLevel()
        self.m_12053Level = level
        local skillCfg = ConfigUtil.GetSkillCfgByID(12053)
        if skillCfg then
            self.m_12053SkillCfg = skillCfg

            self.m_12053AHP = FixIntMul(self.m_baseHP, FixDiv(SkillUtil.A(skillCfg, level), 100))
            self.m_12053XPercent = FixDiv(SkillUtil.X(skillCfg, level), 100)
            self.m_12053C = FixIntMul(SkillUtil.C(skillCfg, level), 1000)

            if level >= 3 then
                self.m_12053YPercent = FixDiv(SkillUtil.Y(skillCfg, level), 100)
                self.m_12053B = SkillUtil.B(skillCfg, level)
                if level >= 6 then
                    self.m_12053DHP = FixIntMul(FixDiv(SkillUtil.D(skillCfg, level), 100), self.m_baseHP)
                end
            end
        end
    end
    
    local dazhaoskillItem = self.m_skillContainer:GetActiveByID(12051)
    if dazhaoskillItem then
        self.m_12051SkillItem = dazhaoskillItem
        local level = dazhaoskillItem:GetLevel()
        self.m_12051Level = level
        local skillCfg = ConfigUtil.GetSkillCfgByID(12051)
        if skillCfg then
            self.m_12051SkillCfg = skillCfg
            self.m_12051X = SkillUtil.X(skillCfg, level)
            self.m_12051B = SkillUtil.B(skillCfg, level)
            self.m_12051D = SkillUtil.D(skillCfg, level)
        end
    end
end

function Actor1205:GetSkill12051X()
    return self.m_12051X
end

function Actor1205:GetSkill12051B()
    return self.m_12051B
end

function Actor1205:GetSkill12051SkillCfg()
    return self.m_12051SkillCfg
end


function Actor1205:Get12053X()
    return self.m_12053X
end


function Actor1205:Get12053SkillCfg()
    return self.m_12053SkillCfg
end


function Actor1205:GetSkill12051SkillLevel()
    return self.m_12051Level
end

function Actor1205:CalcCallStandIndex(callCount)
    local posList = {}

    for i=1, callCount do
        local leftDir = nil
        local tmpDir = FixNormalize(self:GetForward())
        local pos = self:GetPosition()
        if i <= 4 then
            tmpDir:Mul(-5.5)
        else
            tmpDir:Mul(-9)
        end

        leftDir = pos + tmpDir

        local dir = FixVetor3RotateAroundY(self:GetForward(), 90)
        if FixMod(i, 4) == 0 then -- 第4/8个
            dir:Mul(-3.6)
            
        elseif FixMod(i, 4) == 1 then
            dir:Mul(3.6)

        elseif FixMod(i, 4) == 2 then
            dir:Mul(1.2)

        elseif FixMod(i, 4) == 3 then
            dir:Mul(-1.2)

        end

        leftDir:Add(dir)
        table_insert(posList, leftDir)
    end

    for i=1,#posList do
        self:Call(posList[i], i)
    end
end


function Actor1205:LogicOnFightStart(currWave)
    self.m_canCall = true
end


function Actor1205:LogicOnFightEnd()
    self.m_canCall = false
end


function Actor1205:Call(pos, standIndex)
    if not self.m_canCall then
        return
    end

    --  召唤{A}个新的白马义从
    local roleCfg = ConfigUtil.GetWujiangCfgByID(3207)
    if not roleCfg then
        print('========== no 3207 role cfg ================')
    end

    local oneWujiang = OneBattleWujiang.New()
    oneWujiang.wujiangID = roleCfg.id
    oneWujiang.level = self.m_level
    oneWujiang.lineUpPos = 1

    local fightData = self:GetData()
    oneWujiang.max_hp = fightData:GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
    oneWujiang.phy_atk = fightData:GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK)
    oneWujiang.phy_def = fightData:GetAttrValue(ACTOR_ATTR.BASE_PHY_DEF)
    oneWujiang.magic_atk = fightData:GetAttrValue(ACTOR_ATTR.BASE_MAGIC_ATK)
    oneWujiang.magic_def = fightData:GetAttrValue(ACTOR_ATTR.BASE_MAGIC_DEF)
    oneWujiang.phy_baoji = fightData:GetAttrValue(ACTOR_ATTR.BASE_PHY_BAOJI)
    oneWujiang.magic_baoji = fightData:GetAttrValue(ACTOR_ATTR.BASE_MAGIC_BAOJI)
    oneWujiang.shanbi = fightData:GetAttrValue(ACTOR_ATTR.BASE_SHANBI)
    oneWujiang.mingzhong = fightData:GetAttrValue(ACTOR_ATTR.BASE_MINGZHONG)
    oneWujiang.move_speed = fightData:GetAttrValue(ACTOR_ATTR.BASE_MOVESPEED)
    oneWujiang.atk_speed = fightData:GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED)
    oneWujiang.hp_recover = fightData:GetAttrValue(ACTOR_ATTR.BASE_HP_RECOVER)
    oneWujiang.nuqi_recover = fightData:GetAttrValue(ACTOR_ATTR.BASE_NUQI_RECOVER)
    oneWujiang.baoji_hurt = fightData:GetAttrValue(ACTOR_ATTR.BASE_BAOJI_HURT)
    oneWujiang.init_nuqi = 1000

    table_insert(oneWujiang.skillList, {skill_id = 32071, skill_level = 1})

    local createParam = ActorCreateParam.New()
    createParam:MakeSource(BattleEnum.ActorSource_CALLED, self:GetActorID())
    createParam:MakeAI(BattleEnum.AITYPE_BAIMAYICONG)
    createParam:MakeAttr(self:GetCamp(), oneWujiang)
    createParam:MakeLocation(pos, self:GetForward())
    createParam:MakeRelationType(BattleEnum.RelationType_SON_NONINTERACTIVE)
    createParam:SetImmediateCreateObj(true)

    local delay = 0
    local disTance = self.m_12051D
    if standIndex > 4 then
        delay = 500 
        disTance = FixAdd(disTance, 3.5)
    end
    local congyiActor = ActorManagerInst:CreateActor(createParam)
    local forward = congyiActor:GetForward():Clone()
    forward:Mul(disTance)
    forward:Add(congyiActor:GetPosition())
    -- local targetPos = congyiActor:GetPosition() + forward * disTance
    

    congyiActor:SetTargetPos(forward)

    local congyiAI = congyiActor:GetAI()
    if congyiAI then
        congyiAI:SetDelay(delay)
    end
end




return Actor1205