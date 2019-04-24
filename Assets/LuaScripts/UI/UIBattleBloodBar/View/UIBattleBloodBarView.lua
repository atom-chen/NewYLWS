local table_insert = table.insert
local IsNull = IsNull
local UIUtil = UIUtil
local Vector3 = Vector3
local Time = Time
local BattleEnum = BattleEnum
local GameUtility = CS.GameUtility
local BloodBarItemClass = require("UI.UIBattleBloodBar.BattleBloodBarItem")
local UIBattleBloodBarView = BaseClass("UIBattleBloodBarView", UIBaseView)
local base = UIBaseView
local ActorManagerInst = ActorManagerInst

local PlayerBloodBarPrefabPath = "UI/Prefabs/Battle/BloodBarItemPlayer.prefab"
local MonsterBloodBarPrefabPath = "UI/Prefabs/Battle/BloodBarItemMonster.prefab"

function UIBattleBloodBarView:OnCreate()
	base.OnCreate(self)

    self.m_dic = {}
    self.m_loadingDic = {}

    ActorManagerInst:Walk(
        function(tmpTarget)
            self:OnActorCreate(tmpTarget:GetActorID())
        end
    )
end

function UIBattleBloodBarView:OnDestroy()
	base.OnDestroy(self)

    for _,bloodBar in pairs(self.m_dic) do
        if bloodBar then
            bloodBar:Delete()
        end
    end
    self.m_dic = false
    self.m_loadingDic = false
end

function UIBattleBloodBarView:Update()
    local deltaTime = Time.deltaTime
    for _,bloodBar in pairs(self.m_dic) do
        if bloodBar then
            bloodBar:UpdateData(deltaTime)
        end
    end
end

function UIBattleBloodBarView:OnAddListener()
    base.OnAddListener(self)
    self:AddUIListener(UIMessageNames.UIBATTLE_ACTOR_CREATE, self.OnActorCreate)
    self:AddUIListener(UIMessageNames.UIBATTLE_ACTOR_DIE, self.OnActorDie)
    self:AddUIListener(UIMessageNames.UIBATTLE_SHOW_BLOOD_BAR, self.ShowBloodBar)
    self:AddUIListener(UIMessageNames.UIBATTLE_HP_CHANGE, self.OnHPChange)
    self:AddUIListener(UIMessageNames.UIBATTLE_ACTOR_BE_CONTROL, self.OnControl)
end

function UIBattleBloodBarView:OnRemoveListener()
    base.OnRemoveListener(self)
    self:RemoveUIListener(UIMessageNames.UIBATTLE_ACTOR_CREATE, self.OnActorCreate)
    self:RemoveUIListener(UIMessageNames.UIBATTLE_ACTOR_DIE, self.OnActorDie)
    self:RemoveUIListener(UIMessageNames.UIBATTLE_SHOW_BLOOD_BAR, self.ShowBloodBar)
    self:RemoveUIListener(UIMessageNames.UIBATTLE_HP_CHANGE, self.OnHPChange)
    self:RemoveUIListener(UIMessageNames.UIBATTLE_ACTOR_BE_CONTROL, self.OnControl)
end

function UIBattleBloodBarView:OnActorCreate(actorID)
    if self.m_dic[actorID] or self.m_loadingDic[actorID] then
        return
    end

    local actor = ActorManagerInst:GetActor(actorID)
    if not actor then
       return 
    end
    
    self.m_loadingDic[actorID] = true
    local bloodBarPrefabPath = self:GetBloodBarPrefabPath(actor)
	GameObjectPoolInst:GetGameObjectAsync(bloodBarPrefabPath, function(inst)
        local bloodBar = BloodBarItemClass.New(inst, self.transform)
        self.m_dic[actorID] = bloodBar
        bloodBar:OnCreate(actorID, bloodBarPrefabPath, self.rectTransform)
        self.m_loadingDic[actorID] = false
        -- GameUtility.RecursiveSetLayer(inst, Layers.BATTLE_BLOOD)
    end)
end

function UIBattleBloodBarView:GetBloodBarPrefabPath(actor)
    if actor:GetCamp() == BattleEnum.ActorCamp_RIGHT then
        return MonsterBloodBarPrefabPath
    elseif actor:GetCamp() == BattleEnum.ActorCamp_LEFT then
        return PlayerBloodBarPrefabPath
    end
end

function UIBattleBloodBarView:OnActorDie(actorID)
    local bloodBarItem = self.m_dic[actorID]
    if bloodBarItem then
        bloodBarItem:Delete()
        self.m_dic[actorID] = nil
    end
end

function UIBattleBloodBarView:ShowBloodBar(actorID, isShow)
    local bloodBarItem = self.m_dic[actorID]
    if bloodBarItem then
        if isShow then
            bloodBarItem:ShowBloodUI()
        else
            bloodBarItem:HideBloodUI()
        end
    end
end

function UIBattleBloodBarView:OnHPChange(actorID, hpChgVal)
    local bloodBarItem = self.m_dic[actorID]
    if bloodBarItem then
        bloodBarItem:UpdateBloodBar(hpChgVal)
    end
end

function UIBattleBloodBarView:OnControl(actorID, controlMSTime)
    local bloodBarItem = self.m_dic[actorID]
    if bloodBarItem then
        bloodBarItem:OnControl(controlMSTime)
    end
end

return UIBattleBloodBarView

