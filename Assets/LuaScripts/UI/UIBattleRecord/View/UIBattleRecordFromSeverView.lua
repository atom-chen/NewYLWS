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

local BattleDamageData = require "GameLogic.Battle.BattleDamageData"
local UIBattleRecordFromSeverView = BaseClass("UIBattleRecordFromSeverView", UIBaseView)
local base = UIBaseView

function UIBattleRecordFromSeverView:OnCreate()
    base.OnCreate(self)
    
    self:InitView()
end

function UIBattleRecordFromSeverView:InitView()
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
    self.m_leftRecordInfoList = {}

    self.m_hurtText.text = Language.GetString(2438)
    self.m_beHurtText.text = Language.GetString(2439) 
    self.m_recoverText.text = Language.GetString(2440) 
end

function UIBattleRecordFromSeverView:OnEnable(...)
    base.OnEnable(self)
    
    local order, msgObj = ...

    self:OnRelease()    

    local battleLogic = CtlBattleInst:GetLogic()
    local battleType = battleLogic:GetBattleType()
    
    local battleParam = battleLogic:GetBattleParam()

    if not battleParam or not battleParam.resultInfo or not battleParam.resultInfo.left_result or not battleParam.resultInfo.right_result then
        return
    end

    local leftWujiangResultList = battleParam.resultInfo.left_result.wujiang_result_list
    local rightWujiangResultList = battleParam.resultInfo.right_result.wujiang_result_list

    for _, one_wujiang_result in ipairs(leftWujiangResultList) do
        local damageData = self:ConvertDamageData(one_wujiang_result)
        if damageData then
            table_insert(self.m_leftRecordInfoList, damageData)
            self.m_leftItemSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        end
    end

    for _, one_wujiang_result in ipairs(rightWujiangResultList) do
        local damageData = self:ConvertDamageData(one_wujiang_result)
        if damageData then
            table_insert(self.m_rightRecordInfoList, damageData)
        end
    end

    self.m_maxDamagedata = BattleDamageData.New(1, 1)
    maxDamagedata = self:GetMaxVal(self.m_maxDamagedata, self.m_leftRecordInfoList)
    maxDamagedata = self:GetMaxVal(self.m_maxDamagedata, self.m_rightRecordInfoList)

    if battleParam.leftCamp then
        self.m_leftNameText.text = battleParam.leftCamp.name
    end

    if battleParam.rightCampList and #battleParam.rightCampList > 0 then
        self.m_rightNameText.text = battleParam.rightCampList[1].name
    end

    self:UpdateLeftWujiangShow()
    self:UpdateRightWujiangShow()
end

function UIBattleRecordFromSeverView:UpdateLeftWujiangShow()
    if #self.m_leftRecordList > 0 then
        return
    end

    for _, damageData in ipairs(self.m_leftRecordInfoList) do
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
    
            battleRecordItem:UpdateData(damageData:GetHurt(), damageData:GetDropHP(), damageData:GetAddHP(), damageData:GetKillCount(), damageData:GetIsBoss(), damageData:GetActorID(), wujiangID, wujiangLevel, self.m_maxDamagedata)
            
            table_insert(self.m_leftRecordList, battleRecordItem)
        end)
    end
    self:SortLeftWujiangItem()
end

function UIBattleRecordFromSeverView:UpdateRightWujiangShow()
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

function UIBattleRecordFromSeverView:ConvertDamageData(one_wujiang_result)
    if one_wujiang_result and one_wujiang_result.actor_id then
        local damageData = BattleDamageData.New(one_wujiang_result.actor_id, 0)
        damageData:SetWuJiangID(one_wujiang_result.wujiang_id)
        damageData:SetMonsterID(one_wujiang_result.monster_id)
        damageData:ChgHurt(one_wujiang_result.hurt_hp)
        damageData:ChgDropHP(one_wujiang_result.drop_hp)
        damageData:ChgAddHP(one_wujiang_result.add_hp)
        damageData:ChgKillCount(one_wujiang_result.kill_count)
        --damageData:SetWujiangPos(pos.x,pos.y,pos.z)
        damageData:SetLeftNuqi(one_wujiang_result.nuqi)
        damageData:SetLeftHP(one_wujiang_result.hp)
        damageData:SetWujiangSeq(one_wujiang_result.seq)
        damageData:SetMaxHP(one_wujiang_result.max_hp)
        damageData:SetLevel(one_wujiang_result.wujiang_level)
        return damageData
    end    
end

function UIBattleRecordFromSeverView:GetMaxVal(damageData, campDic)
    if campDic then
        for _,v in pairs(campDic) do
            local data = v
            if data then
                if data:GetAddHP() > damageData:GetAddHP() then
                    damageData:ChgAddHP(data:GetAddHP() - damageData:GetAddHP())
                end
                if data:GetHurt() > damageData:GetHurt() then
                    damageData:ChgHurt(data:GetHurt() - damageData:GetHurt())
                end
                if data:GetDropHP() > damageData:GetDropHP() then
                    damageData:ChgDropHP(data:GetDropHP() - damageData:GetDropHP())
                end
            end
        end
    end
    return damageData
end

function UIBattleRecordFromSeverView:SortRightWujiangData()
    table_sort(self.m_rightRecordInfoList, function(itemA, itemB)
        local isADragon = Utils.IsDragon(itemA:GetWuJiangID())
        local isBDragon = Utils.IsDragon(itemB:GetWuJiangID())
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

function UIBattleRecordFromSeverView:OnDisable()
    self:OnRelease()

    if #self.m_rightRecordList > 0 then
        for k,v in pairs(self.m_rightRecordList) do
            v:Delete()
        end
        self.m_rightRecordList = {}
    end

    if #self.m_leftRecordList > 0 then
        for k,v in pairs(self.m_leftRecordList) do
            v:Delete()
        end
        self.m_leftRecordList = {}
    end

    self.m_leftRecordInfoList = {}
    self.m_rightRecordInfoList = {}
	base.OnDisable(self)
end

function UIBattleRecordFromSeverView:OnRelease()
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

function UIBattleRecordFromSeverView:SortLeftWujiangItem()
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

function UIBattleRecordFromSeverView:UpdateRightDataTaskItem(item, realIndex)
    if self.m_rightRecordInfoList then
        if item and realIndex > 0 and realIndex <= #self.m_rightRecordInfoList then
            local damageData = self.m_rightRecordInfoList[realIndex]
            item:UpdateData(damageData:GetHurt(), damageData:GetDropHP(), damageData:GetAddHP(), damageData:GetKillCount(), damageData:GetIsBoss(), damageData:GetActorID(), damageData:GetWuJiangID(), damageData:GetLevel(), maxDamagedata)
        end
    end
end

function UIBattleRecordFromSeverView:OnClick(go, x, y)
    UIManagerInst:Broadcast(UIMessageNames.MN_BATTLE_SETTLEMENT_OPEN)
    self:CloseSelf()
end

function UIBattleRecordFromSeverView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_closeBtnTrans.gameObject)

    base.OnDestroy(self)
end

return UIBattleRecordFromSeverView