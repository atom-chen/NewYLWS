local BattleSettlementView = require "UI.UIBattleRecord.View.BattleSettlementView"

local UIShenbingCopySettlementView = BaseClass("UIShenbingCopySettlementView", BattleSettlementView)
local ConfigUtil = ConfigUtil
local table_insert = table.insert

local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local UIBattleSettlementItemPrefabPath = TheGameIds.BattleSettlementItemPrefab
local UIGameObjectLoaderInstance = UIGameObjectLoader:GetInstance()
local Vector2 = Vector2

local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local SpringContent = CS.SpringContent
local ItemContentSize = 750
local ItemSize = 150

function UIShenbingCopySettlementView:UpdateDropList()
    local dropSth = false
    if not self.m_msgObj.drop_list or #self.m_msgObj.drop_list == 0 then
        self.m_finish = true
    else
        self.m_finish = false
    end

    local CreateAwardParamFromPbAward = PBUtil.CreateAwardParamFromPbAward

    self.m_dropAttachList = {}
    local dropList = self.m_msgObj.drop_list
    if dropList and #dropList > 0 then

        local paramList = {}

        for _, onedrop in ipairs(dropList) do
            local itemIconParam = CreateAwardParamFromPbAward(onedrop)
            local itemCfg = ConfigUtil.GetItemCfgByID(itemIconParam.itemID)
            if itemCfg then
                if itemCfg.sMainType == CommonDefine.ItemMainType_ShenBing then
                    table_insert(paramList, 1, itemIconParam)
                else
                    table_insert(paramList, itemIconParam)
                end
            end            
        end


        dropSth = true

        self.m_bagItemSeq = UIGameObjectLoaderInstance:PrepareOneSeq()
        local count = #dropList
        UIGameObjectLoaderInstance:GetGameObjects(self.m_bagItemSeq, CommonAwardItemPrefab, count, function(objs)
            self.m_bagItemSeq = 0
            if objs then

                for i = 1, #objs do
                    local dropAttachItem = CommonAwardItem.New(objs[i], self.m_attachItemContentTr, CommonAwardItemPrefab)
                    dropAttachItem:SetLocalScale(Vector3.zero)           
                    table_insert(self.m_dropAttachList, dropAttachItem)

                    local itemIconParam = paramList[i]
                    dropAttachItem:UpdateData(itemIconParam)
                end
            end
        end)
        
        self.m_awardItemIndex = 1
        coroutine.start(self.TweenShow, self)
    end

    local wujiangList = self.m_msgObj.wujiang_exp_list
    if wujiangList and #wujiangList > 0 then
        dropSth = true
    end

    if dropSth then
        self.m_dropBg.gameObject:SetActive(true)
    else
        self.m_dropBg.gameObject:SetActive(false)
    end
end

return UIShenbingCopySettlementView