local UIBattleRecordView = BaseClass("UIBattleRecordView", UIBaseView)
local base = UIBaseView
local UIUtil = UIUtil
local table_insert = table.insert
local table_sort = table.sort
local userMgr = Player:GetInstance():GetUserMgr()
local arenaMgr = Player:GetInstance():GetArenaMgr()
local UIGameObjectLoader = UIGameObjectLoader
local CtlBattleInst = CtlBattleInst
local BattleEnum = BattleEnum

local UIBattleRecordItem = require "UI.UIBattleRecord.View.UIBattleRecordItem"
local UIBattleRecordLeftItemPrefabPath = TheGameIds.BattleRecordLeftItemPrefab
local UIBattleRecordRightItemPrefabPath = TheGameIds.BattleRecordRightItemPrefab

function UIBattleRecordView:OnCreate()
    base.OnCreate(self)
    
    self:InitView()
end

function UIBattleRecordView:InitView()
    self.m_closeBtnTrans = UIUtil.GetChildTransforms(self.transform, {
        "close_BTN",
    })

    self.m_leftItemContentTr, self.m_rightItemContentTr = 
    UIUtil.GetChildTransforms(self.transform, {
        "wujiangContainer/leftItemScrollView/Viewport/ItemContent",
        "wujiangContainer/rightItemScrollView/Viewport/ItemContent",
    })

    self.m_leftNameText, self.m_rightNameText, self.m_hurtText, self.m_beHurtText, self.m_recoverText = 
    UIUtil.GetChildTexts(self.transform, {
        "titleImage/leftName",
        "titleImage/rightName",
        "middleContainer/hurtImage/hurtText",
        "middleContainer/beHurtImage/beHurtText",
        "middleContainer/recoverImage/recoverText",
    })

    self.m_rightScrollView = self:AddComponent(LoopScrowView, "wujiangContainer/rightItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateRightDataTaskItem), false)

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_closeBtnTrans.gameObject, onClick)

    self.m_leftItemSeq = 0
    self.m_leftRecordList = {}
    self.m_rightRecordList = {}
    self.m_rightRecordInfoList = {}

    self.m_hurtText.text = Language.GetString(2438)
    self.m_beHurtText.text = Language.GetString(2439) 
    self.m_recoverText.text = Language.GetString(2440) 
end

function UIBattleRecordView:OnEnable(...)
    base.OnEnable(self)
    
    local order, msgObj = ...

    self:OnRelease()

    self.m_leftRecordList = {}

    local battleLogic = CtlBattleInst:GetLogic()

    local battleType = battleLogic:GetBattleType()
    local damageRecorder = battleLogic:GetDamageRecorder()
    local maxDamagedata = damageRecorder:GetMaxValDamagedata()

    damageRecorder:WalkLeftCamp(function(damageData)
        if damageData then
            self.m_leftItemSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
            UIGameObjectLoader:GetInstance():GetGameObject(self.m_leftItemSeq, UIBattleRecordLeftItemPrefabPath, 
                function(go)
                    if IsNull(go) then
                        return
                    end

                    local battleRecordItem = UIBattleRecordItem.New(go, self.m_leftItemContentTr, UIBattleRecordLeftItemPrefabPath)

                    local wujiangLevel = damageData:GetLevel()
                    local wujiangID = damageData:GetWuJiangID()
                    
                    if msgObj then
                        local wujiangList = msgObj.wujiang_exp_list
                        if wujiangList and #wujiangList > 0 then
                            for i=1, #wujiangList do
                                if wujiangID == wujiangList[i].wujiang_id then
                                    wujiangLevel = wujiangList[i].level 
                                end
                            end
                        end
                    end

                    battleRecordItem:UpdateData(damageData:GetHurt(), damageData:GetDropHP(), damageData:GetAddHP(), damageData:GetKillCount(), damageData:GetIsBoss(), damageData:GetActorID(), wujiangID, wujiangLevel, maxDamagedata)
                    
                    table_insert(self.m_leftRecordList, battleRecordItem)
                end
            )
            self:SortLeftWujiangItem()
        end
    end)

    self.m_leftNameText.text = userMgr:GetUserData().name
    if battleType == BattleEnum.BattleType_ARENA or battleType == BattleEnum.BattleType_FRIEND_CHALLENGE or battleType == BattleEnum.BattleType_QUNXIONGZHULU  then
        self.m_rightNameText.text = CtlBattleInst:GetLogic():GetBattleParam().rightCampList[1].name
    end

    --因为我们没有做罐子和盗墓贼的头像，摸金副本的战损界面不显示敌人信息，直接隐藏即可
    local battleType = battleLogic:GetBattleType()
    if battleType ~= BattleEnum.BattleType_GRAVE then
        self.m_rightRecordInfoList = {}
        local queShenList = {}
        damageRecorder:WalkRightCamp(function(damageData)
            if damageData then
                local wujiangLevel = damageData:GetLevel()
                local wujiangID = damageData:GetWuJiangID()
    
                local recordInfo = { 
                    hurt = damageData:GetHurt(), 
                    dropHP = damageData:GetDropHP(), 
                    addHP = damageData:GetAddHP(), 
                    killCount = damageData:GetKillCount(),
                    isBoss = damageData:GetIsBoss(), 
                    actorID = damageData:GetActorID(), 
                    wujiangID = wujiangID, 
                    wujiangLevel = wujiangLevel, 
                    maxDamagedata = maxDamagedata,
                }
    
                if damageData:GetIsBoss() then
                    local wujiangCfg = ConfigUtil.GetWujiangCfgByID(wujiangID)
                    if wujiangCfg then
                        self.m_rightNameText.text = wujiangCfg.sName
                    end
                end
                    
                if battleType == BattleEnum.BattleType_INSCRIPTION and wujiangID == 4050 then
                    local monsterId = damageData:GetMonsterID()
                    local queShenInfo = queShenList[monsterId]
                    if queShenInfo then
                        queShenInfo.hurt = queShenInfo.hurt + recordInfo.hurt
                        queShenInfo.dropHP = queShenInfo.dropHP + recordInfo.dropHP
                        queShenInfo.addHP = queShenInfo.addHP + recordInfo.addHP
                        queShenInfo.killCount = queShenInfo.killCount + recordInfo.killCount
                    else
                        queShenList[monsterId] = recordInfo
                    end
                else
                    table_insert(self.m_rightRecordInfoList, recordInfo)
                end
            end
        end)

        if battleType == BattleEnum.BattleType_INSCRIPTION then
            for _,v in pairs(queShenList) do
                table_insert(self.m_rightRecordInfoList, v)
            end
        end

        self:SortRightWujiangData()

        local rightCount = #self.m_rightRecordList
        if rightCount > 0 then
            self.m_rightScrollView:UpdateView(false, self.m_rightRecordList, self.m_rightRecordInfoList)
        else
            local seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
            UIGameObjectLoader:GetInstance():GetGameObjects(seq, UIBattleRecordRightItemPrefabPath, 8, function(objs)
                seq = 0
                if objs then
                    for i = 1, #objs do
                        local battleRecordItem = UIBattleRecordItem.New(objs[i], self.m_rightItemContentTr, UIBattleRecordRightItemPrefabPath)
                        table_insert(self.m_rightRecordList, battleRecordItem)
                        self.m_rightScrollView:UpdateView(true, self.m_rightRecordList, self.m_rightRecordInfoList)
                    end
                end
            end)
        end
    end
