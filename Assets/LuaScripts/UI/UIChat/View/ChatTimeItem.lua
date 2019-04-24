local UIUtil = UIUtil
local Vector3 = Vector3
local TimeUtil = TimeUtil
local Quaternion = Quaternion
local Type_RectTransform = typeof(CS.UnityEngine.RectTransform)

local ChatTimeItem = BaseClass("ChatTimeItem", UIBaseItem)
local base = UIBaseItem

function ChatTimeItem:OnCreate()
    base.OnCreate(self)

    self.m_chatTimeText 
    = UIUtil.GetChildTexts(self.transform, {
        "chatTimeText",
    })

    self.m_rectTransform = self.transform:GetComponent(Type_RectTransform)
    self.m_localPos = Vector3.zero
    self.m_localRotation = Quaternion.identity
    self.m_groupIndex = 0
    self.m_groupInnerIndex = 0
end

function ChatTimeItem:OnDestroy()
    
    self.m_chatTimeText = nil

    self.m_rectTransform = nil
    self.m_localPos = nil
    self.m_localRotation = nil
    self.m_groupIndex = nil
    self.m_groupInnerIndex = nil

    self.OnDestroy(self)
end

function ChatTimeItem:UpdateData(timeData, groupIndex, groupInnerIndex, callBack, callBackParams)
    if not timeData then
        return
    end
    self.m_groupIndex = groupIndex
    self.m_groupInnerIndex = groupInnerIndex

    self.m_chatTimeText.text = timeData.isShowDate and TimeUtil.ToYearMonthDayHourMinSec(timeData.speakTime, 67, false) or TimeUtil.ToHourMinSec(timeData.speakTime)

    if callBack then
        callBack(self, callBackParams)
    end
end

function ChatTimeItem:SetLocalPos(worldPos)
    self.transform:SetPositionAndRotation(worldPos, self.m_localRotation)
    self.m_localPos = self.transform.localPosition
end

function ChatTimeItem:GetLocalPos()
    return self.m_localPos
end

function ChatTimeItem:GetGroupIndex()
    return self.m_groupIndex
end

function ChatTimeItem:GetGroupInnerIndex()
    return self.m_groupInnerIndex
end

function ChatTimeItem:GetVerticalInterval()
    return self.m_rectTransform.sizeDelta.y + 10
end

function ChatTimeItem:IsChatItem()
    return false
end

return ChatTimeItem