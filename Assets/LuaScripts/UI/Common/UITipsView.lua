local UITipsHelper = require "UI.Common.UITipsHelper"
local UITipsView = BaseClass("UITipsView", UIBaseView)
base = UIBaseView
local OFFSET = Vector2.New(-250, 60)

function UITipsView:OnCreate()
    base.OnCreate(self)

    self.m_nameText, self.m_desText = UIUtil.GetChildTexts(self.transform, {
        "bg/nameText",
        "bg/desText",
    })

    self.m_closeBtn, self.m_bgRoot = UIUtil.GetChildTransforms(self.transform, {
        "closeBtn",
        "bg",
    })

    self.m_tips = self:AddComponent(UITipsHelper, "bg") 


    self:HandleClick()
end

function UITipsView:OnEnable(...)
    base.OnEnable(self, ...)
    local _, targetPos, nameText, desText = ...

    self.m_nameText.text = nameText
    self.m_desText.text = desText

    if self.m_tips then
        self.m_tips:Init(OFFSET, targetPos)
    end 

end


function UITipsView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)
   
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, onClick)
end

function UITipsView:OnClick(go, x, y)
    self:CloseSelf()
end

function UITipsView:OnDestory()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    base.OnDestory(self)
end

return UITipsView