end

function UIBattleRecordView:SortRightWujiangData()
    table_sort(self.m_rightRecordInfoList, function(itemA, itemB)
        local isADragon = Utils.IsDragon(itemA.wujiangID)
        local isBDragon = Utils.IsDragon(itemB.wujiangID)
        if itemA.isBoss and not itemB.isBoss then
            return true
        elseif itemB.isBoss and not itemA.isBoss then
            return false
        elseif isADragon and not isBDragon then
            return false
        elseif isBDragon and not isADragon then
            return true
        else
            return itemA.actorID < itemB.actorID
        end
	end)
	for i,item in pairs(self.m_leftRecordList) do
		if item then
			item:SetSiblingIndex(i)
		end
	end
end

function UIBattleRecordView:OnDisable()
    self:OnRelease()

    if #self.m_rightRecordList > 0 then
        for k,v in pairs(self.m_rightRecordList) do
            v:Delete()
        end
        self.m_rightRecordList = {}
    end

    self.m_rightRecordInfoList = {}

	base.OnDisable(self)
end

function UIBattleRecordView:OnRelease()
    if self.m_leftItemSeq > 0 then
        UIGameObjectLoader:GetInstance():CancelLoad(self.m_leftItemSeq)
        self.m_leftItemSeq = 0
    end 

    if #self.m_leftRecordList > 0 then
        for k,v in pairs(self.m_leftRecordList) do
            v:Delete()
        end
        self.m_leftRecordList = {}
    end
end

function UIBattleRecordView:SortLeftWujiangItem()
    table_sort(self.m_leftRecordList, function(itemA, itemB)
        local isADragon = Utils.IsDragon(itemA:GetWujiangID())
        local isBDragon = Utils.IsDragon(itemB:GetWujiangID())
        if isADragon and not isBDragon then
            return false
        elseif isBDragon and not isADragon then
            return true
        else
            return itemA:GetActorID() < itemB:GetActorID()
        end
	end)
	for i,item in pairs(self.m_leftRecordList) do
		if item then
			item:SetSiblingIndex(i)
		end
	end
end

function UIBattleRecordView:UpdateRightDataTaskItem(item, realIndex)
    if self.m_rightRecordInfoList then
        if item and realIndex > 0 and realIndex <= #self.m_rightRecordInfoList then
            local data = self.m_rightRecordInfoList[realIndex]
            item:UpdateData(data.hurt, data.dropHP, data.addHP, data.killCount, data.isBoss, data.actorID, data.wujiangID, data.wujiangLevel, data.maxDamagedata)
        end
    end
end

function UIBattleRecordView:OnClick(go, x, y)
    UIManagerInst:Broadcast(UIMessageNames.MN_BATTLE_SETTLEMENT_OPEN)
    UIManagerInst:CloseWindow(UIWindowNames.BattleRecord)
end

function UIBattleRecordView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_closeBtnTrans.gameObject)

    base.OnDestroy(self)
end

return UIBattleRecordView