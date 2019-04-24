local UIUtil = UIUtil
local UIManager = UIManager
local UIMessageNames = UIMessageNames
local MsgIDDefine = MsgIDDefine
local HallConnector = HallConnector

local UIEmailItem = BaseClass("UIEmailItem", UIBaseItem)
local base = UIBaseItem

function UIEmailItem:Delete()
    UIUtil.RemoveClickEvent(self.m_selectBtn.gameObject)
    
    self.m_go = false
    self.m_transform = false
    self.m_resPath = false
    self.m_emailInfo = nil
    self.m_bgnoSelectTr = nil
    self.m_bgSelectTr = nil
    self.m_selectBtn = nil
    self.m_emailSenderLabel = nil
    self.m_sendTimeLabel = nil
    self.m_itemIconSpt = nil
    self.m_isSelect = false
end

function UIEmailItem:OnCreate()
    base.OnCreate(self)

    self.m_go = false
    self.m_resPath = false

    self.m_emailInfo = nil
    self.m_emailIndex = 0

    self.m_selectBtn = UIUtil.GetChildTransforms(self.transform, { "selectBtn" })
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_selectBtn.gameObject, onClick)

    self.m_bgnoSelectTr, self.m_bgSelectTr = 
    UIUtil.GetChildTransforms(self.transform, {
        "bgno", "bgyes"
    })

    self.m_itemIconSpt = UIUtil.AddComponent(UIImage, self, "itemIcon", AtlasConfig.DynamicLoad)

    self.m_emailSenderLabel, self.m_sendTimeLabel = UIUtil.GetChildTexts(self.transform, {
        "fromText","timeText"
    })

    self.m_isSelect = false
end

function UIEmailItem:UpdateData(emailInfo, index, isSelelct)
    self.m_emailInfo = emailInfo
    self.m_emailIndex = index
    if isSelelct then
        self:OnClick()
        self.m_bgnoSelectTr.gameObject:SetActive(false)
        self.m_bgSelectTr.gameObject:SetActive(true)
    else
        self.m_bgnoSelectTr.gameObject:SetActive(true)
        self.m_bgSelectTr.gameObject:SetActive(false)
    end

    if emailInfo.attach_count > 0 then
        self.m_itemIconSpt:SetAtlasSprite("youjian1.png", false, AtlasConfig.DynamicLoad)
    else
        if emailInfo.is_read == 1 then
            self.m_itemIconSpt:SetAtlasSprite("youjian2.png", false, AtlasConfig.DynamicLoad)
        else
            self.m_itemIconSpt:SetAtlasSprite("youjian3.png", false, AtlasConfig.DynamicLoad)
        end
    end

    self.m_emailSenderLabel.text = emailInfo.sender 
    self.m_sendTimeLabel.text = TimeUtil.ToYearMonthDayHourMinSec(emailInfo.send_time, 69)
end

function UIEmailItem:OnClick()
    if self.m_isSelect then -- 只刷新UI，不重复请求
        self.m_bgnoSelectTr.gameObject:SetActive(false)
        self.m_bgSelectTr.gameObject:SetActive(true)
        return
    end
    self.m_isSelect = true

    UIManagerInst:Broadcast(UIMessageNames.MN_MAIL_ITEM_ONSELECT, self, self.m_emailIndex)
    local msg_id = MsgIDDefine.MAIL_REQ_MAIL_READ
    local msg = (MsgIDMap[msg_id])()
    msg.mail_seq = self.m_emailInfo.mail_seq
	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function UIEmailItem:OnNoSelect()
    self.m_bgnoSelectTr.gameObject:SetActive(true)
    self.m_bgSelectTr.gameObject:SetActive(false)
    self.m_isSelect = false
end

function UIEmailItem:ReadEmail()
    if self.m_emailInfo.attach_count == 0 then
        self.m_itemIconSpt:SetAtlasSprite("youjian2.png", false, AtlasConfig.DynamicLoad)
    end
end

function UIEmailItem:SetSiblingIndex(index)
    self.transform:SetSiblingIndex(index)
end

function UIEmailItem:GetMailSeq()
    return self.m_emailInfo.mail_seq
end

function UIEmailItem:GetMailIndex()
    return self.m_emailIndex
end

return UIEmailItem