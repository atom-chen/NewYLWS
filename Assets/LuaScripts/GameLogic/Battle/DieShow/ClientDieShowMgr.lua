local table_insert = table.insert
local BattleEnum = BattleEnum
local table_remove = table.remove
local FixNewVector3 = FixMath.NewFixVector3
local HIDE_POSITION = FixNewVector3(6666, 6666, 6666)
local BaseDieShowMgr = require "GameLogic.Battle.DieShow.BaseDieShowMgr"
local ClientDieShowMgr = BaseClass("ClientDieShowMgr", BaseDieShowMgr)

function ClientDieShowMgr:__init()
    self.m_showArray = {}
end

function ClientDieShowMgr:Clear()
    self.m_showArray = {}
end

function ClientDieShowMgr:DieShow(...)
    local _, deadmode = ...
    local dieshow = nil
    if deadmode == BattleEnum.DEADMODE_DEFAULT or deadmode == BattleEnum.DEADMODE_KEEPBODY or deadmode == BattleEnum.DEADMODE_STUN then
        local dieshowClass = require "GameLogic.Battle.DieShow.impl.NormalDieShow"
        dieshow = dieshowClass.New()
    elseif deadmode == BattleEnum.DEADMODE_ESCAPE then
        local dieshowClass = require "GameLogic.Battle.DieShow.impl.EscapeDieShow"
        dieshow = dieshowClass.New()
    elseif deadmode == BattleEnum.DEADMODE_NODIESHOW then
        local dieshowClass = require "GameLogic.Battle.DieShow.impl.ActorNoDieShow"
        dieshow = dieshowClass.New()
    elseif deadmode == BattleEnum.DEADMODE_BYEBYE then
        local dieshowClass = require "GameLogic.Battle.DieShow.impl.ByeByeDieShow"
        dieshow = dieshowClass.New()
    elseif deadmode == BattleEnum.DEADMODE_DISAPPEAR then
        local dieshowClass = require "GameLogic.Battle.DieShow.impl.DisappearDieShow"
        dieshow = dieshowClass.New()
    elseif deadmode == BattleEnum.DEADMODE_ZHANGJIAOHUFA then
        local dieshowClass = require "GameLogic.Battle.DieShow.impl.ZhangjiaoHufaDieShow"
        dieshow = dieshowClass.New()
    elseif deadmode == BattleEnum.DEADMODE_DEPARTURE then
        local dieshowClass = require "GameLogic.Battle.DieShow.impl.DepartureDieShow"
        dieshow = dieshowClass.New()
    end
    dieshow:Start(...)
    CtlBattleInst:AddPauseListener(dieshow)
    table_insert(self.m_showArray, dieshow)
end

function ClientDieShowMgr:Update(deltaTime)
    for i = #self.m_showArray, 1, -1 do
        local show = self.m_showArray[i]
        if show then
            show:Update(deltaTime)
            if show:IsRealActorGone() and show:IsOver() then
                CtlBattleInst:RemovePauseListener(show)
                show:Delete()
                table_remove(self.m_showArray, i)
            end
        end
    end
end

function ClientDieShowMgr:HideDeadActor()
    for _, dieShow in ipairs(self.m_showArray) do
        dieShow:SetPosition(HIDE_POSITION)
    end
end

return ClientDieShowMgr