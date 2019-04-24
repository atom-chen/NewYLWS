

function status_test_prepare()
    package.path = "./?.lua;" .. package.path
    package.path = "../../../?.lua;" .. package.path
    package.path = "../../../Framework/Common/?.lua;" .. package.path
    package.path = "../../../GameLogic/Battle/?.lua;" .. package.path
    print(package.path)
    FixMath = {}
    FixMath.Div = function(a, b) return a/b  end
    FixMath.Mul = function(a, b) return a*b  end
    FixMath.Vector3Normalize = function(v) return v end
    FixMath.Vector3Angle = function(v1, v2) return 0 end
    FixMath.NewFixVector3 = function() return nil end
    Logger = {
        LogError = print,
        Log = print,
    }
    require("BaseClass")
    Singleton = require("Singleton")

    require("BattleRander")
    require("BattleDef")
    require("StatusDef")

    StatusFactory = require("StatusFactory")
    StatusBase = require("StatusBase")
    StatusContainer = require("StatusContainer")
    

    require("impl.StatusHP")
    require("impl.StatusStun")
    require("impl.StatusBuff")
    require("impl.StatusIntervalHP")
    require("impl.StatusImmune")
    require("impl.StatusChaoFeng")
    require("impl.StatusFear")

  

    Actor = Actor or BaseClass("Actor")
    function Actor:__init()
        self.m_statusContainer = StatusContainer.New(self)
        self.m_ai = {
            RandMove = function(duringMS, intervalMS)
            end,
            SpecialStateEnd = function()
            end
        }
        -- self.m_statusContainer:InitSelf(self)
    end
    function Actor:ChangeHP(giver, hurtType, chgHP, reason, keyFrame)
        print("Actor:ChangeHP giver:", giver)
    end

    function Actor:Update(deltaTime)
        self.m_statusContainer:Update(deltaTime)
    end

    function Actor:OnDie(killer)
        print("Actor:OnDie killer", killer)
    end

    function Actor:Logic()
    end

    function Actor:IsLive()
    end

    function Actor:SetTargetID(targetID)
    end

    function Actor:GetAI()
        return self.m_ai;
    end

    function Actor:TestAddStatusHP()
        local s = StatusFactory:GetInstance():NewStatusHP(StatusGiver.New(1,100), -99, 1, 1, 1, 0)
        self.m_statusContainer:AddStatus(s)
    end

    function Actor:TestAddStatusStun()
        local s = StatusFactory:GetInstance():NewStatusStun(StatusGiver.New(1,100), 1000, 1)
        self.m_statusContainer:DelayAdd(s)
    end

    function Actor:TestAddStatusChaoFeng()
        local s = StatusFactory:GetInstance():NewStatusChaoFeng(StatusGiver.New(1, 100), 1001, 10000)
        self.m_statusContainer:AddStatus(s)
    end

    function Actor:TestAddStatusFear()
        local s= StatusFactory:GetInstance():NewStatusFear(StatusGiver.New(1,100), 2, {StatusEnum.STATUSTYPE_FEAR})
        self.m_statusContainer:AddStatus(s)
    end
end

status_test_prepare()


function test_giver()
    local g = StatusGiver.New(1, 2, 3, 4)
    print(g)
    g:Clear()
    print(g)
end

StatusFactory:GetInstance()
local actor = Actor.New()
actor:TestAddStatusHP()
actor:TestAddStatusStun()
actor:TestAddStatusChaoFeng()
-- actor:TestAddStatusFear()
for i = 1, 50 do
    actor:Update(100)
end

BattleRander.Generate(10000)
-- print(BattleRander.Rand())