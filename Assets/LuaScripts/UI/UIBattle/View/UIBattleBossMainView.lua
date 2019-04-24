local UIUtil = UIUtil
local UIBattleMainView = require("UI.UIBattle.View.UIBattleMainView")
local UIBattleBossMainView = BaseClass("UIBattleBossMainView", UIBattleMainView)
local base = UIBattleMainView
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local BattleEnum = BattleEnum

local UISliderHelper = typeof(CS.UISliderHelper)
local Type_RectTransform = typeof(CS.UnityEngine.RectTransform)

local blood_slider_path = "topMiddleContainer/bossBlood/bloodSlider"
local boss_name_path = "topMiddleContainer/bossBlood/name"
local boss_blood_percent_path = "topMiddleContainer/bossBlood/bloodPercent"
local boss_img_path = "topMiddleContainer/bossBlood/bloodSlider/bloodSpt"

function UIBattleBossMainView:OnEnable(...)
    base.OnEnable(self,...)
    local t1, bossName = ...
    self.m_bossNameLabel.text = bossName
    
    local battleType = CtlBattleInst:GetLogic():GetBattleType()
    if battleType == BattleEnum.BattleType_GUILD_BOSS then
        self.m_bossBloodPercentTr.gameObject:SetActive(true)
        self.back_btn.gameObject:SetActive(false)
    else
        self.back_btn.gameObject:SetActive(true)
        self.m_bossBloodPercentTr.gameObject:SetActive(false)
    end
    self.m_bossBloodTr.gameObject:SetActive(true)
end

function UIBattleBossMainView:OnCreate()
	base.OnCreate(self)

    self.m_bloodSlider = UIUtil.FindComponent(self.transform, UISliderHelper, blood_slider_path)
    self.m_bossNameRT = UIUtil.FindComponent(self.transform, UISliderHelper, boss_name_path)
    self.m_bloodPercentRT = UIUtil.FindComponent(self.transform, UISliderHelper, boss_blood_percent_path)
    self.m_bloodImg = UIUtil.AddComponent(UIImage, self, boss_img_path)
    
    self.m_bossNameLabel, self.m_bossBloodPercentLabel = UIUtil.GetChildTexts(self.transform, {
        boss_name_path, boss_blood_percent_path,
    })

    self.m_bossBloodPercentTr = UIUtil.FindTrans(self.transform, boss_blood_percent_path)

    self.m_lastHP = 0
    self.m_bossBloodPercentLabel.text = "100%"

    self.m_bossID = CtlBattleInst:GetLogic():GetBossID()

    self.m_bloodSlider:UpdateSliderImmediately(1)

    self.m_bossBloodTr = UIUtil.FindTrans(self.transform, "topMiddleContainer/bossBlood")
end

function UIBattleBossMainView:OnDestroy()
    self.m_bloodSlider:Dispose()
    self.m_bloodSlider = false
    self.m_bossNameLabel = false
    self.m_bossNameRT = false
    self.m_bloodPercentRT = false
    self.m_bossID = 0
    self.m_bossBloodPercentLabel = false
    self.m_lastHP = nil

	base.OnDestroy(self)
end

function UIBattleBossMainView:Update()
    self:UpdateBloodPercent()
    base.Update(self)
end

function UIBattleBossMainView:GetBackLanguage()
    local battleType = CtlBattleInst:GetLogic():GetBattleType() 
    if battleType == BattleEnum.BattleType_SHENSHOU  then
        return Language.GetString(3708)
    elseif battleType == BattleEnum.BattleType_GUILD_BOSS or battleType == BattleEnum.BattleType_BOSS1 or battleType == BattleEnum.BattleType_BOSS2 then
        return Language.GetString(2464)
    else
        return Language.GetString(6)
    end
end

function UIBattleBossMainView:UpdateBloodPercent()
    local btLogic = CtlBattleInst:GetLogic()
    if not btLogic then
        return
    end

    if self.m_bossID == 0 then
        self.m_bossID = btLogic:GetBossID()
    end
    local actor = ActorManagerInst:GetActor(self.m_bossID)
    if not actor then
        self.m_bloodImg:SetFillAmount(0)
        self.m_bloodSlider:UpdateSliderImmediately(0)
        return 
    end

    local actorData = actor:GetData()
    if not actorData then
        return
    end

    local curHP = actorData:GetAttrValue(ACTOR_ATTR.FIGHT_HP)
    local maxHP = actorData:GetAttrValue(ACTOR_ATTR.FIGHT_MAXHP)
    local newPercent = curHP / maxHP

    self.m_bloodImg:SetFillAmount(newPercent)

    local hpChg = curHP - self.m_lastHP
    if hpChg >= 0 or newPercent > self.m_bloodSlider:GetSliderValue() then
        self.m_bloodSlider:UpdateSliderImmediately(newPercent)
    else
        local time = (-hpChg) / maxHP * 8
        time = time > 1.5 and 1.5 or time
        newPercent = newPercent < 0.02 and 0.02 or newPercent
        self.m_bloodSlider:TweenUpdateSlider(newPercent, time)
    end
    self.m_lastHP = curHP
    newPercent = newPercent * 100

    newPercent = string.format("%.2f", newPercent) .. "%"
    self.m_bossBloodPercentLabel.text = newPercent
end

function UIBattleBossMainView:OnActorDie(actorID)
    base.OnActorDie(self, actorID)

    if actorID == self.m_bossID then
        if CtlBattleInst:GetLogic():GetBattleType() == BattleEnum.BattleType_GUILD_BOSS then
            self.m_bossBloodTr.gameObject:SetActive(false)
        else
            self.m_bloodSlider:UpdateSliderImmediately(0)
    
            local newPercent = "0%"
            self.m_bossBloodPercentLabel.text = newPercent
		end
    end
end
return UIBattleBossMainView

