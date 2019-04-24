
local UIFightWarView = BaseClass("UIFightWarView", UIBaseView)
local base = UIBaseView
local GuildBossMgr = Player:GetInstance():GetGuildBossMgr()
local BossMgr = Player:GetInstance():GetBossMgr()
local DOTweenSettings = CS.DOTween.DOTweenSettings
local table_findIndex = table.findIndex

local FightWarItem = require "UI.FightWar.FightWarItem"
local table_insert = table.insert
local BattleEnum = BattleEnum
local GameObject = CS.UnityEngine.GameObject
local DOTween = CS.DOTween.DOTween
local SpringContent = CS.SpringContent
local GuideEnum = GuideEnum

local FIGHT_TYPE = {
 --[[    BattleEnum.BattleType_GRAVE, 
    BattleEnum.BattleType_YUANMEN,
    BattleEnum.BattleType_SHENSHOU,
    BattleEnum.BattleType_CAMPSRUSH,
    BattleEnum.BattleType_INSCRIPTION,
    BattleEnum.BattleType_BOSS1,
    BattleEnum.BattleType_HUARONG_ROAD,
    BattleEnum.BattleType_ARENA,
    BattleEnum.BattleType_SHENBING,
    BattleEnum.BattleType_THOUSAND_MILES,
    BattleEnum.BattleType_LIEZHUAN,
    BattleEnum.BattleType_QUNXIONGZHULU, ]]

    BattleEnum.BattleType_LIEZHUAN,
    BattleEnum.BattleType_INSCRIPTION,
    BattleEnum.BattleType_GRAVE,
    BattleEnum.BattleType_SHENBING,
    BattleEnum.BattleType_ARENA,
    BattleEnum.BattleType_YUANMEN,
    BattleEnum.BattleType_SHENSHOU,    
    BattleEnum.BattleType_HORSERACE,
    BattleEnum.BattleType_BOSS1,
    BattleEnum.BattleType_QUNXIONGZHULU,
    BattleEnum.BattleType_CAMPSRUSH,
    BattleEnum.BattleType_GUILD_BOSS,
    BattleEnum.BattleType_GUILD_WARCRAFT,
}



function UIFightWarView:OnCreate()
    base.OnCreate(self)

    self.m_fightWarItemList = {}

    self.m_canMoveItemContent = false
    self.m_updatePanelEnd = false
    self.m_tweenOpenEnd = false

    self.m_checkUpdate = false
    self.m_updateObj = nil
    self:InitView()
end

function UIFightWarView:InitView()
    self.m_fightWarItemPrefab, self.m_backBtn, self.m_itemContentTran, self.m_titleContainer, 
    self.m_container = UIUtil.GetChildRectTrans(self.transform, {
        "FightWarItemPrefab",
        "Panel/BackBtn",
        "Panel/Container/ItemScrollView/Viewport/ItemContent", 
        "Panel/titleContainer",
        "Panel/Container",
    })

    local titleText = UIUtil.FindText(self.transform, "Panel/titleContainer/TitleText")
    titleText.text = Language.GetString(1700)
    
    self.m_fightWarItemPrefab = self.m_fightWarItemPrefab.gameObject

    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_backBtn.gameObject, onClick) 
    
end

function UIFightWarView:OnClick(go, x, y)
    if go.name == "BackBtn" then
        self:CloseSelf()
    elseif go.name == "RuleBtn" then

    end
end


function UIFightWarView:OnEnable(...)
    base.OnEnable(self, ...)

    -- if GuideMgr:GetInstance():IsPlayingGuide(GuideEnum.GUIDE_ARENA1) then
    --     self.m_canMoveItemContent = true
    -- end

    self.m_itemContentTran.anchoredPosition = Vector2.zero 
    Player:GetInstance():GetUserMgr():ReqFightWarData()
   
    self:TweenOpen()
end

