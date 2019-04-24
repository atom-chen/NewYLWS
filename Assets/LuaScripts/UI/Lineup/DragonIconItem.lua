local DragonIconItem = BaseClass("DragonIconItem", UIBaseItem)
local base = UIBaseItem

function DragonIconItem:OnCreate()
    self.m_dragonID = 0
    self.m_lockImg, self.m_selectImg = UIUtil.GetChildTransforms(self.transform, {
        "lockImg",
        "selectImg",
    })

    self.m_iconImg = UIUtil.AddComponent(UIImage, self, "icon", AtlasConfig.DynamicLoad)
    self.m_lockImg = self.m_lockImg.gameObject
    self.m_selectImg = self.m_selectImg.gameObject

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_iconImg.gameObject, onClick)
end

function DragonIconItem:SetData(dragonID, isLock)
    self.m_dragonID = dragonID
    self.m_lockImg:SetActive(isLock)
    UILogicUtil.SetDragonIcon(self.m_iconImg, dragonID)
end

function DragonIconItem:OnSelect(isSelect)
    self.m_selectImg:SetActive(isSelect)
end

function DragonIconItem:OnClick(go, x, y)
    local name = go.name
    if name == "icon" then
        UIManagerInst:Broadcast(UIMessageNames.MN_LINEUP_CLICK_DRAGON, self.m_dragonID)
    end
end

function DragonIconItem:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_iconImg.gameObject)
    base.OnDestroy(self)
end

return DragonIconItem