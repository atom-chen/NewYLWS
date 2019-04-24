local table_insert = table.insert
local IsNull = IsNull
local UIUtil = UIUtil
local Vector3 = Vector3
local Time = Time
local GameUtility = CS.GameUtility
local ActorManagerInst = ActorManagerInst
local BattleContinueGuideItemClass = require("UI.UIContinueGuide.BattleContinueGuideItem")
local UIBattleContinueGuideView = BaseClass("UIBattleContinueGuideView", UIBaseView)
local base = UIBaseView

local BattleContinueGuideItemPrefabPath = "UI/Prefabs/Battle/BattleContinueGuideItem.prefab"

function UIBattleContinueGuideView:OnCreate()
	base.OnCreate(self)

    self.m_dic = {}
    self.m_loadingDic = {}
end

function UIBattleContinueGuideView:OnDestroy()
	base.OnDestroy(self)

    for _,guideItem in pairs(self.m_dic) do
        if guideItem then
            guideItem:Delete()
        end
    end
    self.m_dic = nil
    self.m_loadingDic = nil
end

function UIBattleContinueGuideView:Update()
    local deltaTime = Time.deltaTime
    for actorID,guideItem in pairs(self.m_dic) do
        if guideItem then
            local target = ActorManagerInst:GetActor(actorID)
            if target and target:IsLive() and target:IsPause() then
                guideItem:RefreshPosition()
            else
                local isGuide = guideItem:UpdateData(deltaTime)
                if not isGuide then
                    self:GuideOver(actorID)
                end
            end
        end
    end
end

function UIBattleContinueGuideView:OnAddListener()
    base.OnAddListener(self)
    self:AddUIListener(UIMessageNames.UIBATTLE_ACTOR_DIE, self.OnActorDie)
    self:AddUIListener(UIMessageNames.UIBATTLE_ACTOR_GUIDE, self.OnContinueGuide)
    self:AddUIListener(UIMessageNames.UIBATTLE_ACTOR_BE_CONTROL, self.OnControl)
    self:AddUIListener(UIMessageNames.UIBATTLE_ACTOR_INTERRUPT_GUIDE, self.OnInterruptGuide)
end

function UIBattleContinueGuideView:OnRemoveListener()
    base.OnRemoveListener(self)
    self:RemoveUIListener(UIMessageNames.UIBATTLE_ACTOR_DIE, self.OnActorDie)
    self:RemoveUIListener(UIMessageNames.UIBATTLE_ACTOR_GUIDE, self.OnContinueGuide)
    self:RemoveUIListener(UIMessageNames.UIBATTLE_ACTOR_BE_CONTROL, self.OnControl)
    self:RemoveUIListener(UIMessageNames.UIBATTLE_ACTOR_INTERRUPT_GUIDE, self.OnInterruptGuide)
end

function UIBattleContinueGuideView:OnContinueGuide(actorID, guideTime)
    if self.m_dic[actorID] or self.m_loadingDic[actorID] then
        return
    end

    local actor = ActorManagerInst:GetActor(actorID)
    if not actor then
       return 
    end
    
    self.m_loadingDic[actorID] = true
	GameObjectPoolInst:GetGameObjectAsync(BattleContinueGuideItemPrefabPath, function(inst)
        local guideBar = BattleContinueGuideItemClass.New(inst, self.transform)
        self.m_dic[actorID] = guideBar
        guideBar:OnCreate(actorID, BattleContinueGuideItemPrefabPath, self.rectTransform, guideTime)
        self.m_loadingDic[actorID] = false
        -- GameUtility.RecursiveSetLayer(inst, Layers.BATTLE_BLOOD)
    end)
end

function UIBattleContinueGuideView:OnActorDie(actorID)
    self:GuideOver(actorID)
end

function UIBattleContinueGuideView:OnControl(actorID)
    self:GuideOver(actorID)
end

function UIBattleContinueGuideView:OnInterruptGuide(actorID)
    self:GuideOver(actorID)
end

function UIBattleContinueGuideView:GuideOver(actorID)
    local guideItem = self.m_dic[actorID]
    if guideItem then
        guideItem:Delete()
        self.m_dic[actorID] = nil
    end
end

return UIBattleContinueGuideView

