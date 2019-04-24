local GameObject = CS.UnityEngine.GameObject
local table_insert = table.insert
local string_format = string.format
local BattleHorseSettlementItemPath = "UI/Prefabs/Battle/BattleHorseSettlementItem.prefab"
local BattleHorseSettlementItem = require "UI.UIBattle.View.BattleHorseSettlementItem"
local UIGameObjectLoader = UIGameObjectLoader:GetInstance()
local UIBattleHorseRaceSettlementView = BaseClass("UIBattleHorseRaceSettlementView", UIBaseView)
local base = UIBaseView


function UIBattleHorseRaceSettlementView:OnCreate()
    base.OnCreate(self)
    self:InitView()
end

function UIBattleHorseRaceSettlementView:InitView()
    self.m_closeBtn, self.m_itemContent = UIUtil.GetChildRectTrans(self.transform, {
        "closeBtn",
        "Container/itemContent",
    })

    local rankText, playerText, horseText, timeText
    rankText, playerText, horseText, timeText = UIUtil.GetChildTexts(self.transform, {
        "Container/top/rankText",
        "Container/top/playerText",
        "Container/top/horseText",
        "Container/top/timeText",
    })

    rankText.text = Language.GetString(4161)
    playerText.text = Language.GetString(4162)
    horseText.text = Language.GetString(4163)
    timeText.text = Language.GetString(4164)

    self.m_raceRackItemList = {}
end

function UIBattleHorseRaceSettlementView:OnClick(go, x, y)
    if go.name == "closeBtn" then
        SceneManagerInst:SwitchScene(SceneConfig.HomeScene)
    end
end

function UIBattleHorseRaceSettlementView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
end

function UIBattleHorseRaceSettlementView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
end

function UIBattleHorseRaceSettlementView:OnEnable(...)
    base.OnEnable(self, ...)
    local order,rank_list
    order, rank_list = ...  
    self:HandleClick()
    self:UpdateRankShow(rank_list)
end

function UIBattleHorseRaceSettlementView:OnDisable()
    base.OnDisable(self)
    self:RemoveClick()
    for _,item in pairs(self.m_raceRackItemList) do
		item:Delete()
	end
	self.m_raceRackItemList = {}
end

function UIBattleHorseRaceSettlementView:UpdateRankShow(rank_list)
    if not rank_list then
        return
    end
    if #self.m_raceRackItemList == 0 then
        self.m_seq = UIGameObjectLoader:PrepareOneSeq()
        UIGameObjectLoader:GetGameObjects(self.m_seq, BattleHorseSettlementItemPath, #rank_list, function(objs)
            self.m_seq = 0
            if objs then
                for i = 1, #objs do
                    local rankItem = BattleHorseSettlementItem.New(objs[i], self.m_itemContent, BattleHorseSettlementItemPath)
                    if rankItem then
                        table_insert(self.m_raceRackItemList, rankItem)
                        rankItem:SetData(rank_list[i])
                    end 
                end
            end
        end)
    else
        for i = 1, #self.m_raceRackItemList do
            self.m_raceRackItemList[i]:SetData(rank_list[i])
        end
    end
end

function UIBattleHorseRaceSettlementView:OnDestroy()
    base.OnDestroy(self)
end

return UIBattleHorseRaceSettlementView