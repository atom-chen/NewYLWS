local Language = Language
local BattleEnum = BattleEnum
local CommonDefine = CommonDefine
local Vector3 = Vector3
local Color = Color
local table_insert = table.insert
local LineupWuJiangCardItem = require "UI.UIWuJiang.View.LineupWuJiangCardItem"
local CardItemPath = TheGameIds.CommonWujiangCardPrefab
local LineupManagerItem = BaseClass("LineupManagerItem", UIBaseItem)
local base = UIBaseItem

function LineupManagerItem:OnCreate()
    self.m_roleItemArray = {}
    self.m_seq = 0
    self.m_buzhenID = nil
    self.m_battleType = nil
    self.m_wuJiangMgr = Player:GetInstance():GetWujiangMgr()

    local itemBg_1, itemBg_2, itemBg_3, itemBg_4, itemBg_5
    itemBg_1, itemBg_2, itemBg_3, itemBg_4, itemBg_5, 
    self.m_useBtn, self.m_editBtn, self.m_dragonBg = UIUtil.GetChildTransforms(self.transform, {
        "roleGrid/itemBg_1",
        "roleGrid/itemBg_2",
        "roleGrid/itemBg_3",
        "roleGrid/itemBg_4",
        "roleGrid/itemBg_5",
        "VerticalLayout/useBtn",
        "VerticalLayout/editBtn",
        "Dragon",
    })

    self.m_dragonBg = self.m_dragonBg.gameObject
    self.m_itemBgTransList = {itemBg_1, itemBg_2, itemBg_3, itemBg_4, itemBg_5}
    self.m_useBtnImage = UIUtil.AddComponent(UIImage, self, "VerticalLayout/useBtn", AtlasConfig.DynamicLoad)
    self.m_dragonImg = UIUtil.AddComponent(UIImage, self, "dragonImg", AtlasConfig.DynamicLoad)

    local powerDesText, useText, editText
    self.m_numText, self.m_powerText, powerDesText, useText, editText = UIUtil.GetChildTexts(self.transform, {
        "numText",
        "powerBg/powerText",
        "powerBg/powerDesText",
        "VerticalLayout/useBtn/useText",
        "VerticalLayout/editBtn/editText",
    })

    powerDesText.text = Language.GetString(1102)
    useText.text = Language.GetString(1103)
    editText.text = Language.GetString(1104)

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_useBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_editBtn.gameObject, onClick)
end

function LineupManagerItem:SetData(index, buzhenID, battleType, canEditor)
    self.m_buzhenID = buzhenID
    self.m_battleType = battleType
    if #self.m_roleItemArray == 0 and self.m_seq == 0 then
        self.m_seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoader:GetInstance():GetGameObjects(self.m_seq, CardItemPath, CommonDefine.LINEUP_WUJIANG_COUNT, function(objs)
            self.m_seq = 0
            if objs then
                for i = 1, #objs do
                    local cardItem = LineupWuJiangCardItem.New(objs[i], self.m_itemBgTransList[i], CardItemPath)
                    cardItem:SetLocalPosition(Vector3.New(0, -22, 0))
                    cardItem:SetLocalScale(Vector3.New(0.96, 0.96, 1))
                    table_insert(self.m_roleItemArray, cardItem)
                end

                self:UpdateLineupIcons()
            end
        end)
    else
        self:UpdateLineupIcons()
    end

    if self:IsEmptyLineup() then
        self.m_useBtnImage:SetColor(Color.black)
    else
        self.m_useBtnImage:SetColor(Color.white)
    end
    self.m_numText.text = index

    self.m_editBtn.gameObject:SetActive(canEditor)

    self.m_powerText.text = string.format("%d", Player:GetInstance():GetLineupMgr():GetLineupTotalPower(self.m_buzhenID))
end

function LineupManagerItem:UpdateLineupIcons()
    self:HideAllIcon()

    Player:GetInstance():GetLineupMgr():Walk(self.m_buzhenID, function(wujiangBriefData)
        self.m_roleItemArray[wujiangBriefData.pos]:SetData(wujiangBriefData)
    end)
    
    local dragon = Player:GetInstance():GetLineupMgr():GetLineupDragon(self.m_buzhenID)
    if dragon > 0 then
        self.m_dragonImg.gameObject:SetActive(true)
        self.m_dragonBg:SetActive(false)
        UILogicUtil.SetDragonIcon(self.m_dragonImg, dragon)
    else
        self.m_dragonImg.gameObject:SetActive(false)
        self.m_dragonBg:SetActive(true)
    end
end

function LineupManagerItem:IsEmptyLineup()
    local isEmpty = true
    Player:GetInstance():GetLineupMgr():Walk(self.m_buzhenID, function(wujiangBriefData)
        isEmpty = false
    end)
    return isEmpty
end

function LineupManagerItem:HideAllIcon()
    for _, wujiangItem in pairs(self.m_roleItemArray) do
        wujiangItem:HideAll()
    end
end

function LineupManagerItem:OnClick(go, x, y)
    local name = go.name
    if name == "useBtn" then
        if self:IsEmptyLineup() then
            return
        end

        if self.m_battleType == BattleEnum.BattleType_ARENA_DEF then
            Player:GetInstance():GetArenaMgr():ApplyToModuleLineup(self.m_buzhenID)
        else
            Player:GetInstance():GetLineupMgr():ApplyToModuleLineup(Utils.GetBuZhenIDByBattleType(self.m_battleType), self.m_buzhenID)
        end
        UIManagerInst:Broadcast(UIMessageNames.MN_LINEUP_APPLY_NEW)
    elseif name == "editBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UILineupEdit, self.m_battleType, self.m_buzhenID)
    end
end

function LineupManagerItem:OnDestroy()
    for _, wujiangItem in pairs(self.m_roleItemArray) do
        if wujiangItem then
            wujiangItem:Delete()
        end
    end

    UIUtil.RemoveClickEvent(self.m_useBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_editBtn.gameObject)
    self.m_roleItemArray = {}
    base.OnDestroy(self)
end

return LineupManagerItem