local FixDiv = FixMath.div
local FixNormalize = FixMath.Vector3Normalize
local FixMul = FixMath.mul
local FixAdd = FixMath.add
local Angle = FixMath.Vector3Angle  --角度
local FixNewVector3 = FixMath.NewFixVector3
local table_insert = table.insert
local table_remove = table.remove
local MediumEnum = MediumEnum
local StatusGiver = StatusGiver
local CtlBattleInst = CtlBattleInst


local MediumManager = BaseClass("MediumManager", Singleton)


local ID_CLASS_MAP = {
    [MediumEnum.MEDIUMTYPE_ONLY_LOGIC]                  = "GameLogic.Battle.Medium.impl.MediumOnlyLogic",
    [MediumEnum.MEDIUMTYPE_LINEAR]                      = "GameLogic.Battle.Medium.impl.LinearFlyToPointMedium",
    [MediumEnum.MEDIUMTYPE_PARAMBOLA]                   = "GameLogic.Battle.Medium.impl.LinearFlyToPointMedium",
    [MediumEnum.MEDIUMTYPE_LINEAR_TO_POINT]             = "GameLogic.Battle.Medium.impl.LinearFlyToPointMedium",
    [MediumEnum.MEDIUMTYPE_PARAMBOLA_TO_POINT]          = "GameLogic.Battle.Medium.impl.ParambolaFlyToPointMedium",
    [MediumEnum.MEDIUMTYPE_BEZIER_TO_POINT]             = "GameLogic.Battle.Medium.impl.BezierFlyToPointMedium",
    [MediumEnum.MEDIUMTYPE_GUANYU_WATER]                = "GameLogic.Battle.Medium.impl.Medium10021",
    [MediumEnum.MEDIUMTYPE_LINEAR_TO_TARGET]            = "GameLogic.Battle.Medium.impl.LinearFlyToTargetMedium",
    [MediumEnum.MEDIUMTYPE_20071]                       = "GameLogic.Battle.Medium.impl.Medium20071",
    [MediumEnum.MEDIUMTYPE_20072]                       = "GameLogic.Battle.Medium.impl.Medium20072",
    [MediumEnum.MEDIUMTYPE_20073]                       = "GameLogic.Battle.Medium.impl.Medium20073",
    [MediumEnum.MEDIUMTYPE_20031]                       = "GameLogic.Battle.Medium.impl.Medium20031",
    [MediumEnum.MEDIUMTYPE_20032]                       = "GameLogic.Battle.Medium.impl.Medium20032",
    [MediumEnum.MEDIUMTYPE_20033]                       = "GameLogic.Battle.Medium.impl.Medium20033",
    [MediumEnum.MEDIUMTYPE_10481]                       = "GameLogic.Battle.Medium.impl.Medium10481",
    [MediumEnum.MEDIUMTYPE_10482]                       = "GameLogic.Battle.Medium.impl.Medium10482",
    [MediumEnum.MEDIUMTYPE_10351]                       = "GameLogic.Battle.Medium.impl.Medium10351",
    [MediumEnum.MEDIUMTYPE_10352]                       = "GameLogic.Battle.Medium.impl.Medium10352",
    [MediumEnum.MEDIUMTYPE_1035ATK]                     = "GameLogic.Battle.Medium.impl.Medium1035Atk",
    [MediumEnum.MEDIUMTYPE_10012]                       = "GameLogic.Battle.Medium.impl.Medium10012",
    [MediumEnum.MEDIUMTYPE_10436]                       = "GameLogic.Battle.Medium.impl.Medium10436",
    [MediumEnum.MEDIUMTYPE_NORMALFLY]                   = "GameLogic.Battle.Medium.impl.NormalFly",
    [MediumEnum.MEDIUMTYPE_20402]                       = "GameLogic.Battle.Medium.impl.Medium20402",
    [MediumEnum.MEDIUMTYPE_20052]                       = "GameLogic.Battle.Medium.impl.Medium20052",
    [MediumEnum.MEDIUMTYPE_3606_DAZHAO]                 = "GameLogic.Battle.Medium.impl.MediumDragon3606",
    [MediumEnum.MEDIUMTYPE_3601_DAZHAO]                 = "GameLogic.Battle.Medium.impl.MediumDragon3601",
    [MediumEnum.MEDIUMTYPE_3602_DAZHAO]                 = "GameLogic.Battle.Medium.impl.MediumDragon3602",
    [MediumEnum.MEDIUMTYPE_3603_DAZHAO]                 = "GameLogic.Battle.Medium.impl.MediumDragon3603",
    [MediumEnum.MEDIUMTYPE_20972]                       = "GameLogic.Battle.Medium.impl.Medium20972",
    [MediumEnum.MEDIUMTYPE_20432]                       = "GameLogic.Battle.Medium.impl.Medium20342",
    [MediumEnum.MEDIUMTYPE_20433]                       = "GameLogic.Battle.Medium.impl.Medium20343",
    [MediumEnum.MEDIUMTYPE_10341]                       = "GameLogic.Battle.Medium.impl.Medium10341",
    [MediumEnum.MEDIUMTYPE_10342]                       = "GameLogic.Battle.Medium.impl.Medium10342",
    [MediumEnum.MEDIUMTYPE_10292]                       = "GameLogic.Battle.Medium.impl.Medium10292",
    [MediumEnum.MEDIUMTYPE_10291]                       = "GameLogic.Battle.Medium.impl.Medium10291",
    [MediumEnum.MEDIUMTYPE_10381]                       = "GameLogic.Battle.Medium.impl.Medium10381",
    [MediumEnum.MEDIUMTYPE_10382]                       = "GameLogic.Battle.Medium.impl.Medium10382",
    [MediumEnum.MEDIUMTYPE_10291Ball]                   = "GameLogic.Battle.Medium.impl.Medium10291Ball",
    [MediumEnum.MEDIUMTYPE_10443Ghost]                  = "GameLogic.Battle.Medium.impl.Medium10443Ghost",
    [MediumEnum.MEDIUMTYPE_CHORD]                       = "GameLogic.Battle.Medium.impl.MediumChord",
    [MediumEnum.MEDIUMTYPE_20973]                       = "GameLogic.Battle.Medium.impl.Medium20973",
    [MediumEnum.MEDIUMTYPE_20974]                       = "GameLogic.Battle.Medium.impl.Medium20974",
    [MediumEnum.MEDIUMTYPE_10622]                       = "GameLogic.Battle.Medium.impl.Medium10622",
    [MediumEnum.MEDIUMTYPE_10443]                       = "GameLogic.Battle.Medium.impl.Medium10443",
    [MediumEnum.MEDIUMTYPE_35102]                       = "GameLogic.Battle.Medium.impl.Medium35102",
    [MediumEnum.MEDIUMTYPE_12142]                       = "GameLogic.Battle.Medium.impl.Medium12142",
    [MediumEnum.MEDIUMTYPE_20481]                       = "GameLogic.Battle.Medium.impl.Medium20481",
    [MediumEnum.MEDIUMTYPE_20371]                       = "GameLogic.Battle.Medium.impl.Medium20371",
    [MediumEnum.MEDIUMTYPE_11111]                       = "GameLogic.Battle.Medium.impl.Medium11111",
    [MediumEnum.MEDIUMTYPE_11112]                       = "GameLogic.Battle.Medium.impl.Medium11112",
    [MediumEnum.MEDIUMTYPE_11114]                       = "GameLogic.Battle.Medium.impl.Medium11114",
    [MediumEnum.MEDIUMTYPE_11115]                       = "GameLogic.Battle.Medium.impl.Medium11115",
    [MediumEnum.MEDIUMTYPE_35012]                       = "GameLogic.Battle.Medium.impl.Medium35012",
    [MediumEnum.MEDIUMTYPE_12141]                       = "GameLogic.Battle.Medium.impl.Medium12141",
    [MediumEnum.MEDIUMTYPE_10611]                       = "GameLogic.Battle.Medium.impl.Medium10611",
    [MediumEnum.MEDIUMTYPE_1061ATK]                     = "GameLogic.Battle.Medium.impl.Medium1061ATK",
    [MediumEnum.MEDIUMTYPE_1006ATK]                     = "GameLogic.Battle.Medium.impl.Medium1006ATK",
    [MediumEnum.MEDIUMTYPE_10061]                       = "GameLogic.Battle.Medium.impl.Medium10061",
    [MediumEnum.MEDIUMTYPE_10062]                       = "GameLogic.Battle.Medium.impl.Medium10062",
    [MediumEnum.MEDIUMTYPE_10152]                       = "GameLogic.Battle.Medium.impl.Medium10152",
    [MediumEnum.MEDIUMTYPE_10153]                       = "GameLogic.Battle.Medium.impl.Medium10153",
    [MediumEnum.MEDIUMTYPE_40501]                       = "GameLogic.Battle.Medium.impl.Medium40501",
    [MediumEnum.MEDIUMTYPE_20682]                       = "GameLogic.Battle.Medium.impl.Medium20682",
    [MediumEnum.MEDIUMTYPE_20702]                       = "GameLogic.Battle.Medium.impl.Medium20702",
    [MediumEnum.MEDIUMTYPE_20612]                       = "GameLogic.Battle.Medium.impl.Medium20612",
    [MediumEnum.MEDIUMTYPE_20111]                       = "GameLogic.Battle.Medium.impl.Medium20111",
    [MediumEnum.MEDIUMTYPE_20112]                       = "GameLogic.Battle.Medium.impl.Medium20112", 
    [MediumEnum.MEDIUMTYPE_20542]                       = "GameLogic.Battle.Medium.impl.Medium20542",
    [MediumEnum.MEDIUMTYPE_1011ATK]                     = "GameLogic.Battle.Medium.impl.Medium1011ATK",
    [MediumEnum.MEDIUMTYPE_2088ATK]                     = "GameLogic.Battle.Medium.impl.Medium2088Atk",
    [MediumEnum.MEDIUMTYPE_10081]                       = "GameLogic.Battle.Medium.impl.Medium10081",
    [MediumEnum.MEDIUMTYPE_1008ATK]                     = "GameLogic.Battle.Medium.impl.Medium1008ATK",
    [MediumEnum.MEDIUMTYPE_1021ATK]                     = "GameLogic.Battle.Medium.impl.Medium1021ATK",
    [MediumEnum.MEDIUMTYPE_10461]                       = "GameLogic.Battle.Medium.impl.Medium10461",
    [MediumEnum.MEDIUMTYPE_10211]                       = "GameLogic.Battle.Medium.impl.Medium10211",
    [MediumEnum.MEDIUMTYPE_20903]                       = "GameLogic.Battle.Medium.impl.Medium20903",
    [MediumEnum.MEDIUMTYPE_20903]                       = "GameLogic.Battle.Medium.impl.Medium20903", 
    [MediumEnum.MEDIUMTYPE_20571]                       = "GameLogic.Battle.Medium.impl.Medium20571", 
    [MediumEnum.MEDIUMTYPE_20541]                       = "GameLogic.Battle.Medium.impl.Medium20541", 
    [MediumEnum.MEDIUMTYPE_10082]                       = "GameLogic.Battle.Medium.impl.Medium10082",
    [MediumEnum.MEDIUMTYPE_20141]                       = "GameLogic.Battle.Medium.impl.Medium20141",
    [MediumEnum.MEDIUMTYPE_1022ATK]                     = "GameLogic.Battle.Medium.impl.Medium1022ATK",
    [MediumEnum.MEDIUMTYPE_10221]                       = "GameLogic.Battle.Medium.impl.Medium10221",
    [MediumEnum.MEDIUMTYPE_10391]                       = "GameLogic.Battle.Medium.impl.Medium10391",
    [MediumEnum.MEDIUMTYPE_10392]                       = "GameLogic.Battle.Medium.impl.Medium10392",
    [MediumEnum.MEDIUMTYPE_10441]                       = "GameLogic.Battle.Medium.impl.Medium10441",
    [MediumEnum.MEDIUMTYPE_10641]                       = "GameLogic.Battle.Medium.impl.Medium10641",
    [MediumEnum.MEDIUMTYPE_10642]                       = "GameLogic.Battle.Medium.impl.Medium10642", 
    [MediumEnum.MEDIUMTYPE_22001]                       = "GameLogic.Battle.Medium.impl.Medium22001",
    [MediumEnum.MEDIUMTYPE_22002]                       = "GameLogic.Battle.Medium.impl.Medium22002", 
    [MediumEnum.MEDIUMTYPE_22003]                       = "GameLogic.Battle.Medium.impl.Medium22003",  
    [MediumEnum.MEDIUMTYPE_10281]                       = "GameLogic.Battle.Medium.impl.Medium10281",  
    [MediumEnum.MEDIUMTYPE_35023]                       = "GameLogic.Battle.Medium.impl.Medium35023",
    [MediumEnum.MEDIUMTYPE_22012]                       = "GameLogic.Battle.Medium.impl.Medium22012", 
    [MediumEnum.MEDIUMTYPE_22013]                       = "GameLogic.Battle.Medium.impl.Medium22013", 
    [MediumEnum.MEDIUMTYPE_20151]                       = "GameLogic.Battle.Medium.impl.Medium20151", 
}

