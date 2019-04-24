
local math_ceil = math.ceil
local math_floor = math.floor
local string_format = string.format
local UIUtil = UIUtil
local Language = Language
local ConfigUtil = ConfigUtil
local GameUtility = CS.GameUtility
local UIGameObjectLoaderInstance = UIGameObjectLoader:GetInstance()
local ItemMgr = Player:GetInstance():GetItemMgr()
local BagItemPrefabPath = TheGameIds.CommonBagItemPrefab
local BagItemClass = require("UI.UIBag.View.BagItem")
local ItemIconParam = require "DataCenter.ItemData.ItemIconParam"
local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam"
local FuliMgr = Player:GetInstance():GetFuliMgr()

local StamainItem = BaseClass("StamainItem", UIBaseItem)
local base = UIBaseItem

function StamainItem:OnCreate()
    base.OnCreate(self)

    self.m_timeAreaText, self.m_yuanbaoCountText, self.m_btnText = UIUtil.GetChildTexts(self.transform, { 
        "TimeArea",
        "Yuanbao/CountText",
        "GetBtn/Text",
    })

    self.m_itemParentTr, self.m_getImgTr, self.m_getBtnTr, self.m_yuanbaoTr = UIUtil.GetChildTransforms(self.transform, {
        "BagItemParent",
        "GetImg",
        "GetBtn",
        "Yuanbao",
    })

    self.m_btnImg = UIUtil.AddComponent(UIImage, self, "GetBtn")

    self.m_getImgGo = self.m_getImgTr.gameObject
    self.m_getBtnGo = self.m_getBtnTr.gameObject
    self.m_yuanbaoGo = self.m_yuanbaoTr.gameObject
    self.m_fuliId = 0
    self.m_index = 0
    self.m_param = 0

    self.m_curBagItem = nil
    self.m_seq = 0

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_getBtnGo, onClick)
end

function StamainItem:OnClick(go)
    if go.name == "GetBtn" then
        if self.m_param == 0 then
            return
        end
        FuliMgr:ReqGetFuliAward(self.m_fuliId, self.m_index, self.m_param, "")
    end
end

function StamainItem:UpdateData(item, status, leftTime, rightTime, condition, index, fuliId)
    if not item then
        return
    end

    self.m_fuliId = fuliId or 0
    self.m_index = index or 0
    if not self.m_curBagItem and self.m_seq == 0 then
        self.m_seq = UIGameObjectLoaderInstance:PrepareOneSeq()
        UIGameObjectLoaderInstance:GetGameObject(self.m_seq, CommonAwardItemPrefab, function(go)
            self.m_seq = 0
            if not go then
                return
            end
            
            self.m_curBagItem = CommonAwardItem.New(go, self.m_itemParentTr, CommonAwardItemPrefab)
            self.m_curBagItem:SetLocalScale(Vector3.one * 0.8)
            local itemIconParam = AwardIconParamClass.New(item.item_id, item.count)
            self.m_curBagItem:UpdateData(itemIconParam)
        end)
    else
        local itemIconParam = AwardIconParamClass.New(item.item_id, item.count)
        self.m_curBagItem:UpdateData(itemIconParam)
    end

    self.m_timeAreaText.text = string_format(Language.GetString(3437), string_format("%d:%02d", math_floor(leftTime / 100), leftTime % 100), string_format("%d:%02d", math_floor(rightTime / 100), rightTime % 100))
    self.m_yuanbaoCountText.text = math_ceil(condition)

    self.m_getImgGo:SetActive(false)
    self.m_getBtnGo:SetActive(false)
    self.m_yuanbaoGo:SetActive(false)
    GameUtility.SetUIGray(self.m_getBtnGo, false)
    self.m_btnImg:EnableRaycastTarget(true)
    if status == 0 then
        self.m_btnImg:EnableRaycastTarget(false)
        GameUtility.SetUIGray(self.m_getBtnGo, true)
        self.m_getBtnGo:SetActive(true)
        self.m_yuanbaoGo:SetActive(false)
        self.m_btnText.text = Language.GetString(3435)
    elseif status ==  1 then
        self.m_param = 3
        self.m_getBtnGo:SetActive(true)
        self.m_yuanbaoGo:SetActive(false)
        self.m_btnText.text = Language.GetString(3435)
    elseif status == 2 then
        self.m_getImgGo:SetActive(true)
    elseif status ==  3 then
        self.m_param = 1
        self.m_getBtnGo:SetActive(true)
        self.m_yuanbaoGo:SetActive(true)
        self.m_btnText.text = Language.GetString(3436)
    end

end

function StamainItem:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_getBtnGo)
    self.m_curBagItem:Delete()
    self.m_curBagItem = nil

    UIGameObjectLoaderInstance:CancelLoad(self.m_seq)
    self.m_seq = 0

    base.OnDestroy(self)
end

return StamainItem