local string_format = string.format
local math_floor = math.floor
local UIDownloadDialogView = BaseClass("UIDownloadDialogView", UIBaseView)
base = UIBaseView

function UIDownloadDialogView:OnCreate()
    base.OnCreate(self)
    self.m_tipsText, self.m_downloadText, self.m_processText = UIUtil.GetChildTexts(self.transform, {
        "BgRoot/tipsText",
        "BgRoot/downloadText",
        "BgRoot/processText",
    })
    self.m_tipsText.text = Language.GetString(4203)
    self.m_downloadMsg = Language.GetString(4204)
    self.m_totalDownloadMsg = Language.GetString(4205)

    self.loading_slider = self:AddComponent(UISlider, "BgRoot/SliderBar")
	self.loading_slider:SetValue(0)
end

function UIDownloadDialogView:OnEnable(...)
    base.OnEnable(self, ...)

    coroutine.start(function()
        coroutine.yieldstart(ResourcesManagerInst.CoDownloadAllAssetbundle, function(co, progress, curABName, alreadyDownloadSize, totalABSize)
            assert(progress <= 1.0, "Progress should be normalized value : " .. progress)
            self.m_downloadText.text = string_format(self.m_downloadMsg, curABName, math_floor(progress * 100))
            local totalPercent = alreadyDownloadSize / totalABSize
            self.m_processText.text = string_format(self.m_totalDownloadMsg, totalPercent * 100, UIUtil.KBSizeToString(alreadyDownloadSize), UIUtil.KBSizeToString(totalABSize))
            self.loading_slider:SetValue(totalPercent)
        end, ResourcesManagerInst)

        UIManagerInst:Broadcast(UIMessageNames.MN_MAIN_ICON_REFRESH)

        local userMgr = Player:GetInstance():GetUserMgr()
        if userMgr:IsTakeDownloadAward() then
            UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(9),Language.GetString(4206), Language.GetString(10))
        else
            userMgr:ReqTakeDownloadAward()
        end
        self:CloseSelf()
	end)
end

return UIDownloadDialogView