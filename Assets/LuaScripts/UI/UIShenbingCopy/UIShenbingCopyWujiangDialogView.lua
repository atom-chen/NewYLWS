
local UIPlotWujiangDialogView = require "UI.UIPlot.View.UIPlotWujiangDialogView"
local UIShenbingCopyWujiangDialogView = BaseClass("UIShenbingCopyWujiangDialogView", UIPlotWujiangDialogView)
local base = UIPlotWujiangDialogView
local Vector3 = Vector3
local SplitString = CUtil.SplitString
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local DOTween = CS.DOTween.DOTween
local WujiangRotate = Vector3.New(0, 180, 0)
local math_ceil = math.ceil
local ConfigUtil = ConfigUtil
local Language = Language


function UIShenbingCopyWujiangDialogView:SetUIEnable(value)
end

function UIPlotWujiangDialogView:ShowSkip()
    self.m_skipBtn.gameObject:SetActive(false)
end

function UIShenbingCopyWujiangDialogView:UpdateView(...)
    local characterName, sParam, isLeft, wujiangID, weaponLevel, lang, languageCfgName = ...

    local wujiangCfg = ConfigUtil.GetWujiangCfgByID(wujiangID)
    if not wujiangCfg then
        return
    end

    self.m_leftNameText.text = wujiangCfg.sName
    self.m_leftNameBg:SetActive(true)
    self.m_rightNameBg:SetActive(false)
    self:LoadLeftWujiangModel(wujiangID, weaponLevel, 650, 300, -425, 'nil', false, 135)

    self.m_msgText.text = Language.GetString(lang)
end

function UIShenbingCopyWujiangDialogView:OnClick(go, x, y)
    local name = go.name
	if name == "closeBtn" then        
        UIManagerInst:Broadcast(UIMessageNames.UIBATTLE_SHENBING_DIALOG_CLOSE)
        self:CloseSelf()
    end
end


return UIShenbingCopyWujiangDialogView