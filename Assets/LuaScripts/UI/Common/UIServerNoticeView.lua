local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local DOTweenExtensions = CS.DOTween.DOTweenExtensions
local DOTween = CS.DOTween.DOTween
local Type_CanvasGroup = typeof(CS.UnityEngine.CanvasGroup)

local Vector3 = Vector3
local Vector2 = Vector2
local userMgr = Player:GetInstance():GetUserMgr() 

local math_ceil = math.ceil
local table_insert = table.insert
local string_format = string.format
 
 --ShowTime一定要大于Move_Y_TiME
local ShowTime = 3
local ShowTimeOnlyOne = 10
local Move_X_Time = 6
local Move_Y_TiME = 2

local UIServerNoticeView = BaseClass("UIServerNoticeView", UIBaseView)
local base = UIBaseView

function UIServerNoticeView:OnCreate()
    base.OnCreate(self)
    self.m_isOne = true
    self.m_start = false

    self:InitView() 
end

function UIServerNoticeView:InitView()
    self.m_serverNoticeImgTr,
    self.m_serverNoticeTxt1Tr,
    self.m_serverNoticeTxt2Tr = UIUtil.GetChildTransforms(self.transform, {
        "ServerNoticeImg",
        "ServerNoticeImg/NoticeTxt1",
        "ServerNoticeImg/NoticeTxt2",
    }) 

    self.m_serverNoticeTxt1,
    self.m_serverNoticeTxt2 = UIUtil.GetChildTexts(self.transform, {
        "ServerNoticeImg/NoticeTxt1",
        "ServerNoticeImg/NoticeTxt2",
    })

    self:Reset() 
    self:HideNoticeImg()
end

function UIServerNoticeView:OnEnable(...)
    base.OnEnable(self, ...) 
end    

function UIServerNoticeView:HideNoticeImg()
    local imgGo = self.m_serverNoticeImgTr.gameObject
    if imgGo.activeInHierarchy then
        imgGo:SetActive(false)
    end
end

function UIServerNoticeView:ShowNoticeImg()
    local imgGo = self.m_serverNoticeImgTr.gameObject
    if not imgGo.activeInHierarchy then
        imgGo:SetActive(true)
    end
end

function UIServerNoticeView:Reset()
    self.m_isOne = true
    self.m_serverNoticeTxt1.text = ""
    self.m_serverNoticeTxt2.text = ""
    self.m_imgWidth = self.m_serverNoticeImgTr.sizeDelta.x 
    self.m_serverNoticeTxt1Tr.anchoredPosition = Vector2.New(-(self.m_imgWidth / 2), -45) 
    self.m_serverNoticeTxt2Tr.anchoredPosition = Vector2.New(-(self.m_imgWidth / 2), -45) 
end

function UIServerNoticeView:OnServerNotice() 
    DOTweenExtensions.Kill(self.m_tweener_One_1)
    DOTweenExtensions.Kill(self.m_tweener_One_2)
    DOTweenExtensions.Kill(self.m_tweener_Two_1)
    DOTweenExtensions.Kill(self.m_tweener_Two_2) 
    DOTweenExtensions.Kill(self.m_tweener) 
 
    self.m_start = true
    self:Reset() 
    self:ShowNoticeImg() 
    self:UpdateData(false, true)
end 

