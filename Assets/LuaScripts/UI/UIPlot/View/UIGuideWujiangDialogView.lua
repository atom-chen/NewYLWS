
local UIPlotWujiangDialogView = require "UI.UIPlot.View.UIPlotWujiangDialogView"
local UIGuideWujiangDialogView = BaseClass("UIGuideWujiangDialogView", UIPlotWujiangDialogView)
local base = UIPlotWujiangDialogView
local Vector3 = Vector3
local SplitString = CUtil.SplitString
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local Type_Animator = typeof(CS.UnityEngine.Animator)
local GameUtility = CS.GameUtility
local DOTweenSettings = CS.DOTween.DOTweenSettings
local DOTween = CS.DOTween.DOTween
local Language = Language

function UIGuideWujiangDialogView:ShowSkip()
    self.m_skipText.text = Language.GetString(902)
end

function UIGuideWujiangDialogView:UpdateView(...)
    local characterName, sParam, isLeft, wujiangID, weaponLevel, message, languageCfgName = ...
    local paramList = SplitString(sParam, ',')
    self.m_skipBtn.gameObject:SetActive(paramList[2] == "1")
    self.m_isCloseWhenClick = paramList[5] == "1"
    self.m_isCloseMainUI = paramList[9] == "1"
    self.m_animSpeed = tonumber(paramList[10]) or 1
    Logger.Log("UIGuideWujiangDialog :" .. sParam)

    if isLeft == 1 then
        self.m_leftNameText.text = PlotLanguage.GetString(languageCfgName, tonumber(characterName))
        self.m_leftNameBg:SetActive(true)
        self.m_rightNameBg:SetActive(false)
        self:LoadLeftWujiangModel(wujiangID, weaponLevel, tonumber(paramList[1]), tonumber(paramList[3]), tonumber(paramList[4]), paramList[6], paramList[7] == '1', tonumber(paramList[8]))
    else
        self.m_rightNameText.text = PlotLanguage.GetString(languageCfgName, tonumber(characterName))
        self.m_rightNameBg:SetActive(true)
        self.m_leftNameBg:SetActive(false)
        self:LoadRightWujiangModel(wujiangID, weaponLevel, tonumber(paramList[1]), tonumber(paramList[3]), tonumber(paramList[4]), paramList[6], paramList[7] == '1', tonumber(paramList[8]))
    end
    self:UpdateMsgText(languageCfgName, message)

    if self.m_isCloseMainUI then
        local UIMgrInstance = UIManagerInst
        UIMgrInstance:CloseWindowExceptRemain({self.winName, UIWindowNames.UIMain, UIWindowNames.UIServerNotice})
        UIMgrInstance:Broadcast(UIMessageNames.MN_HIDE_MAIN)
    end
end

function UIGuideWujiangDialogView:OnClick(go, x, y)
    local name = go.name
    if name == "skipBtn" then
        UIUtil.TryClick(self.m_skipBtn)
        DOTween.KillAll()
		TimelineMgr:GetInstance():SkipTo(100)
        self:CloseSelf()
    elseif name == "closeBtn" then
        if self.m_isTweenCloseNow then
            return
        end

        if self.m_isCloseWhenClick then
            self:TweenClose()
        else
            TimelineMgr:GetInstance():CheckTimelinePerform()
        end
    end
end

function UIGuideWujiangDialogView:OnDisable(...)
    base.OnDisable(self, ...)
    local UIMgrInstance = UIManagerInst
    Logger.Log("UIGuideWujiangDialog Close : " .. (self.m_isCloseMainUI and "True" or "False"))
    if self.m_isCloseMainUI then
        UIMgrInstance:OpenWindow(UIWindowNames.UIMainMenu)
        if UIMgrInstance:IsWindowOpen(UIWindowNames.UIMain) then
            UIMgrInstance:Broadcast(UIMessageNames.MN_SHOW_MAIN)
        else
            UIMgrInstance:OpenWindow(UIWindowNames.UIMain)
        end
    end
end

return UIGuideWujiangDialogView