local BattleEnum = BattleEnum
local FixNewVector3 = FixMath.NewFixVector3

local base = require "GameLogic.Battle.DieShow.impl.NormalDieShow"
local ZhangjiaoHufaDieShow = BaseClass("ZhangjiaoHufaDieShow", base)

function ZhangjiaoHufaDieShow:Start(...)
    base.Start(self, ...)

    self.m_anim = BattleEnum.ANIM_IDLE
    self.m_deadMode = BattleEnum.DEADMODE_DEFAULT

    self.m_isTweenAlpha = false
end

function ZhangjiaoHufaDieShow:ShowDeath(anim)
    self.m_deadTime = 0.8 --这里没有马上获得动画时间
    self.m_alphaTime = 1.2
    self.m_alphaTweenTime = 1.5

    --夏侯渊分身
   
    if self.m_fakeActor and self.m_fakeActor:GetWujiangID() == 6015 then
        self.m_deadTime = 0
        self.m_alphaTime = 0.9
        self.m_alphaTweenTime = 1
    end
    
    self.m_fakeActor:PlayAnim(BattleEnum.ANIM_IDLE)
    self.m_effectKey = EffectMgr:AddEffect(self.m_fakeActor, 20012)
end

function ZhangjiaoHufaDieShow:StartDead(anim)
    self:ShowDeath(anim)
end

function ZhangjiaoHufaDieShow:StayUpdate(deltaTime)
    self.m_deadTime = self.m_deadTime - deltaTime
    if self.m_deadTime <= 0 then
        self.m_alphaTime = self.m_alphaTime - deltaTime

        if not self.m_isTweenAlpha then
            self.m_isTweenAlpha = true
            local actorColor = self.m_fakeActor:GetActorColor()
            if actorColor then
                local alpha = actorColor:GetActorAlpha()
                if alpha > 0 then
                    actorColor:AddAlphaFactor(0, self.m_alphaTweenTime, self.m_alphaTweenTime)
                end
            end
        end

        if self.m_alphaTime <= 0 then
            self.m_fakeActor:SetPosition(FixNewVector3(0,-100,0))
            self.m_isOver = true
        end
    end
end

return ZhangjiaoHufaDieShow