function UIServerNoticeView:UpdateData(isDelay, isNew) 
    if not self.m_start then
        return
    end 
    local noticeList = userMgr:GetServerNoticList()  

    if isDelay and not isNew then 
        local time = ShowTimeOnlyOne
        if noticeList and #noticeList > 1 then
            time = ShowTime
        end
        
        coroutine.waitforseconds(time)  
        --删除一条信息
        userMgr:DeleteOneServerNotice() 

        if noticeList and #noticeList > 0 then
            if self.m_isOne then  
                self.m_tweener_One_1 = DOTweenShortcut.DOLocalMoveY(self.m_serverNoticeTxt1Tr, 45, Move_Y_TiME) 
                DOTweenSettings.OnComplete(self.m_tweener_One_1, function()  
                    self.m_serverNoticeTxt1.text = ""   
                    self.m_serverNoticeTxt1Tr.anchoredPosition = Vector2.New(-(self.m_imgWidth / 2), -45)
                end) 
            else 
                self.m_tweener_Two_2 = DOTweenShortcut.DOLocalMoveY(self.m_serverNoticeTxt2Tr, 45, Move_Y_TiME)
                DOTweenSettings.OnComplete(self.m_tweener_Two_2, function()   
                    self.m_serverNoticeTxt2.text = ""   
                    self.m_serverNoticeTxt2Tr.anchoredPosition = Vector2.New(-(self.m_imgWidth / 2), -45)
                end)
            end 
            self.m_isOne = not self.m_isOne
        end
    end 
     
    if noticeList and #noticeList > 0 then  
        local str = tostring(noticeList[1])
        if not str then
            Debug.LogError("str is nil")
            return
        end 
        
        if self.m_isOne then
            self.m_serverNoticeTxt1.text = str 
        else
            self.m_serverNoticeTxt2.text = str 
        end
        
        if isDelay and not isNew then
            if self.m_isOne then   
                self.m_tweener_Two_1 = DOTweenShortcut.DOLocalMoveY(self.m_serverNoticeTxt1Tr, 0, Move_Y_TiME)
                DOTweenSettings.OnComplete(self.m_tweener_Two_1, function()  
                    self.m_serverNoticeTxt1Tr.anchoredPosition = Vector2.New(-(self.m_imgWidth / 2), 0) 
                    coroutine.start(self.DelayShow, self)
                end) 
            else  
                self.m_tweener_One_2 = DOTweenShortcut.DOLocalMoveY(self.m_serverNoticeTxt2Tr, 0, Move_Y_TiME)
                DOTweenSettings.OnComplete(self.m_tweener_One_2, function()  
                    self.m_serverNoticeTxt2Tr.anchoredPosition = Vector2.New(-(self.m_imgWidth / 2), 0)
                    coroutine.start(self.DelayShow, self)
                end)
            end 
        else 
            self.m_tweener_Two_1 = DOTweenShortcut.DOLocalMoveY(self.m_serverNoticeTxt1Tr, 0, Move_Y_TiME)
            DOTweenSettings.OnComplete(self.m_tweener_Two_1, function()  
                self.m_serverNoticeTxt1Tr.anchoredPosition = Vector2.New(-(self.m_imgWidth / 2), 0) 
                coroutine.start(self.DelayShow, self)
            end) 
        end 
    else
        self:HideNoticeImg()
        DOTweenExtensions.Kill(self.m_tweener_One_1)
        DOTweenExtensions.Kill(self.m_tweener_One_2)
        DOTweenExtensions.Kill(self.m_tweener_Two_1)
        DOTweenExtensions.Kill(self.m_tweener_Two_2) 
        DOTweenExtensions.Kill(self.m_tweener) 
        self.m_start = false
    end
end

function UIServerNoticeView:DelayShow()
    coroutine.waitforseconds(0.1)
    local txtWidth = 0
    if self.m_isOne then
        txtWidth = self.m_serverNoticeTxt1Tr.sizeDelta.x 
    else
        txtWidth = self.m_serverNoticeTxt2Tr.sizeDelta.x 
    end 

    if txtWidth > self.m_imgWidth then  
        local endPosX = txtWidth - (self.m_imgWidth / 2)
        local txtTr = self.m_isOne and self.m_serverNoticeTxt1Tr or self.m_serverNoticeTxt2Tr 
        self.m_tweener = DOTweenShortcut.DOLocalMoveX(txtTr, -endPosX, Move_X_Time) 
        DOTweenSettings.OnComplete(self.m_tweener, function()  
            coroutine.start(self.UpdateData, self, true)
        end)
    else 
        coroutine.start(self.UpdateData, self, true)
    end 
end   

function UIServerNoticeView:OnDisable() 
    base.OnDisable(self)
end

function UIServerNoticeView:OnDestroy()
    base.OnDestroy(self)
end 

function UIServerNoticeView:OnAddListener()
    base.OnAddListener(self)

    self:AddUIListener(UIMessageNames.MN_USER_SERVER_NOTICE, self.OnServerNotice)  
end

function UIServerNoticeView:OnRemoveListener()
    self:RemoveUIListener(UIMessageNames.MN_USER_SERVER_NOTICE, self.OnServerNotice)  
    
    base.OnRemoveListener(self)
end


return UIServerNoticeView