function MediumManager:__init()
    self.m_dic = {}        -- id -> obj
    self.m_mediumList = {} -- id[]
    self.m_delList = {}    -- id[]
    self.m_seq = 0
end

function MediumManager:Clear()
    for k, v in pairs(self.m_dic) do
        if v then
            v:Delete()
        end
    end

    self.m_dic = {}
    self.m_mediumList = {}
    self.m_delList = {}
    self.m_seq = 0
end

function MediumManager:Update(deltaMS)
    self:RevokeAll()

    local count = #self.m_mediumList
    for i = 1, count do 
        local medium_id = self.m_mediumList[i]
        local medium = self.m_dic[medium_id]
        if medium and medium:IsValid() then
            medium:Update(deltaMS)
        end
    end
end

function MediumManager:RemoveMedium(medium_id)
    local medium = self.m_dic[medium_id]
    if medium and medium:IsValid() then
        medium:Invalid()
        CtlBattleInst:RemovePauseListener(medium)
    end

    table_insert(self.m_delList, medium_id) 
end

function MediumManager:RevokeAll()
    local count = #self.m_delList
    for i = 1, count do
        local medium_id = self.m_delList[i]
        local medium = self.m_dic[medium_id]
        if medium then
            medium:Delete()
        end

        self.m_dic[medium_id] = nil

        for k = 1, #self.m_mediumList do
            if medium_id == self.m_mediumList[k] then
                table_remove(self.m_mediumList, k)
                break
            end
        end
    end
        
    if count > 0 then
        self.m_delList = {}
    end
