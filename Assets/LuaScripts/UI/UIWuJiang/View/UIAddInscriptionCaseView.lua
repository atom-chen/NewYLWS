

local UIUtil = UIUtil
local UILogicUtil = UILogicUtil

local UIAddInscriptionCaseView = BaseClass("UIAddInscriptionCaseView", UIBaseView)
local base = UIBaseView


function UIAddInscriptionCaseView:OnCreate()
    base.OnCreate(self)

    self.m_input = self:AddComponent(UIInput, "Container/Input")

    local placeholderText, cancelBtnText, confirmBtnText, titleText = UIUtil.GetChildTexts(self.transform, {
        "Container/Input/Placeholder",
        "Container/cancel_BTN/cancelBtnText",
        "Container/confirm_BTN/confirmBtnText",
        "Container/titleText",
    })

    placeholderText.text = Language.GetString(676)
    cancelBtnText.text = Language.GetString(50)
    confirmBtnText.text = Language.GetString(10)
    titleText.text = Language.GetString(706)
    
    local closeBtn, cancelBtn, confirmBtn = UIUtil.GetChildTransforms(self.transform, {
        "CloseBtn",
        "Container/cancel_BTN",
        "Container/confirm_BTN"
    })

    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(closeBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(cancelBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(confirmBtn.gameObject, onClick)
end

function UIAddInscriptionCaseView:OnDestory()
    self:RemoveClick()
    base.OnDestory(self)
end

function UIAddInscriptionCaseView:RemoveClick()
    UIUtil.RemoveClickEvent(closeBtn.gameObject)
    UIUtil.RemoveClickEvent(cancelBtn.gameObject)
    UIUtil.RemoveClickEvent(confirmBtn.gameObject)
end

function UIAddInscriptionCaseView:OnEnable(...)
    base.OnEnable(self, ...)
    
    _, self.m_wujiangIndex = ...
end

function UIAddInscriptionCaseView:OnDisable()
    self.m_input:SetText("")
    base.OnDisable(self)
end



function UIAddInscriptionCaseView:OnClick(go, x, y)
    if go.name == "CloseBtn" or go.name == "cancel_BTN" then
        self:CloseSelf()

    elseif go.name == "confirm_BTN" then
        local caseName = self.m_input:GetText()
        if caseName then
            if caseName == "" then
                UILogicUtil.FloatAlert(Language.GetString(693))
                return 
            end

            local inscription_id_list = Player:GetInstance().WujiangMgr:GetOwnInscriptionIDList(self.m_wujiangIndex)
            if inscription_id_list then
                if #inscription_id_list == 0 then
                    UILogicUtil.FloatAlert(Language.GetString(677))
                    return
                end

                Player:GetInstance().InscriptionMgr:ReqAddInscriptionCase(caseName, inscription_id_list)
            end
        end
    end
end


return UIAddInscriptionCaseView