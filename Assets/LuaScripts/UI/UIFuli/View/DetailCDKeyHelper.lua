local Vector3 = Vector3
local Vector2 = Vector2
local string_format = string.format
local math_min = math.min
local string_trim = string.trim
local tonumber = tonumber
local ConfigUtil = ConfigUtil
local UIUtil = UIUtil
local UILogicUtil = UILogicUtil
local Language = Language
local FuliMgr = Player:GetInstance():GetFuliMgr()

local DetailCDKeyHelper = BaseClass("DetailCDKeyHelper")

function DetailCDKeyHelper:__init(fuliTr, fuliView)
    self.m_fuliView = fuliView
    
    self.m_titleText, self.m_descText, self.m_btnText = UIUtil.GetChildTexts(fuliTr, {
        "Container/Fuli/bg/RightContainer/CdKey/Title/Text",
        "Container/Fuli/bg/RightContainer/CdKey/bg/Text",
        "Container/Fuli/bg/RightContainer/CdKey/bg/Btn/Text",
    })

    self.m_exchangeBtn, self.m_cdKeyTr = UIUtil.GetChildTransforms(fuliTr, {"Container/Fuli/bg/RightContainer/CdKey/bg/Btn", "Container/Fuli/bg/RightContainer/CdKey"})
    self.m_cdKeyGo = self.m_cdKeyTr.gameObject

    self.m_input = self.m_fuliView:AddComponent(UIInput, "Container/Fuli/bg/RightContainer/CdKey/bg/InputField")

    self.m_param = 0

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_exchangeBtn.gameObject, onClick)
end

function DetailCDKeyHelper:OnClick(go)
    if go.name == "Btn" then
        local inputText = string_trim(self.m_input:GetText())
        if inputText == "" then
            UILogicUtil.FloatAlert(Language.GetString(3450))
            return
        end

        if self.m_param == 1 then
            FuliMgr:ReqGetFuliAward(self.m_fuliView:GetFuliId(), 0, 0, self.m_input:GetText())
        else
            UILogicUtil.FloatAlert(Language.GetString(3438))
        end
    end
end

function DetailCDKeyHelper:__delete()
    UIUtil.RemoveClickEvent(self.m_exchangeBtn.gameObject)
    self.m_fuliView = nil
    self:Close()
end

function DetailCDKeyHelper:Close()
    self.m_cdKeyGo:SetActive(false)

end

function DetailCDKeyHelper:UpdateInfo(isReset)
    local oneFuli = self.m_fuliView:GetOneFuli()
    if not oneFuli then
        return
    end

    self.m_cdKeyGo:SetActive(true)
    self.m_param = oneFuli.f_param1
    self.m_titleText.text = self.m_fuliView:GetTitleName()
    self.m_descText.text = Language.GetString(3439)
    self.m_btnText.text = Language.GetString(3440)
end

return DetailCDKeyHelper