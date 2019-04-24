

local SplitString = CUtil.SplitString
local UIGMView = BaseClass("UIGMView", UIBaseView)
local base = UIBaseView

function UIGMView:OnCreate()
	base.OnCreate(self)

    self.cmdInput = self:AddComponent(UIInput, "Container/CmdInput")

    self.m_submitBtnBtn, self.m_closeBtn = UIUtil.GetChildTransforms(self.transform,
       {"Container/SubmitBtn", "Container/CloseBtn"} )

    self.m_timeText = UIUtil.GetChildTexts(self.transform, {
        "Container/TimeText",
    })

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_submitBtnBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, onClick)
end

function UIGMView:OnClick(go)
    if go.name == "SubmitBtn" then
        local content = self.cmdInput:GetText()
        local strList = SplitString(content, ' ')
        if strList[1] == "guide" then
            coroutine.start(function()
                coroutine.waitforseconds(0.5)
                self:CloseSelf()
                 GuideMgr:GetInstance():Play(tonumber(strList[2]))
            end)
        elseif strList[1] == "video" then
            Player:GetInstance():GetVideoMgr():ReqVideo(strList[2], VIDEO_TYPE.NORMAL)
        else
            local msg_id = MsgIDDefine.ADMIN_REQ_EXEC_CMD
            local msg = (MsgIDMap[msg_id])()
            --msg.cmd = 'addallwujiang'
            msg.cmd = content
            HallConnector:GetInstance():SendMessage(msg_id, msg)
        end
    elseif go.name == "CloseBtn" then
        UIManagerInst:CloseWindow(UIWindowNames.UIGMView)
    end
end

function UIGMView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_submitBtnBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    base.OnDestroy(self)
end

function UIGMView:Update()
    self.m_timeText.text = TimeUtil.ToYearMonthDayHourMinSec(Player:GetInstance():GetServerTime())
end

return UIGMView