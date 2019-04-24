
local UIInscriptionStageItem = BaseClass("UIInscriptionStageItem", UIBaseItem)
local base = UIBaseItem

function UIInscriptionStageItem:OnCreate()

    base.OnCreate(self)

    self.m_checkBtn, self.m_checkSptGo = UIUtil.GetChildTransforms(self.transform, {
        "CheckBtn",
        "CheckSpt",
    })

    self.m_nameText = UIUtil.FindText(self.transform, "NameText")

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_checkBtn.gameObject, onClick)

    self.m_checkSptGo = self.m_checkSptGo.gameObject
    self.m_isSelect = false
    self.m_selfOnClickCallback = nil
end


function UIInscriptionStageItem:UpdateData(stage, nameText, isSelect, selfOnClickCallback)

    isSelect = isSelect or false

    self.m_nameText.text = nameText
    self.Stage = stage

    self.m_checkSptGo:SetActive(isSelect)

    self.m_isSelect = isSelect

    self.m_selfOnClickCallback = selfOnClickCallback
end

function UIInscriptionStageItem:OnClick(go, x, y)
    if go.name == "CheckBtn" then
       
        self.m_isSelect = not self.m_isSelect
        self.m_checkSptGo:SetActive(self.m_isSelect)

        if self.m_selfOnClickCallback then
            self.m_selfOnClickCallback(self)
        end
    end
end

function UIInscriptionStageItem:IsSelect()
    return self.m_isSelect
end

function UIInscriptionStageItem:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_checkBtn.gameObject)
    self.m_selfOnClickCallback = nil
    base.OnDestroy(self)
end

return UIInscriptionStageItem