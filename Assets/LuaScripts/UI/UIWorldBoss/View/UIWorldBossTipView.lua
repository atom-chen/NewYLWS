local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local UIUtil = UIUtil

local base = UIBaseView
local UIWorldBossTipView = BaseClass("UIWorldBossTipView", UIBaseView)


function UIWorldBossTipView:OnCreate()
    base.OnCreate(self)
    
    self:InitView()
end

function UIWorldBossTipView:InitView()
    self.m_titleText, self.m_confirmBtnText, self.m_tipContentText = UIUtil.GetChildTexts(self.transform, {
        "winPanel/title/titleText","winPanel/confirmBtn/confirmBtnText","winPanel/middleText/Text"
    }) 
    
    self.m_confirmBtn = 
    UIUtil.GetChildTransforms(self.transform, {
        "winPanel/confirmBtn"
    })

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_confirmBtn.gameObject, onClick)

    self.transform.localScale = Vector3.New(0,0,0)
end

function UIWorldBossTipView:OnEnable(...)
    base.OnEnable(self, ...)

    local order, rank = ...

    self.m_titleText.text = Language.GetString(2400)
    self.m_confirmBtnText.text = Language.GetString(632)

    if not rank or rank == 0 then
        self.m_tipContentText.text = Language.GetString(2407)
    else
        self.m_tipContentText.text = string.format(Language.GetString(2406),rank)
    end

    DOTweenShortcut.DOScale(self.transform, 1, 0.5)
end

function UIWorldBossTipView:OnClick(go)
    if go.name == "confirmBtn" then
        UIManagerInst:CloseWindow(UIWindowNames.UIWorldBossTip)
    end
end

function UIWorldBossTipView:OnDisable()

	base.OnDisable(self)
end

function UIWorldBossTipView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_confirmBtn.gameObject)

    base.OnDestroy(self)
end

return UIWorldBossTipView