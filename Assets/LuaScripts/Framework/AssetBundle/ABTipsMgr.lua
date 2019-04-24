local string_format = string.format
local table_insert = table.insert
local ABTipsMgr = BaseClass("ABTipsMgr", Singleton)

function ABTipsMgr:__init()
    self.m_isAlreadyShow = false
    self.m_isAllowDownload = false
    self.m_downloadList = {}
    self.m_loadCallbackList = {}
end


function ABTipsMgr:ShowABLoadFailTips(callback)
	if self.m_isAlreadyShow then
		return
	end

	local titleMsg = Language.GetString(9)
	local contentMsg = Language.GetString(1600)
	local btn1Msg = Language.GetString(1601)
    self.m_isAlreadyShow = UIManagerInst:OpenTipsWindow(titleMsg, contentMsg, btn1Msg, function()
        self.m_isAlreadyShow = false
        callback() 
    end, nil, nil, false)

    UIManagerInst:CloseWindow(UIWindowNames.UIDownloadTips)
end

function ABTipsMgr:ShowABLoadTips(downloadList, callback)
    if self.m_isAllowDownload then
        callback()
        return
    end

    table_insert(self.m_loadCallbackList, callback)
    self:AddDownloadList(downloadList)
	local contentMsg = string_format(Language.GetString(1602), self:GetDownloadSize())
    if UIManagerInst:IsWindowOpen(UIWindowNames.UITipsDialog) then
        UIManagerInst:Broadcast(UIMessageNames.MN_TIPS_MESSAGE_CHG, contentMsg)
    else
        local titleMsg = Language.GetString(9)
        local btn1Msg = Language.GetString(1603)
        local btn2Msg = Language.GetString(50)
        UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, titleMsg, contentMsg, btn1Msg, function()
            self.m_isAllowDownload = true
            self.m_downloadList = {}
            for _, v in ipairs(self.m_loadCallbackList) do
                v()
            end
            self.m_loadCallbackList = {}
        end, btn2Msg, function()
            self.m_downloadList = {}
            self.m_loadCallbackList = {}
            UIManagerInst:Broadcast(UIMessageNames.MN_DOWNLOAD_CANCLE)
        end, false)
    end
end

function ABTipsMgr:AddDownloadList(downloadList)
    for abName, size in pairs(downloadList) do
        self.m_downloadList[abName] = size
    end
end

function ABTipsMgr:GetDownloadSize()
    local downloadSize = 0
    for _, size in pairs(self.m_downloadList) do
        downloadSize = downloadSize + size
    end
    return self:KBSizeToString(downloadSize)
end

function ABTipsMgr:KBSizeToString(kbSize)
    local sizeStr = nil
    if kbSize >= 1024 then
        sizeStr = string.format("%.2f", kbSize / 1024) .. "M"
    else
        sizeStr = kbSize .. "K"
    end

    return sizeStr
end

return ABTipsMgr