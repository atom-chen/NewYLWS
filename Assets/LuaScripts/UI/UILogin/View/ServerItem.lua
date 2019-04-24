local base = UIBaseItem
local ServerItem = BaseClass("ServerItem", base)

function ServerItem:OnCreate()
    base.OnCreate(self)
    
    self.m_serverData = nil
    self.m_nameText = UIUtil.GetChildTexts(self.transform, {
        "bg/nameText",
    })

    self.m_clickBtn, self.m_selectImg = UIUtil.GetChildTransforms(self.transform, {
        "bg/clickBtn",
        "bg/selectImg",
    })
    self.m_selectImg = self.m_selectImg.gameObject
    self.m_statusImg = UIUtil.AddComponent(UIImage, self, "bg/statusImg", AtlasConfig.DynamicLoad)
    
    UIUtil.AddClickEvent(self.m_clickBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick))
end

function ServerItem:SetData(serverData, isSelect)
    self.m_serverData = serverData
    self.m_statusImg:SetAtlasSprite(serverData:GetStatusSpriteName())
    self.m_nameText.text = serverData:GetServerIndexAndName()
    self.m_selectImg:SetActive(isSelect)
end

function ServerItem:OnClick(go, x, y)
    if go.name == "clickBtn" then
        UIManagerInst:Broadcast(UIMessageNames.MN_LOGIN_SELECT_SERVER, self.m_serverData)
    end
end

function ServerItem:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_clickBtn.gameObject)
    base.OnDestroy(self)
end

return ServerItem

