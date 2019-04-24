local UIUtil = UIUtil
local SplitString = CUtil.SplitString
local ShopTabItem = BaseClass("ShopTabItem", UIBaseItem)
local base = UIBaseItem

function ShopTabItem:OnCreate()
    self.m_shopType = 0
    self.m_selectImgGO, self.m_clickBtn = UIUtil.GetChildTransforms(self.transform, {
        "selectImg",
        "clickBtn",
    })

    self.m_nameText, self.m_selectNameText = UIUtil.GetChildTexts(self.transform, {
        "tabNameText1",
        "tabNameText2",
    })

    self.m_selectImgGO = self.m_selectImgGO.gameObject

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_clickBtn.gameObject, onClick)
end

function ShopTabItem:SetData(shopType, name, isSelect)
    self.m_shopType = shopType
    self.m_selectImgGO:SetActive(isSelect)
    self.m_nameText.text = isSelect and "" or name
    self.m_selectNameText.text = isSelect and name or ""
end

function ShopTabItem:OnClick(go, x, y)
    UIManagerInst:Broadcast(UIMessageNames.MN_SHOP_CLICK_TAB_BTN, self.m_shopType)
end

function ShopTabItem:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_clickBtn.gameObject)
    base.OnDestroy(self)
end

return ShopTabItem