end

function MediumManager:MakeID()
    self.m_seq = self.m_seq + 1
    return self.m_seq
end

function MediumManager:GetMedium(id, bIncludeInvalid)
    local medium = self.m_dic[id]
    if medium and medium:IsValid() then
        return medium
    end

    return nil
end

function MediumManager:CreateMedium(type, mediumID, giver, skillBase, pos, forward, param)
    -- TODO obj pool 
    local medium = nil
    local cls = ID_CLASS_MAP[type] 
    if cls then
        mediumCls = require(cls)
        medium = mediumCls.New()
    end

    if medium then
        local id = self:MakeID()
        -- print("mediumID" ,id)
        medium:OnCreate(id, mediumID, giver, skillBase, pos, forward, param)
        self.m_dic[id] = medium
        table_insert(self.m_mediumList, id)

        CtlBattleInst:AddPauseListener(medium)
    end
    return medium
end

function MediumManager:SetAllLayerState(layerState)
    local count = #self.m_mediumList
    for i = 1, count do 
        local medium_id = self.m_mediumList[i]
        local medium = self.m_dic[medium_id]
        if medium and medium:IsValid() then
            medium:SetLayerState(layerState)
        end
    end
end

function MediumManager:OnWaveEnd()
    if self.m_mediumList then
        local count = #self.m_mediumList
        for i = 1, count do 
            local medium_id = self.m_mediumList[i]
            self:RemoveMedium(medium_id)
        end
    end

    if self.m_delList then
        self:RevokeAll()
    end
end

return MediumManager