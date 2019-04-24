
local math_ceil = math.ceil
local math_floor = math.floor
local string_format = string.format
local table_insert = table.insert
local UIUtil = UIUtil
local Language = Language
local ConfigUtil = ConfigUtil
local CommonDefine = CommonDefine
local GameUtility = CS.GameUtility
local UIGameObjectLoaderInstance = UIGameObjectLoader:GetInstance()
local ItemMgr = Player:GetInstance():GetItemMgr()

local ItemIconParam = require "DataCenter.ItemData.ItemIconParam"
local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam"
local FuliMgr = Player:GetInstance():GetFuliMgr()

local FuliAwardItem = BaseClass("FuliAwardItem", UIBaseItem)
local base = UIBaseItem

function FuliAwardItem:OnCreate()
    base.OnCreate(self)

    self.m_conditionText, self.m_descText, self.m_btnText = UIUtil.GetChildTexts(self.transform, { 
        "Condition/Text",
        "Desc",
        "GetBtn/Text",
    })

    self.m_gridTr, self.m_getImgTr, self.m_getBtnTr, self.m_descTr = UIUtil.GetChildTransforms(self.transform, {
        "Grid",
        "GetImg",
        "GetBtn",
        "Desc",
    })

    self.m_btnImg = UIUtil.AddComponent(UIImage, self, "GetBtn")

    self.m_getImgGo = self.m_getImgTr.gameObject
    self.m_getBtnGo = self.m_getBtnTr.gameObject
    self.m_descGo = self.m_descTr.gameObject

    self.m_awardItemList = {}
    self.m_seq = 0
    self.m_fuliId = 0
    self.m_index = 0


    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_getBtnGo, onClick)
end

function FuliAwardItem:OnClick(go)
    if go.name == "GetBtn" then
        FuliMgr:ReqGetFuliAward(self.m_fuliId, self.m_index, 0, "")
    end
end

function FuliAwardItem:UpdateData(entry, fuliId)
    if not entry then
        return
    end
    
    self.m_fuliId = fuliId or 0
    self.m_index = entry.index
    self.m_conditionText.text = entry.desc
    self.m_descText.text = string_format(Language.GetString(3447), entry.e_param1, entry.condition)
    self.m_btnText.text =  Language.GetString(3435)
    self.m_getImgGo:SetActive(false)
    self.m_getBtnGo:SetActive(true)
    self.m_btnImg:EnableRaycastTarget(true)
    self.m_descGo:SetActive(true)
    GameUtility.SetUIGray(self.m_getBtnGo, false)
    if entry.status == 0 then
        GameUtility.SetUIGray(self.m_getBtnGo, true)
        self.m_btnImg:EnableRaycastTarget(false)
    elseif entry.status == 2 then
        self.m_getImgGo:SetActive(true)
        self.m_getBtnGo:SetActive(false)
        self.m_descGo:SetActive(false)
    end

    if #self.m_awardItemList == 0 and self.m_seq == 0 then
        self.m_seq = UIGameObjectLoaderInstance:PrepareOneSeq()
        UIGameObjectLoaderInstance:GetGameObjects(self.m_seq, CommonAwardItemPrefab, #entry.award_list, function(objs)
            self.m_seq = 0
            
            if objs then
                for i = 1, #objs do
                    local awardItem = CommonAwardItem.New(objs[i], self.m_gridTr, CommonAwardItemPrefab)
                    awardItem:SetLocalScale(Vector3.one * 0.8)
                    table_insert(self.m_awardItemList, awardItem)
                    local awardIconParam = AwardIconParamClass.New(entry.award_list[i].item_id, entry.award_list[i].count)
                    awardItem:UpdateData(awardIconParam)
                end
            end
        end)
    else
        for i, v in ipairs(self.m_awardItemList) do
            local awardIconParam = AwardIconParamClass.New(entry.award_list[i].item_id, entry.award_list[i].count)
            v:UpdateData(awardIconParam)
        end
    end
end

function FuliAwardItem:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_getBtnGo)
    UIGameObjectLoaderInstance:CancelLoad(self.m_seq)
    self.m_seq = 0
    
    for _, v in ipairs(self.m_awardItemList) do
        v:Delete()
    end
    self.m_awardItemList = {}

    base.OnDestroy(self)
end

return FuliAwardItem