function UIFightWarView:UpdateView(act_copy_list)
    if not act_copy_list then
        return
    end

    -- print("act_copy_list ", tostring(act_copy_list))

    for i, v in ipairs(FIGHT_TYPE) do
        local fightWarItem = self.m_fightWarItemList[i]
        if fightWarItem == nil then
            local go = GameObject.Instantiate(self.m_fightWarItemPrefab)
            fightWarItem = FightWarItem.New(go, self.m_itemContentTran)
            table_insert(self.m_fightWarItemList, fightWarItem)
        end

        local findIndex = table_findIndex(act_copy_list, function(act_copy)
            return act_copy.battle_type == v
        end)

        -- print("findIndex :", findIndex, v)
    
        if findIndex > 0 then
            fightWarItem:UpdateData(i, act_copy_list[findIndex])
        end
    end

    if self.m_canMoveItemContent then
        self.m_canMoveItemContent = false
        self.m_springContent = SpringContent.Begin(self.m_itemContentTran.gameObject, Vector3.New(0, 674.6, 0), 8, function()
            self:DelayTriggerEvent()
        end)
    else
        self:DelayTriggerEvent()
    end 
end

function UIFightWarView:DelayTriggerEvent()
    coroutine.start(function()
        coroutine.waitforframes(3)
        self.m_updatePanelEnd = true
        self:CheckUIShowEnd()
    end)
end

function UIFightWarView:OnDisable()
    self.m_updatePanelEnd = false
    self.m_tweenOpenEnd = false
    self.m_checkUpdate = false
    self.m_updateObj = nil
    base.OnDisable(self)
end

function UIFightWarView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject) 

    for i, v in ipairs(self.m_fightWarItemList) do 
        v:Delete()
    end
    self.m_fightWarItemList = nil
    
    self.m_springContent = nil
    self.m_updateObj = nil
    base.OnDestroy(self)
end


function UIFightWarView:OnAddListener()
	base.OnAddListener(self)
	-- UI消息注册
    self:AddUIListener(UIMessageNames.MN_FIGHTWAR_INFO, self.UpdateView)
    self:AddUIListener(UIMessageNames.MN_FIGHTWAR_UPDATE_LEFT_TIME, self.OnUpdateLeftTime)
end

function UIFightWarView:OnRemoveListener()
	base.OnRemoveListener(self)
	-- UI消息注销
    self:RemoveUIListener(UIMessageNames.MN_FIGHTWAR_INFO, self.UpdateView)
    self:RemoveUIListener(UIMessageNames.MN_FIGHTWAR_UPDATE_LEFT_TIME, self.OnUpdateLeftTime)
    
end


function UIFightWarView:EnterGuildBossFight(go)
	UIManagerInst:OpenWindow(UIWindowNames.UIGuildBoss, go)
end

function UIFightWarView:TweenOpen()
    local tweener = DOTween.ToFloatValue(function()
        return 0
    end, 
    function(value)
        self.m_backBtn.anchoredPosition = Vector3.New(236, -46.5 + 150 - 150 * value, 0)
        self.m_titleContainer.anchoredPosition = Vector3.New(0, 270 - 270 * value, 0)
        self.m_container.anchoredPosition = Vector3.New(0, -500 + 500 * value, 0)
    end, 1, 0.3)

    DOTweenSettings.OnComplete(tweener, function()
        self.m_tweenOpenEnd = true
        self:CheckUIShowEnd()
    end)
end

function UIFightWarView:CheckUIShowEnd()
    if self.m_tweenOpenEnd and self.m_updatePanelEnd then
        TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.SHOW_UI_END, self.winName)
    end
end

function UIFightWarView:OnUpdateLeftTime(flag, obj)
    self.m_checkUpdate = flag
    self.m_updateObj = obj
end

function UIFightWarView:Update()
    if self.m_checkUpdate and self.m_updateObj then
        self.m_updateObj:UpdateLeftTimes(Time.deltaTime)
    end
end

return UIFightWarView