local BagItem = require "UI.UIBag.View.BagItem"
local ItemIconParam = require "DataCenter.ItemData.ItemIconParam"
local BagItemPrefabPath = TheGameIds.CommonBagItemPrefab
local Vector3 = Vector3
local table_insert = table.insert
local Language = Language
local QingYuanGiftItem = BaseClass("QingYuanGiftItem", UIBaseItem)
local base = UIBaseItem
local GameUtility = CS.GameUtility

function QingYuanGiftItem:OnCreate()
    base.OnCreate(self)
    self.m_itemLoaderSeq = 0 
    self.m_item = nil 

    self.m_clickGiveDesTxt,
    self.m_clickBuyDesTxt = UIUtil.GetChildTexts(self.transform, {
        "ClickGiveDes",
        "ClickBuyDes",
    })

    self.m_itemPosTr = UIUtil.FindTrans(self.transform, "ItemPos")
end

function QingYuanGiftItem:UpdateData(item_id, count, callback) 
    if self.m_item then
        local itemCfg = ConfigUtil.GetItemCfgByID(item_id)
        if itemCfg then 
            local itemParam = ItemIconParam.New(itemCfg, count)
            itemParam.selfOnClickCallback = callback
            self.m_item:UpdateData(itemParam)
        end
    else
        self.m_itemLoaderSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoader:GetInstance():GetGameObject(self.m_itemLoaderSeq, BagItemPrefabPath, function(obj)
            self.m_itemLoaderSeq = 0
            if obj then
                local item = BagItem.New(obj, self.m_itemPosTr, BagItemPrefabPath) 
                item:SetLocalScale(Vector3.New(0.85, 0.85, 1))
                local itemCfg = ConfigUtil.GetItemCfgByID(item_id)
                if itemCfg then 
                    local itemParam = ItemIconParam.New(itemCfg, count)
                    itemParam.selfOnClickCallback = callback
                    item:UpdateData(itemParam)
                end 
                self.m_item = item
                self.m_item:SetClickScaleChg(true, 0.85, 0.95, 0.2) 
            end
        end)
    end
    if count <= 0 then 
        GameUtility.SetUIGray(self.m_item.transform.gameObject, true) 
        self.m_clickBuyDesTxt.text = Language.GetString(3660)
        self.m_clickGiveDesTxt.text = ""
    else 
        GameUtility.SetUIGray(self.m_item.transform.gameObject, false) 
        self.m_clickGiveDesTxt.text = Language.GetString(3659)
        self.m_clickBuyDesTxt.text = ""
    end
end 

function QingYuanGiftItem:OnDestroy()
    UIGameObjectLoader:GetInstance():CancelLoad(self.m_itemLoaderSeq)
    self.m_itemLoaderSeq = 0

    GameUtility.SetUIGray(self.m_item.transform.gameObject, false) 
    
    if self.m_item then
        self.m_item:Delete()
        self.m_item = nil
    end
    
    base.OnDestroy(self)
end

return QingYuanGiftItem













