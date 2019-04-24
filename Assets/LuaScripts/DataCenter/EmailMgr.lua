

local EmailMgr = BaseClass("EmailMgr")
local table_insert = table.insert
local table_remove = table.remove

local EmailInfo = require("DataCenter/EmailData/EmailInfo")

function EmailMgr:__init()
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.MAIL_RSP_MAIL_LIST, Bind(self, self.RspMailList))--请求邮件列表
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.MAIL_RSP_MAIL_READ, Bind(self, self.RspMailRead)) --请求设置为已读
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.MAIL_RSP_TAKE_ATTACH, Bind(self, self.RspMailTakeAttach))--请求提取附件
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.MAIL_RSP_TAKE_ATTACH_LIST, Bind(self, self.RspMailTakeAttachList))--请求提取所有附件
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.MAIL_RSP_DELETE_MAIL, Bind(self, self.RspDeleteMail))--请求删除附件

    self.m_emailList = {}
end

function EmailMgr:RspMailList(msg_obj)
    if not msg_obj or msg_obj.result ~= 0 then
        return
    end

    self.m_emailList = {}
    local mailList = msg_obj.mail_list
    local count = #mailList
    if mailList and count > 0 then
        for i=1,count do
            table_insert(self.m_emailList, {
                                            sender = mailList[i].sender,
                                            send_time = mailList[i].send_time,
                                            is_read = mailList[i].is_read,
                                            mail_seq = mailList[i].mail_seq,
                                            attach_count = mailList[i].attach_count,}
                                        )
        end
    end

    UIManagerInst:Broadcast(UIMessageNames.MN_MAIL_RSP_MAILLIST, msg_obj)  
    self:SetEmailRedPoint()
end

function EmailMgr:RspMailRead(msg_obj)
    if not msg_obj or msg_obj.result ~= 0 then
        return
    end

    if msg_obj.result == 0 then
        UIManagerInst:Broadcast(UIMessageNames.MN_MAIL_RSP_MAILREAD, msg_obj)
        self:SetEmailRedPoint()
    end
end

function EmailMgr:RspMailTakeAttach(msg_obj)
    if not msg_obj or msg_obj.result ~= 0 then
        return
    end

    if msg_obj.is_delete == 1 then
        local count = #self.m_emailList
        if count > 0 then
        
            for i=count,1,-1 do
                if self.m_emailList[i].mail_seq == msg_obj.mail_seq then
                    table_remove(self.m_emailList, i)
                end
            end
        end
    end

    UIManagerInst:Broadcast(UIMessageNames.MN_MAIL_RSP_TAKEATTACH, self.m_emailList, msg_obj)
    self:SetEmailRedPoint()
end


function EmailMgr:RspMailTakeAttachList(msg_obj)
    if not msg_obj or msg_obj.result ~= 0 then
        return
    end

    local deleList = {}

    local attachList = msg_obj.mail_attach_list
    if attachList and #attachList > 0 then
        local count = #attachList   
        for i=count,1,-1 do 
            if attachList[i].is_delete == 1 then
                deleList[attachList[i].mail_seq] = true
            end
        end
    end

    for i=#self.m_emailList,1,-1 do
        if deleList[self.m_emailList[i].mail_seq] then
            table_remove(self.m_emailList, i)
        end
    end

    UIManagerInst:Broadcast(UIMessageNames.MN_MAIL_RSP_TAKEATTACHLIST, self.m_emailList, msg_obj)
    self:SetEmailRedPoint()
end

function EmailMgr:RspDeleteMail(msg_obj)
    if not msg_obj or msg_obj.result ~= 0 then
        return
    end

    local count = #self.m_emailList
    if count > 0 then
        for i=count,1,-1 do
            if self.m_emailList[i].mail_seq == msg_obj.mail_seq then
                table_remove(self.m_emailList, i)
            end
        end
    end

    UIManagerInst:Broadcast(UIMessageNames.MN_MAIL_DELETEEMEIL, self.m_emailList)

    self:SetEmailRedPoint()
end

function EmailMgr:SetEmailRedPoint()
    local IsAllWorked = self:IsAllEmailWorked()
    local userMgr = Player:GetInstance():GetUserMgr()
    if IsAllWorked then  
        userMgr:DeleteRedPointID(SysIDs.EMAIL)
    else
        userMgr:AddRedPointId(SysIDs.EMAIL)
    end
    UIManagerInst:Broadcast(UIMessageNames.MN_MAIN_ICON_REFRESH_RED_POINT)
end

function EmailMgr:IsAllEmailWorked()
    local isAllWorked = true 

    for k, v in pairs(self.m_emailList) do
        if v.attach_count > 0 then
            isAllWorked = false 
            break
        end
        if v.is_read == 0 then
            isAllWorked = false
            break
        end
    end

    return isAllWorked 
end

return EmailMgr