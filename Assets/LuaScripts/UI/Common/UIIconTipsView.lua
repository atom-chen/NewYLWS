local string_format = string.format
local table_insert = table.insert
local math_ceil = math.ceil
local GameObject = CS.UnityEngine.GameObject

local Type_RectTransform = typeof(CS.UnityEngine.RectTransform)
local ScreenPointToLocalPointInRectangle = CS.UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle
local UIUtil = UIUtil

local UIIconTipsView = BaseClass("UIIconTipsView", UIBaseView)
local base = UIBaseView

function UIIconTipsView:OnCreate()
    base.OnCreate(self)
    
    self.m_skillTipsRectTran, self.m_skillTipsTextRectTran, self.m_closeBtn , self.m_containerRectTran = 
    UIUtil.GetChildRectTrans(self.transform, {
        "Container/SkillTips",
        "Container/SkillTips/SkillTipsText",
        "CloseBtn",
        "Container"
    })

    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, onClick)

    self.m_skillTipsText = UIUtil.FindText(self.transform, "Container/SkillTips/SkillTipsText")
    self.m_colorList = { "ffffff","32b0e4", "e041e6", "e8c04c", "d24643"}

    self.m_setContentSize = false
    self.m_delayFrameCount = 0

end

function UIIconTipsView:OnClick(go)
    if go.name == "CloseBtn" then
        self:CloseSelf()
    end
end

function UIIconTipsView:OnEnable(...)
    base.OnEnable(self, ...)
    
    local _, targetPos, text  = ...
    if not targetPos then
        return 
    end

    local uiCamera = UIManagerInst.UICamera
    local screenPos = uiCamera:WorldToScreenPoint(targetPos)
    local v2 = Vector2.New(screenPos.x, screenPos.y)

    local ok, outV2 = ScreenPointToLocalPointInRectangle(self.m_containerRectTran, v2, uiCamera)

    self.m_skillTipsRectTran.anchoredPosition = Vector2.New(outV2.x, outV2.y + 30)

    self.m_skillTipsText.text = text
    self.m_setContentSize = true
    self.m_delayFrameCount = 1

end


function UIIconTipsView:Update()
    if self.m_delayFrameCount > 0 then
        self.m_delayFrameCount = self.m_delayFrameCount - 1
        return
    end

    if self.m_setContentSize then
        self.m_setContentSize = false
        local sizeDelta = self.m_skillTipsTextRectTran.sizeDelta
        local sizeDelta2 = self.m_skillTipsRectTran.sizeDelta
        if sizeDelta.y > 141 then
            local y = sizeDelta2.y + (sizeDelta.y - 141 + 10)
            self.m_skillTipsRectTran.sizeDelta = Vector2.New(sizeDelta2.x, y)
        end
    end
end

function UIIconTipsView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    base.OnDestroy(self)
end


return UIIconTipsView