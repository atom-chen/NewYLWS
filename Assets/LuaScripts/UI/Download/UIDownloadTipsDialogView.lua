local string_format = string.format
local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam"
local Application = CS.UnityEngine.Application
local NetworkReachability = CS.UnityEngine.NetworkReachability

local UIDownloadTipsDialogView = BaseClass("UIDownloadTipsDialogView", UIBaseView)
base = UIBaseView

function UIDownloadTipsDialogView:OnCreate()
    base.OnCreate(self)
    self.m_bagItemSeq = 0
    self.m_item = nil

    self.m_titleText, self.m_downloadBtnText, self.m_msgText = UIUtil.GetChildTexts(self.transform, {
        "BgRoot/titleText",
        "BgRoot/ContentRoot/downloadBtn/downloadBtnText",
        "BgRoot/ContentRoot/msgText"
    })
    self.m_titleText.text = Language.GetString(9)
    self.m_downloadBtnText.text = Language.GetString(4200)

    self.m_downloadBtn, self.m_closeBtn, self.m_contentRoot = UIUtil.GetChildTransforms(self.transform, {
        "BgRoot/ContentRoot/downloadBtn",
        "CloseBtn",
        "BgRoot/ContentRoot",
    })
    self.m_downloadBtn = self.m_downloadBtn.gameObject

    self:HandleClick()
end

function UIDownloadTipsDialogView:OnEnable(...)
    base.OnEnable(self, ...)

    Player:GetInstance():GetUserMgr():HideDownloadRedPoint()
    UIManagerInst:Broadcast(UIMessageNames.MN_MAIN_ICON_REFRESH_RED_POINT)
    self.m_msgText.text = string_format(Language.GetString(4201), UIUtil.KBSizeToString(AssetBundleMgrInst:GetAllNeedDownloadABSize()))
    self.m_bagItemSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
    UIGameObjectLoader:GetInstance():GetGameObject(self.m_bagItemSeq, CommonAwardItemPrefab, function(go)
        self.m_bagItemSeq = 0
        if not go then
            return
        end
        
        self.m_item = CommonAwardItem.New(go, self.m_contentRoot, CommonAwardItemPrefab)
        self.m_item:SetAnchoredPosition(Vector3.New(50, -90, 0))
        local itemIconParam = AwardIconParamClass.New(10002, 100)
        self.m_item:UpdateData(itemIconParam)
    end)
end

function UIDownloadTipsDialogView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
   
    UIUtil.AddClickEvent(self.m_downloadBtn, onClick)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
end

function UIDownloadTipsDialogView:RemoveEvent()
    UIUtil.RemoveClickEvent(self.m_downloadBtn)
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
end

function UIDownloadTipsDialogView:OnClick(go, x, y)
    if go.name == "downloadBtn" then
        if Application.internetReachability == NetworkReachability.ReachableViaLocalAreaNetwork then
            UIManagerInst:OpenWindow(UIWindowNames.UIDownloadDialog)
        else
            UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(9),Language.GetString(4202), Language.GetString(10), function()
                UIManagerInst:OpenWindow(UIWindowNames.UIDownloadDialog)
            end, Language.GetString(50))
        end
    end
    
    coroutine.start(function()
        coroutine.waitforseconds(0.1)
        self:CloseSelf()
    end)
end

function UIDownloadTipsDialogView:OnDestroy()
    UIGameObjectLoader:GetInstance():CancelLoad(self.m_bagItemSeq)
    self.m_bagItemSeq = 0

    if self.m_item then
        self.m_item:Delete()
        self.m_item = nil
    end
    self:RemoveEvent()
    base.OnDestroy(self)
end

return UIDownloadTipsDialogView