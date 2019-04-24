local Vector3 = Vector3
local Vector2 = Vector2
local table_insert = table.insert
local string_format = string.format
local math_min = math.min
local string_trim = string.trim
local tonumber = tonumber
local ConfigUtil = ConfigUtil
local UIUtil = UIUtil
local UILogicUtil = UILogicUtil
local Language = Language
local GameUtility = CS.GameUtility
local UIGameObjectLoaderInstance = UIGameObjectLoader:GetInstance()
local FuliMgr = Player:GetInstance():GetFuliMgr()

local FuliAwardItemClass = require "UI.UIFuli.View.FuliAwardItem"
local FuliAwardItemPrefabPath = "UI/Prefabs/Fuli/AwardItem.prefab"

local DetailFundHelper = BaseClass("DetailFundHelper")

function DetailFundHelper:__init(fuliTr, fuliView)
    self.m_fuliView = fuliView
    
    self.m_descText, self.m_btnText = UIUtil.GetChildTexts(fuliTr, {
        "Container/Fuli/bg/RightContainer/Fund/Title/Descext",
        "Container/Fuli/bg/RightContainer/Fund/Title/BuyBtn/Text",
    })

    self.m_buyBtn, 
    self.m_fundTr, 
    self.m_gridTr,
    self.m_buyBtnRedPointTr  = UIUtil.GetChildTransforms(fuliTr, {
        "Container/Fuli/bg/RightContainer/Fund/Title/BuyBtn",
        "Container/Fuli/bg/RightContainer/Fund",
        "Container/Fuli/bg/RightContainer/Fund/ItemScrollView/Viewport/ItemContent",
        "Container/Fuli/bg/RightContainer/Fund/Title/BuyBtn/RedPointImg",
    })

    self.m_btnImg = UIUtil.AddComponent(UIImage, self.m_fuliView, "Container/Fuli/bg/RightContainer/Fund/Title/BuyBtn")
    self.m_titleImg = UIUtil.AddComponent(UIImage, self.m_fuliView, "Container/Fuli/bg/RightContainer/Fund/Title")
    self.m_fundGo = self.m_fundTr.gameObject
    self.m_titleImg:SetAtlasSprite("4.png", false, ImageConfig.Activity)

    self.m_ItemList = {}
    self.m_seq = 0
    self.m_yuanbaoCount = 0

    if FuliMgr:GetFundRedPointStatus() then
        self.m_buyBtnRedPointTr.gameObject:SetActive(true)
    else 
        self.m_buyBtnRedPointTr.gameObject:SetActive(false)
    end

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_buyBtn.gameObject, onClick)
end

function DetailFundHelper:OnClick(go)
    if go.name == "BuyBtn" then
        UIManagerInst:Broadcast(UIMessageNames.MN_FULI_FUND_BUY_BTN_CLICK)
        self.m_buyBtnRedPointTr.gameObject:SetActive(false)
        UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(9), string_format(Language.GetString(3448), self.m_yuanbaoCount), Language.GetString(10), Bind(FuliMgr, FuliMgr.ReqBuyFund), Language.GetString(50))
    end
end

function DetailFundHelper:__delete()
    self.m_fuliView = nil
    UIUtil.RemoveClickEvent(self.m_buyBtn.gameObject)
    self:Close()
end

function DetailFundHelper:Close()
    self.m_fundGo:SetActive(false)
    UIGameObjectLoaderInstance:CancelLoad(self.m_seq)
    self.m_seq = 0

    for i, v in ipairs(self.m_ItemList) do
        v:Delete()
    end
    self.m_ItemList = {}
end

function DetailFundHelper:UpdateScrollView()
    local oneFuli = self.m_fuliView:GetOneFuli()
    if not oneFuli then
        return
    end

    if #self.m_ItemList == 0 and self.m_seq == 0 then
        self.m_seq = UIGameObjectLoaderInstance:PrepareOneSeq()
        UIGameObjectLoaderInstance:GetGameObjects(self.m_seq, FuliAwardItemPrefabPath, #oneFuli.entry_list, function(objs)
            self.m_seq = 0 
            if objs then
                for i = 1, #objs do
                    local Item = FuliAwardItemClass.New(objs[i], self.m_gridTr, FuliAwardItemPrefabPath)
                    table_insert(self.m_ItemList, Item)
                    Item:UpdateData(oneFuli.entry_list[i], self.m_fuliView:GetFuliId())
                end
            end
        end)
    else
        for i, v in ipairs(self.m_ItemList) do
            v:UpdateData(oneFuli.entry_list[i], self.m_fuliView:GetFuliId())
        end
    end
end

function DetailFundHelper:UpdateInfo(isReset)
    local oneFuli = self.m_fuliView:GetOneFuli()
    if not oneFuli then
        return
    end

    if isReset then
        self.m_gridTr.localPosition = Vector2.zero
    end
    self.m_fundGo:SetActive(true)
    self.m_yuanbaoCount = oneFuli.f_param2
    self:UpdateScrollView()
    self.m_descText.text = string_format(Language.GetString(3444), oneFuli.f_param1)
    if oneFuli.f_param3 == 1 then
        self.m_btnImg:EnableRaycastTarget(false)
        GameUtility.SetUIGray(self.m_buyBtn.gameObject, true)
        self.m_btnText.text = Language.GetString(3446)
    else
        self.m_btnImg:EnableRaycastTarget(true)
        GameUtility.SetUIGray(self.m_buyBtn.gameObject, false)
        self.m_btnText.text = Language.GetString(3445)
    end

end

return DetailFundHelper